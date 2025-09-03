package control;

import DAO.ProdottoDAO;
import model.ProdottoBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/catalogo")
public class CatalogoControl extends HttpServlet {

    private ProdottoDAO prodottoDAO;

    @Override
    public void init() {
        prodottoDAO = new ProdottoDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Recupera tutti i prodotti
        List<ProdottoBean> prodotti = prodottoDAO.findAll();

        // Salva nella request
        request.setAttribute("prodotti", prodotti);

        // Inoltra a catalogo.jsp
        request.getRequestDispatcher("/catalogo.jsp").forward(request, response);
    }
}
