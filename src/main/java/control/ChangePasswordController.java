package control;

import DAO.UtenteDAO;
import model.UtenteBean;
import model.PasswordUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/profile/change-password")
public class ChangePasswordController extends HttpServlet {

    private UtenteDAO utenteDAO;

    @Override
    public void init() {
        utenteDAO = new UtenteDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession sess = request.getSession(false);
        if (sess == null || sess.getAttribute("utente") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        UtenteBean current = (UtenteBean) sess.getAttribute("utente");
        int userId = current.getId();

        String oldPwd = request.getParameter("oldPassword");
        String newPwd = request.getParameter("newPassword");
        String newPwd2 = request.getParameter("newPassword2");

        // Controllo password attuale
        if (!PasswordUtils.verify(oldPwd, current.getPassw())) {
            request.setAttribute("errore", "La password attuale non è corretta.");
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
            return;
        }

        // Controllo nuova password
        if (newPwd == null || !newPwd.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&]).{8,}$")) {
            request.setAttribute("errore", "La nuova password non rispetta i requisiti.");
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
            return;
        }

        if (!newPwd.equals(newPwd2)) {
            request.setAttribute("errore", "Le nuove password non coincidono.");
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
            return;
        }

        // Hash nuova password
        String hash = PasswordUtils.hash(newPwd);

        // Aggiornamento DB
        boolean ok = utenteDAO.updatePasswordHash(userId, hash);

        if (ok) {
            current.setPassw(hash); // aggiorno anche la sessione
            sess.setAttribute("utente", current);
            request.setAttribute("successo", "Password aggiornata con successo.");
        } else {
            request.setAttribute("errore", "Errore durante l'aggiornamento della password.");
        }

        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }
}
