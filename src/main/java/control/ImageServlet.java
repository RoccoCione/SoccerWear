package control;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import DAO.ProdottoDAO;
import model.ProdottoBean;

@WebServlet("/image")
public class ImageServlet extends HttpServlet {
    private ProdottoDAO prodottoDAO = new ProdottoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String idStr = request.getParameter("id");
        if (idStr == null) return;

        try {
            int id = Integer.parseInt(idStr);
            ProdottoBean p = prodottoDAO.findById(id);

            if (p != null && p.getFoto() != null) {
                response.setContentType("image/jpeg");
                response.setContentLength(p.getFoto().length);
                response.getOutputStream().write(p.getFoto());
            } else {
                response.sendRedirect(request.getContextPath() + "/img/no-photo.png");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
