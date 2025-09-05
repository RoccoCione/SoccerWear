package control;

import DAO.ProdottoDAO;
import model.ProdottoBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;

@WebServlet("/admin/edit-prodotto")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024)
public class EditProdottoController extends HttpServlet {
    private ProdottoDAO prodottoDAO;

    @Override
    public void init() {
        prodottoDAO = new ProdottoDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        try {
            // 1) ID robusto
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.isBlank()) {
                session.setAttribute("errore", "ID mancante: impossibile modificare.");
                response.sendRedirect(request.getContextPath() + "/admincatalogo.jsp");
                return;
            }
            int id = Integer.parseInt(idStr);

            // 2) Carica il record esistente (se non c'è, NON creare)
            ProdottoBean existing = prodottoDAO.findById(id);
            if (existing == null) {
                session.setAttribute("errore", "Prodotto non trovato (id=" + id + ").");
                response.sendRedirect(request.getContextPath() + "/admincatalogo.jsp");
                return;
            }

            // 3) Leggi campi dalla form
            String nome        = request.getParameter("nome");
            String descrizione = request.getParameter("descrizione");
            String categoria   = request.getParameter("categoria");
            String taglia      = request.getParameter("taglia");

            // interi/decimali con parsing safe (accetta anche virgola)
            Integer numeroMaglia     = parseInteger(request.getParameter("numero_maglia"));
            Integer unitaDisponibili = parseInteger(request.getParameter("unita_disponibili"));
            Double  costo            = parseDouble(request.getParameter("costo"));
            Double  iva              = parseDouble(request.getParameter("iva"));

            // 4) Foto opzionale: se non caricata, tieni quella esistente
            byte[] fotoBytes = null;
            Part foto = request.getPart("foto"); // con @MultipartConfig non è null
            if (foto != null && foto.getSize() > 0) {
                try (InputStream is = foto.getInputStream()) {
                    fotoBytes = is.readAllBytes();
                }
            }

            // 5) Aggiorna SOLO i campi: se un campo è nullo nella form, mantieni quello esistente
            ProdottoBean p = new ProdottoBean();
            p.setId(id);
            p.setNome(nome != null ? nome : existing.getNome());
            p.setDescrizione(descrizione != null ? descrizione : existing.getDescrizione());
            p.setCategoria(categoria != null ? categoria : existing.getCategoria());
            p.setTaglia(taglia != null ? taglia : existing.getTaglia());
            p.setNumeroMaglia(numeroMaglia != null ? numeroMaglia : existing.getNumeroMaglia());
            p.setUnitaDisponibili(unitaDisponibili != null ? unitaDisponibili : existing.getUnitaDisponibili());
            p.setCosto(costo != null ? costo : existing.getCosto());
            p.setIva(iva != null ? iva : existing.getIva());
            p.setFoto(fotoBytes != null ? fotoBytes : existing.getFoto());
            p.setAttivo(existing.isAttivo()); // non toccare lo stato

            // 6) UPDATE (mai insert qui)
            boolean ok = prodottoDAO.update(p);
            if (ok) {
                session.setAttribute("successo", "Prodotto aggiornato correttamente.");
            } else {
                session.setAttribute("errore", "Aggiornamento non riuscito.");
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            session.setAttribute("errore", "Errore: " + ex.getMessage());
        }

        // Redirect alla lista (Post/Redirect/Get)
        response.sendRedirect(request.getContextPath() + "/admincatalogo.jsp");
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
}
