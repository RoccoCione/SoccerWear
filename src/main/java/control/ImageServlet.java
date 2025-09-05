package control;

import DAO.ProdottoDAO;
import model.ProdottoBean;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.OutputStream;

@WebServlet("/image")
public class ImageServlet extends HttpServlet {
    private ProdottoDAO dao;

    @Override
    public void init() {
        dao = new ProdottoDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idStr = req.getParameter("id");
        if (idStr == null) {
            resp.sendError(400, "Parametro id mancante");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            ProdottoBean p = dao.findById(id);

            if (p == null || p.getFoto() == null) {
                resp.sendError(404, "Immagine non trovata");
                return;
            }

            // Content type: se hai sempre JPEG va bene così
            resp.setContentType("image/jpeg");
            resp.setContentLength(p.getFoto().length);

            resp.getOutputStream().write(p.getFoto());
        } catch (NumberFormatException e) {
            resp.sendError(400, "Parametro id non valido");
        }
    }
}
