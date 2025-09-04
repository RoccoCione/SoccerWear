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

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String nome = request.getParameter("nome");
            String descrizione = request.getParameter("descrizione");
            String categoria = request.getParameter("categoria");
            String taglia = request.getParameter("taglia");

            Double costo = parseDouble(request.getParameter("costo"));
            Double iva = parseDouble(request.getParameter("iva"));
            Integer unita = parseInteger(request.getParameter("unita_disponibili"));

            byte[] fotoBytes = null;
            Part foto = request.getPart("foto");
            if (foto != null && foto.getSize() > 0) {
                try (InputStream is = foto.getInputStream()) {
                    fotoBytes = is.readAllBytes();
                }
            }

            ProdottoBean p = new ProdottoBean();
            p.setId(id);
            p.setNome(nome);
            p.setDescrizione(descrizione);
            p.setCategoria(categoria);
            p.setTaglia(taglia);
            p.setCosto(costo != null ? costo : 0.0);
            p.setIva(iva != null ? iva : 0.0);
            p.setUnitaDisponibili(unita);
            p.setFoto(fotoBytes);
            p.setAttivo(true); // default

            boolean ok = prodottoDAO.update(p);

            HttpSession session = request.getSession();
            if (ok) {
                session.setAttribute("successo", "Prodotto aggiornato correttamente.");
            } else {
                session.setAttribute("errore", "Aggiornamento non riuscito.");
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            request.getSession().setAttribute("errore", "Errore: " + ex.getMessage());
        }

        // 👉 redirect (non forward)
        response.sendRedirect(request.getContextPath() + "/admincatalogo.jsp");
    }

    private Integer parseInteger(String v) {
        try { return (v==null||v.isBlank()) ? null : Integer.parseInt(v); }
        catch(Exception e){ return null; }
    }
    private Double parseDouble(String v) {
        try { return (v==null||v.isBlank()) ? null : Double.parseDouble(v); }
        catch(Exception e){ return null; }
    }
}
