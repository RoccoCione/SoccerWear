package control;

import DAO.ProdottoDAO;
import model.ProdottoBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/search"})
public class SearchController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String q = req.getParameter("q");
        q = (q == null) ? "" : q.trim();

        List<ProdottoBean> risultati;
        try {
            if (q.length() < 2) {
                // se query troppo corta: nessun filtro (o vuota, scegli tu)
                risultati = new ProdottoDAO().findAll();
                req.setAttribute("searchNotice", "Inserisci almeno 2 caratteri (mostro tutto).");
            } else {
                risultati = new ProdottoDAO().searchByNameOrCategory(q, 100);
                if (risultati.isEmpty()) {
                    req.setAttribute("searchNotice", "Nessun prodotto trovato per: \"" + q + "\"");
                } else {
                    req.setAttribute("searchNotice", "Risultati per: \"" + q + "\"");
                }
            }
        } catch (Exception e) {
            // Log e fallback
            e.printStackTrace();
            req.setAttribute("searchNotice", "Si è verificato un errore durante la ricerca.");
            risultati = java.util.Collections.emptyList();
        }

        req.setAttribute("q", q);
        req.setAttribute("prodotti", risultati);
        // riuso la pagina catalogo (oppure una pagina results.jsp, se preferisci)
        req.getRequestDispatcher("/catalogo.jsp").forward(req, resp);
    }
}
