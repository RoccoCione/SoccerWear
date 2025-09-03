package control;

import DAO.UtenteDAO;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.*;
import java.io.IOException;

@WebServlet("/api/check-email")
public class CheckEmailController extends HttpServlet {
    private UtenteDAO dao;

    @Override public void init() { dao = new UtenteDAO(); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        boolean exists = (email != null && dao.existsByEmail(email));
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write("{\"exists\":" + exists + "}");
    }
}
