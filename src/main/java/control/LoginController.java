package control;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import DAO.UtenteDAO;
import model.UtenteBean;
import model.PasswordUtils;

/**
 * Servlet che gestisce il login utente.
 * - Recupera le credenziali dal form
 * - Verifica username e password (hash PBKDF2)
 * - Se corrette, crea la sessione e reindirizza a home.jsp
 * - Se errate, rimanda al login con messaggio di errore
 */
@WebServlet("/login")
public class LoginController extends HttpServlet {
    
    private UtenteDAO utenteDAO;

    // Inizializza il DAO alla creazione della servlet
    @Override 
    public void init() { 
        utenteDAO = new UtenteDAO(); 
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Recupera username e password dal form di login
        String username = request.getParameter("username");
        String passwordInserita = request.getParameter("password");

        // 2. Cerca l’utente in base all’username
        UtenteBean utente = utenteDAO.findByUsername(username);

        // 3. Se l’utente esiste e la password inserita corrisponde all’hash salvato → login valido
        if (utente != null && PasswordUtils.verify(passwordInserita, utente.getPassw())) {
            
            // 3a. Crea/recupera la sessione e memorizza l’utente
            HttpSession session = request.getSession();
            session.setAttribute("utente", utente);
            session.setAttribute("ruolo", utente.getRuolo());

            // 3b. Migrazione trasparente:
            //     se nel DB era ancora salvata una password in chiaro,
            //     la sostituiamo subito con l’hash sicuro PBKDF2
            if (!utente.getPassw().startsWith("pbkdf2_sha256$")) {
                String nuovoHash = PasswordUtils.hash(passwordInserita);
                utenteDAO.updatePasswordHash(utente.getId(), nuovoHash);
            }

            // 3c. Redirect alla home page protetta
            response.sendRedirect("home.jsp");

        } else {
            // 4. Credenziali non valide:
            //    - aggiunge un messaggio di errore
            //    - ritorna al login (index.html) mostrando l’errore
            request.setAttribute("errore", "Username o password errati");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
