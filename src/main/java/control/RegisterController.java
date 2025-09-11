package control;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import DAO.UtenteDAO;
import model.UtenteBean;
import model.PasswordUtils;

@WebServlet("/register")
public class RegisterController extends HttpServlet {

    private UtenteDAO utenteDAO;

    @Override
    public void init() {
        utenteDAO = new UtenteDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1) Parametri dal form
        String nome = request.getParameter("nome");
        String cognome = request.getParameter("cognome");
        String username = request.getParameter("username");
        String email = request.getParameter("email");          // 👈 OBBLIGATORIO
        String password = request.getParameter("password");

        // (facoltativo) validazione email basica lato server
        if (email == null || !email.matches("^[\\w.+\\-]+@[\\w\\-]+\\.[\\w.]{2,}$")) {
            request.setAttribute("errore", "Inserisci un'email valida.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // 2) Regole password
        if (!isPasswordValida(password)) {
            request.setAttribute("errore",
                "La password deve contenere almeno 8 caratteri, una maiuscola, una minuscola, un numero e un carattere speciale.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // 3) Unicità username/email
        if (utenteDAO.existsByUsername(username)) {
            request.setAttribute("errore", "Username già in uso.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        if (utenteDAO.existsByEmail(email)) {                 // 👈 controllo email
            request.setAttribute("errore", "Email già registrata.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // 4) Hash password
        String stored = PasswordUtils.hash(password);

        // 5) Bean utente
        UtenteBean utente = new UtenteBean();
        utente.setNome(nome);
        utente.setCognome(cognome);
        utente.setUsername(username);
        utente.setEmail(email);                               // 👈 salva email nel bean
        utente.setPassw(stored);
        utente.setRuolo("cliente");                           // default

        // Debug utile se serve
        System.out.println("DEBUG register -> email: " + utente.getEmail());

        // 6) Persistenza
        boolean registrato = utenteDAO.register(utente);

        // 7) Esito
        if (registrato) {
        	request.getSession().setAttribute("flashOk", "Registrazione completata! Benvenuto/a.");
        	response.sendRedirect(request.getContextPath() + "/login.jsp");
        } else {
            request.setAttribute("errore", "Registrazione fallita. Riprova.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }

    private boolean isPasswordValida(String password) {
        if (password == null) return false;
        String pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$";
        return password.matches(pattern);
    }
}
