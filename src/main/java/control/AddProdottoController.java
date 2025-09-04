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

        // ✅ Solo ADMIN
        HttpSession sess = request.getSession(false);
        UtenteBean u = (sess != null) ? (UtenteBean) sess.getAttribute("utente") : null;
        if (u == null || !"ADMIN".equalsIgnoreCase(u.getRuolo())) {
            response.sendRedirect(request.getContextPath() + "/home.jsp");
            return;
        }

        try {
            // --- Parametri dal form ---
            String nome        = getParam(request, "nome");
            String descrizione = firstNonBlank(getParam(request, "descrizione"), getParam(request, "squadra")); // compat
            Integer numeroMaglia = parseInteger(getParam(request, "numero_maglia")); // opzionale
            String taglia      = getParam(request, "taglia");
            String categoria   = getParam(request, "categoria");

            Double costo = parseDouble(getParam(request, "costo"));
            Double iva   = parseDouble(getParam(request, "iva"));
            Integer unita = parseInteger(getParam(request, "unita_disponibili"));

            // --- Foto (opzionale, BLOB) ---
            byte[] fotoBytes = null;
            Part foto = request.getPart("foto");
            if (foto != null && foto.getSize() > 0) {
                try (InputStream is = foto.getInputStream()) {
                    fotoBytes = is.readAllBytes();
                }
            }

            // --- Validazioni minime ---
            if (nome == null || nome.isBlank()) {
                request.setAttribute("errore", "Il nome prodotto è obbligatorio.");
                request.getRequestDispatcher("/admincatalogo.jsp").forward(request, response);
                return;
            }
            if (costo == null || iva == null) {
                request.setAttribute("errore", "Inserisci costo e IVA.");
                request.getRequestDispatcher("/admincatalogo.jsp").forward(request, response);
                return;
            }

            // --- Bean ---
            ProdottoBean p = new ProdottoBean();
            p.setNome(nome);
            p.setDescrizione(descrizione);
            p.setNumeroMaglia(numeroMaglia);
            p.setTaglia(taglia);
            p.setCategoria(categoria);
            p.setCosto(costo);
            p.setIva(iva);
            p.setUnitaDisponibili(unita != null ? unita : 0);
            p.setFoto(fotoBytes);
            p.setAttivo(true); // nuovo prodotto attivo

            // --- Insert ---
            boolean ok = prodottoDAO.insert(p);

            if (ok) {
                request.setAttribute("successo", "Prodotto inserito correttamente (ID: " + p.getId() + ").");
            } else {
                request.setAttribute("errore", "Inserimento non riuscito.");
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            request.setAttribute("errore", "Errore: " + ex.getMessage());
        }

        // Torna alla pagina admin
        request.getRequestDispatcher("/admincatalogo.jsp").forward(request, response);
    }

    // --- Utility ---
    private String getParam(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return (v != null) ? v.trim() : null;
    }
    private Integer parseInteger(String v) {
        try { return (v == null || v.isBlank()) ? null : Integer.parseInt(v); }
        catch (Exception e) { return null; }
    }
    private Double parseDouble(String v) {
        try { return (v == null || v.isBlank()) ? null : Double.parseDouble(v); }
        catch (Exception e) { return null; }
    }
    private String firstNonBlank(String a, String b) {
        if (a != null && !a.isBlank()) return a;
        if (b != null && !b.isBlank()) return b;
        return null;
    }
}
