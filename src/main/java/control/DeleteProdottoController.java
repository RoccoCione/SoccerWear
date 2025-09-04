package control;

import DAO.ProdottoDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/delete-prodotto")
public class DeleteProdottoController extends HttpServlet {
    private ProdottoDAO prodottoDAO;

    @Override
    public void init() { prodottoDAO = new ProdottoDAO(); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean ok = prodottoDAO.delete(id);
            if (ok) {
                request.setAttribute("successo", "Prodotto eliminato correttamente.");
            } else {
                request.setAttribute("errore", "Eliminazione non riuscita.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errore", "Errore: " + e.getMessage());
        }

        request.getRequestDispatcher("/admincatalogo.jsp").forward(request, response);
    }
}
