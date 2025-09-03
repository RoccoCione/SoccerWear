package control;

import DAO.UtenteDAO;
import model.UtenteBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/profile/update")
public class ProfileUpdateController extends HttpServlet {

    private UtenteDAO utenteDAO;

    @Override public void init() { utenteDAO = new UtenteDAO(); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession sess = request.getSession(false);
        if (sess == null || sess.getAttribute("utente") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        UtenteBean current = (UtenteBean) sess.getAttribute("utente");
        int userId = current.getId();

        // Parametri
        String nome = request.getParameter("nome");
        String cognome = request.getParameter("cognome");
        String email = request.getParameter("email");
        String telefono = request.getParameter("telefono");
        String indirizzo = request.getParameter("indirizzo");
        String etaStr = request.getParameter("eta");

        // Validazione email base
        if (email == null || !email.matches("^[\\w.+\\-]+@[\\w\\-]+\\.[\\w.]{2,}$")) {
            request.setAttribute("errore", "Email non valida.");
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
            return;
        }

        // Unicità email (se cambiata)
        if (!email.equalsIgnoreCase(current.getEmail()) && utenteDAO.existsByEmailExceptUser(email, userId)) {
            request.setAttribute("errore", "Questa email è già registrata.");
            request.getRequestDispatcher("/profile.jsp").forward(request, response);
            return;
        }

        Integer eta = null;
        try { if (etaStr != null && !etaStr.isBlank()) eta = Integer.parseInt(etaStr); } catch (NumberFormatException ignored) {}

        // Prepara bean aggiornato
        UtenteBean updated = new UtenteBean();
        updated.setId(userId);
        updated.setUsername(current.getUsername()); // non modificabile qui
        updated.setRuolo(current.getRuolo());       // non modificabile qui
        updated.setNome(nome);
        updated.setCognome(cognome);
        updated.setEmail(email);
        updated.setTelefono(telefono);
        updated.setIndirizzo(indirizzo);
        updated.setEta(eta);
        updated.setPassw(current.getPassw());       // non cambiamo la password qui

        boolean ok = utenteDAO.updateProfile(updated);
        if (ok) {
            // Aggiorna la sessione con i nuovi valori
            sess.setAttribute("utente", updated);
            request.setAttribute("successo", "Profilo aggiornato correttamente.");
            
        } else {
            request.setAttribute("errore", "Aggiornamento profilo non riuscito.");
        }

        request.getRequestDispatcher("/profile.jsp").forward(request, response);
    }
}
