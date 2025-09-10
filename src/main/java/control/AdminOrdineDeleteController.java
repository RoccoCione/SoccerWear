package control;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.LinkedHashMap;
import java.util.Map;

import model.UtenteBean;

@WebServlet("/admin/ordini/delete")
public class AdminOrdineDeleteController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        HttpSession s = req.getSession(false);
        if (s == null) { resp.sendRedirect(req.getContextPath()+"/home.jsp"); return; }

        UtenteBean u = (UtenteBean) s.getAttribute("utente");
        if (u == null || !"admin".equalsIgnoreCase(u.getRuolo())) {
            s.setAttribute("flashError", "Non autorizzato.");
            resp.sendRedirect(req.getContextPath()+"/gestioneordini.jsp");
            return;
        }

        String idStr = req.getParameter("id");
        String restockStr = req.getParameter("restock"); // "1" per ripristinare stock (opzionale)
        boolean restock = "1".equals(restockStr);

        Integer ordineId;
        try { ordineId = Integer.valueOf(idStr); }
        catch (Exception e) {
            s.setAttribute("flashError", "ID ordine non valido.");
            resp.sendRedirect(req.getContextPath()+"/gestioneordini.jsp");
            return;
        }

        Connection con = null;
        try {
            con = model.ConnectionDatabase.getConnection();
            con.setAutoCommit(false);

            // 0) Verifica esistenza ordine e cattura spedizione_id
            Integer spedizioneId = null;
            try (PreparedStatement ps = con.prepareStatement(
                "SELECT spedizione_id FROM ordine WHERE id=?")) {
                ps.setInt(1, ordineId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        s.setAttribute("flashError", "Ordine non trovato.");
                        resp.sendRedirect(req.getContextPath()+"/gestioneordini.jsp");
                        return;
                    }
                    spedizioneId = (Integer) rs.getObject(1);
                }
            }

            // 1) (Opzionale) Ripristina stock in base alle righe dell’ordine
            if (restock) {
                Map<Integer, Integer> qtyByProdotto = new LinkedHashMap<>();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT prodotto_id, quantita FROM riga_ordine WHERE ordine_id=? AND prodotto_id IS NOT NULL")) {
                    ps.setInt(1, ordineId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Integer pid = (Integer) rs.getObject("prodotto_id");
                            int q = rs.getInt("quantita");
                            if (pid != null) qtyByProdotto.merge(pid, q, Integer::sum);
                        }
                    }
                }
                if (!qtyByProdotto.isEmpty()) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE prodotto SET unita_disponibili = unita_disponibili + ? WHERE id=?")) {
                        for (Map.Entry<Integer,Integer> e : qtyByProdotto.entrySet()) {
                            ps.setInt(1, e.getValue());
                            ps.setInt(2, e.getKey());
                            ps.addBatch();
                        }
                        ps.executeBatch();
                    }
                }
            }

            // 2) Cancella personalizzazioni righe
            try (PreparedStatement ps = con.prepareStatement(
                    "DELETE rop FROM riga_ordine_personalizzazione rop " +
                    "JOIN riga_ordine r ON r.id = rop.riga_ordine_id " +
                    "WHERE r.ordine_id=?")) {
                ps.setInt(1, ordineId);
                ps.executeUpdate();
            }

            // 3) Cancella righe
            try (PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM riga_ordine WHERE ordine_id=?")) {
                ps.setInt(1, ordineId);
                ps.executeUpdate();
            }

            // 4) Cancella pagamento
            try (PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM pagamento WHERE ordine_id=?")) {
                ps.setInt(1, ordineId);
                ps.executeUpdate();
            }

            // 5) Cancella fattura
            try (PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM fattura WHERE ordine_id=?")) {
                ps.setInt(1, ordineId);
                ps.executeUpdate();
            }

            // 6) Cancella ordine
            try (PreparedStatement ps = con.prepareStatement(
                    "DELETE FROM ordine WHERE id=?")) {
                ps.setInt(1, ordineId);
                ps.executeUpdate();
            }

            // 7) Cancella spedizione se non più referenziata da altri ordini
            if (spedizioneId != null) {
                boolean usedElsewhere = false;
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT 1 FROM ordine WHERE spedizione_id=? LIMIT 1")) {
                    ps.setInt(1, spedizioneId);
                    try (ResultSet rs = ps.executeQuery()) {
                        usedElsewhere = rs.next();
                    }
                }
                if (!usedElsewhere) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "DELETE FROM spedizione WHERE id=?")) {
                        ps.setInt(1, spedizioneId);
                        ps.executeUpdate();
                    }
                }
            }

            con.commit();
            s.setAttribute("flashOk", "Ordine #" + ordineId + " eliminato" + (restock ? " (stock ripristinato)." : "."));
            resp.sendRedirect(req.getContextPath()+"/gestioneordini.jsp");

        } catch (Exception ex) {
            ex.printStackTrace();
            if (con != null) try { con.rollback(); } catch (SQLException ignore) {}
            s.setAttribute("flashError", "Errore eliminazione: " + ex.getMessage());
            resp.sendRedirect(req.getContextPath()+"/gestioneordini.jsp");
        } finally {
            if (con != null) try { con.setAutoCommit(true); con.close(); } catch (SQLException ignore) {}
        }
    }
}
