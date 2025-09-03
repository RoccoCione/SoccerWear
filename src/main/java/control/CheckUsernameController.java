package control;

import DAO.UtenteDAO;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.*;
import java.io.IOException;

@WebServlet("/api/check-username")
public class CheckUsernameController extends HttpServlet {
    private UtenteDAO dao;

    @Override public void init() { dao = new UtenteDAO(); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        boolean exists = (username != null && dao.existsByUsername(username));
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write("{\"exists\":" + exists + "}");
    }
}
