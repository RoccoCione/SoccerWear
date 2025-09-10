package control;

import DAO.ProdottoDAO;
import DAO.SpedizioneDAO;
import model.Cart;
import model.CartItem;
import model.SpedizioneBean;
import model.UtenteBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.List;

@WebServlet(urlPatterns = {"/checkout", "/checkout/submit"})
public class CheckoutController extends HttpServlet {

    private ProdottoDAO prodottoDAO;
    private SpedizioneDAO spedizioneDAO;

    @Override
    public void init() {
        prodottoDAO = new ProdottoDAO();
        spedizioneDAO = new SpedizioneDAO();
    }

    private Cart getCart(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s == null ? null : (Cart) s.getAttribute("cart");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) { resp.sendRedirect(req.getContextPath() + "/home.jsp"); return; }

        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            session.setAttribute("flashError", "Il carrello è vuoto.");
            resp.sendRedirect(req.getContextPath() + "/catalogo.jsp");
            return;
        }
        UtenteBean u = (UtenteBean) session.getAttribute("utente");
        if (u == null) {
            session.setAttribute("flashError", "Effettua il login per procedere al checkout.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }
        req.getRequestDispatcher("/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        if (!"/checkout/submit".equals(req.getServletPath())) {
            resp.sendRedirect(req.getContextPath() + "/checkout");
            return;
        }

        HttpSession session = req.getSession(false);
        if (session == null) { resp.sendRedirect(req.getContextPath() + "/home.jsp"); return; }

        Cart cart = getCart(req);
        if (cart == null || cart.isEmpty()) {
            session.setAttribute("flashError", "Il carrello è vuoto.");
            resp.sendRedirect(req.getContextPath() + "/catalogo.jsp");
            return;
        }
        UtenteBean u = (UtenteBean) session.getAttribute("utente");
        if (u == null) {
            session.setAttribute("flashError", "Effettua il login per procedere al checkout.");
            resp.sendRedirect(req.getContextPath() + "/home.jsp");
            return;
        }

        // Spedizione
        String indirizzo = n(req.getParameter("indirizzo"));
        String cap = n(req.getParameter("cap"));
        String numeroCivico = n(req.getParameter("numero_civico"));
        String citta = n(req.getParameter("citta"));
        if (indirizzo == null || cap == null || numeroCivico == null || citta == null) {
            session.setAttribute("flashError", "Compila tutti i campi di spedizione.");
            resp.sendRedirect(req.getContextPath() + "/checkout");
            return;
        }

        // Metodo pagamento (accetta "payment_method" o "metodo_pagamento")
        String metodo = n(req.getParameter("payment_method"));
        if (metodo == null) metodo = n(req.getParameter("metodo_pagamento"));
        if (metodo == null || !(metodo.equalsIgnoreCase("CARTA") || metodo.equalsIgnoreCase("PAYPAL") || metodo.equalsIgnoreCase("COD"))) {
            session.setAttribute("flashError", "Seleziona un metodo di pagamento valido.");
            resp.sendRedirect(req.getContextPath() + "/checkout");
            return;
        }

        // Se CARTA, valida i campi della carta (dal modale)
        String cardNumber = n(req.getParameter("card_number"));
        String cardCircuit = n(req.getParameter("card_circuit"));
        if ("CARTA".equalsIgnoreCase(metodo)) {
            if (cardNumber == null || cardNumber.length() < 12) {
                session.setAttribute("flashError", "Numero carta non valido.");
                resp.sendRedirect(req.getContextPath() + "/checkout");
                return;
            }
        }

        // Etichetta leggibile da salvare in ordine.metodo_pagamento
        String metodoDisplay;
        if ("CARTA".equalsIgnoreCase(metodo)) {
            String last4 = (cardNumber != null && cardNumber.length() >= 4) ? cardNumber.substring(cardNumber.length() - 4) : "****";
            metodoDisplay = (cardCircuit != null && !cardCircuit.isBlank())
                    ? "Carta " + cardCircuit + " (**** " + last4 + ")"
                    : "Carta (**** " + last4 + ")";
        } else if ("PAYPAL".equalsIgnoreCase(metodo)) {
            metodoDisplay = "PayPal";
        } else {
            metodoDisplay = "Pagamento alla consegna";
        }

        // Totali
        BigDecimal totNetto = bd(cart.getSubtotaleNetto());
        BigDecimal totIva   = bd(cart.getTotaleIva());
        BigDecimal totLordo = bd(cart.getTotaleLordo());

        Connection con = null;
        try {
            con = model.ConnectionDatabase.getConnection();
            con.setAutoCommit(false);

            // 1) SPEDIZIONE
            SpedizioneBean sp = new SpedizioneBean();
            sp.setIndirizzo(indirizzo);
            sp.setCap(cap);
            sp.setNumeroCivico(numeroCivico);
            sp.setCitta(citta);
            sp.setData(new java.sql.Date(System.currentTimeMillis()));

            int spedId = spedizioneDAO.insert(con, sp);
            if (spedId <= 0) throw new SQLException("Impossibile creare la spedizione.");

            // 2) ORDINE (salva spedizione_stato separato)
            Integer ordineId = null;
            try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO ordine (utente_id, spedizione_id, totale_spesa, totale_iva, stato, metodo_pagamento, spedizione_stato) " +
                "VALUES (?,?,?,?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, u.getId());
                ps.setInt(2, spedId);
                ps.setBigDecimal(3, totNetto);
                ps.setBigDecimal(4, totIva);
                ps.setString(5, "CREATO");
                ps.setString(6, metodoDisplay);
                ps.setString(7, "IN_COSTRUZIONE"); // <— nuovo default
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) ordineId = rs.getInt(1);
                }
            }
            if (ordineId == null) throw new SQLException("Impossibile creare l'ordine.");

            // 3) RIGHE + PERSONALIZZAZIONI + SCALA STOCK
            try (PreparedStatement psRiga = con.prepareStatement(
                     "INSERT INTO riga_ordine (ordine_id, prodotto_id, nome_prodotto, taglia, prezzo_unitario, iva, quantita, totale_riga) " +
                     "VALUES (?,?,?,?,?,?,?,?)",
                     Statement.RETURN_GENERATED_KEYS);
                 PreparedStatement psPers = con.prepareStatement(
                     "INSERT INTO riga_ordine_personalizzazione (riga_ordine_id, opzione_label, valore, prezzo_extra) VALUES (?,?,?,?)");
                 PreparedStatement psStock = con.prepareStatement(
                     "UPDATE prodotto SET unita_disponibili = unita_disponibili - ? WHERE id = ? AND unita_disponibili >= ?")) {

                for (CartItem it : cart.getItems()) {
                    // scala stock
                    psStock.setInt(1, it.getQuantita());
                    psStock.setInt(2, it.getProductId());
                    psStock.setInt(3, it.getQuantita());
                    if (psStock.executeUpdate() == 0) {
                        throw new SQLException("Stock insufficiente per " + it.getNome() + " (" + it.getTaglia() + ")");
                    }

                    BigDecimal prezzo = bd(it.getPrezzo());
                    BigDecimal ivaPerc = bd(it.getIva());
                    BigDecimal qta = new BigDecimal(it.getQuantita());
                    BigDecimal lineaNetta = prezzo.multiply(qta);
                    BigDecimal lineaIva = lineaNetta.multiply(ivaPerc).divide(new BigDecimal("100"));
                    BigDecimal totaleRiga = lineaNetta.add(lineaIva);

                    psRiga.setInt(1, ordineId);
                    psRiga.setInt(2, it.getProductId());
                    psRiga.setString(3, it.getNome());
                    psRiga.setString(4, it.getTaglia());
                    psRiga.setBigDecimal(5, prezzo);
                    psRiga.setBigDecimal(6, ivaPerc);
                    psRiga.setInt(7, it.getQuantita());
                    psRiga.setBigDecimal(8, totaleRiga);
                    psRiga.executeUpdate();

                    Integer rigaId = null;
                    try (ResultSet rs = psRiga.getGeneratedKeys()) {
                        if (rs.next()) rigaId = rs.getInt(1);
                    }

                    if (rigaId != null) {
                        if (it.getNomeRetro() != null && !it.getNomeRetro().isBlank()) {
                            psPers.setInt(1, rigaId);
                            psPers.setString(2, "Nome maglia");
                            psPers.setString(3, it.getNomeRetro());
                            psPers.setBigDecimal(4, new BigDecimal("0.00"));
                            psPers.executeUpdate();
                        }
                        if (it.getNumeroRetro() != null && !it.getNumeroRetro().isBlank()) {
                            psPers.setInt(1, rigaId);
                            psPers.setString(2, "Numero");
                            psPers.setString(3, it.getNumeroRetro());
                            psPers.setBigDecimal(4, new BigDecimal("0.00"));
                            psPers.executeUpdate();
                        }
                    }
                }
            }

            // 4) PAGAMENTO (mock)
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO pagamento (ordine_id, metodo_id, importo, esito) VALUES (?,?,?, ?)")) {
                ps.setInt(1, ordineId);
                ps.setNull(2, Types.INTEGER);
                ps.setBigDecimal(3, totLordo);
                ps.setString(4, "OK");
                ps.executeUpdate();
            }

            // 5) FATTURA
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO fattura (ordine_id, totale_spesa, totale_iva) VALUES (?,?,?)")) {
                ps.setInt(1, ordineId);
                ps.setBigDecimal(2, totNetto);
                ps.setBigDecimal(3, totIva);
                ps.executeUpdate();
            }

            // 6) Stato ordine (COD resta CREATO; Carta/PayPal -> PAGATO)
            try (PreparedStatement ps = con.prepareStatement("UPDATE ordine SET stato=? WHERE id=?")) {
                String stato = "COD".equalsIgnoreCase(metodo) ? "CREATO" : "PAGATO";
                ps.setString(1, stato);
                ps.setInt(2, ordineId);
                ps.executeUpdate();
            }

            con.commit();

            cart.clear();
            session.setAttribute("cartCount", 0);

            resp.sendRedirect(req.getContextPath() + "/ordine-success.jsp?id=" + ordineId);

        } catch (Exception ex) {
            ex.printStackTrace();
            if (con != null) try { con.rollback(); } catch (SQLException ignore) {}
            session.setAttribute("flashError", "Errore nel checkout: " + ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/checkout");
        } finally {
            if (con != null) try { con.setAutoCommit(true); con.close(); } catch (SQLException ignore) {}
        }
    }

    private static BigDecimal bd(double d) {
        return new BigDecimal(String.format(java.util.Locale.ENGLISH, "%.2f", d));
    }
    private static String n(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }
}
