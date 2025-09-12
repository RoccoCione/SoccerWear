package control;

import DAO.ProdottoDAO;
import model.ProdottoBean;
import model.UtenteBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;

@WebServlet("/admin/add-prodotto")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10MB
public class AddProdottoController extends HttpServlet {

    private ProdottoDAO prodottoDAO;

    @Override
    public void init() { prodottoDAO = new ProdottoDAO(); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // ✅ Solo ADMIN
        HttpSession sess = request.getSession(false);
        UtenteBean u = (sess != null) ? (UtenteBean) sess.getAttribute("utente") : null;
        if (u == null || !"ADMIN".equalsIgnoreCase(u.getRuolo())) {
            response.sendRedirect(request.getContextPath() + "/home.jsp");
            return;
        }

        // useremo la sessione per i messaggi perché facciamo redirect (PRG)
        HttpSession session = request.getSession();

        try {
            // --- Parametri dal form ---
            String nome        = getParam(request, "nome");
            String descrizione = firstNonBlank(getParam(request, "descrizione"), getParam(request, "squadra")); // compat vecchi form
            String taglia      = getParam(request, "taglia");
            String categoria   = getParam(request, "categoria");
            String tipo        = normalizeTipo(getParam(request, "tipo")); // NEW: Replica | Authentic

            Double costo = parseDouble(getParam(request, "costo")); // gestisce "12,50"
            Double iva   = parseDouble(getParam(request, "iva"));
            Integer unita = parseInteger(getParam(request, "unita_disponibili"));

            // --- Validazioni minime ---
            if (nome == null || nome.isBlank()) {
                session.setAttribute("errore", "Il nome prodotto è obbligatorio.");
                response.sendRedirect(request.getContextPath() + "/admincatalogo.jsp");
                return;
            }
            if (costo == null || iva == null) {
                session.setAttribute("errore", "Inserisci costo e IVA (es. 12.50).");
                response.sendRedirect(request.getContextPath() + "/admincatalogo.jsp");
                return;
            }
            if (tipo == null) {
                session.setAttribute("errore", "Seleziona il tipo prodotto (Replica o Authentic).");
                response.sendRedirect(request.getContextPath() + "/admincatalogo.jsp");
                return;
            }

            // --- Foto (opzionale, BLOB) ---
            byte[] fotoBytes = null;
            Part foto = request.getPart("foto");
            if (foto != null && foto.getSize() > 0) {
                try (InputStream is = foto.getInputStream()) {
                    fotoBytes = is.readAllBytes();
                }
            }

            // --- Bean ---
            ProdottoBean p = new ProdottoBean();
            p.setNome(nome);
            p.setDescrizione(descrizione);
            p.setTaglia(taglia);
            p.setCategoria(categoria);
            p.setCosto(costo);
            p.setIva(iva);
            p.setUnitaDisponibili(unita != null ? unita : 0);
            p.setFoto(fotoBytes);
            p.setAttivo(true); // nuovo prodotto attivo
            p.setTipo(tipo);   // NEW

            // --- Insert ---
            boolean ok = prodottoDAO.insert(p);

            if (ok) {
                session.setAttribute("successo", "Prodotto inserito correttamente (ID: " + p.getId() + ").");
            } else {
                session.setAttribute("errore", "Inserimento non riuscito.");
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("errore", "Errore: " + ex.getMessage());
        }

        // ✅ PRG: Redirect (evita doppio inserimento su refresh)
        response.sendRedirect(request.getContextPath() + "/admincatalogo.jsp");
    }

    // --- Utility ---
    private String getParam(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return (v != null) ? v.trim() : null;
    }
    private Integer parseInteger(String v) {
        try { return (v == null || v.isBlank()) ? null : Integer.parseInt(v.trim()); }
        catch (Exception e) { return null; }
    }
    private Double parseDouble(String v) {
        try {
            if (v == null || v.isBlank()) return null;
            return Double.parseDouble(v.replace(',', '.').trim());
        } catch (Exception e) { return null; }
    }
    private String firstNonBlank(String a, String b) {
        if (a != null && !a.isBlank()) return a;
        if (b != null && !b.isBlank()) return b;
        return null;
    }

    // Accetta solo i due valori previsti, default = Replica
    private String normalizeTipo(String t) {
        if (t == null) return "Replica";
        t = t.trim();
        if ("Authentic".equalsIgnoreCase(t)) return "Authentic";
        return "Replica";
    }
}
