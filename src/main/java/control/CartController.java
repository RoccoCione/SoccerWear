package control;

import DAO.ProdottoDAO;
import model.Cart;
import model.CartItem;
import model.ProdottoBean;
import model.UtenteBean;
import model.CartService;   // <<— aggiungi questa import

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet(urlPatterns = {
        "/cart/add",
        "/cart/update",
        "/cart/remove",
        "/cart/clear",
        "/cart/view"
})
public class CartController extends HttpServlet {

    private ProdottoDAO prodottoDAO;
    private CartService cartService; // <<— servizio per persistenza DB

    @Override
    public void init() {
        prodottoDAO = new ProdottoDAO();
        cartService = new CartService(); // <<— init service
    }

    private Cart getOrCreateCart(HttpServletRequest req) {
        HttpSession sess = req.getSession(true);
        Cart cart = (Cart) sess.getAttribute("cart");
        if (cart == null) {
            cart = new Cart();
            sess.setAttribute("cart", cart);
        }
        return cart;
    }

    /** user id se loggato, altrimenti null */
    private Integer getLoggedUserId(HttpServletRequest req) {
        UtenteBean u = (UtenteBean) req.getSession().getAttribute("utente");
        return (u != null) ? u.getId() : null;
    }

    /** dopo ogni modifica del carrello, persisti se loggato */
    private void syncIfLogged(HttpServletRequest req, Cart cart) {
        Integer userId = getLoggedUserId(req);
        cartService.persistIfLogged(userId, cart);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String path = request.getServletPath();
        Cart cart = getOrCreateCart(request);

        switch (path) {
            case "/cart/view": {
                request.getRequestDispatcher("/carrello.jsp").forward(request, response);
                return;
            }
            case "/cart/clear": {
                cart.clear();
                updateBadge(request);
                // sincronizza DB (salva carrello vuoto) se loggato
                syncIfLogged(request, cart);
                response.sendRedirect(request.getContextPath() + "/carrello.jsp");
                return;
            }
            default: {
                response.sendRedirect(request.getContextPath() + "/carrello.jsp");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String path = request.getServletPath();
        Cart cart = getOrCreateCart(request);

        switch (path) {
            case "/cart/add": {
                try {
                    int id = Integer.parseInt(n(request.getParameter("id")));
                    String taglia = n(request.getParameter("taglia"));
                    int quantita = parseIntSafe(request.getParameter("quantita"), 1);
                    String nomeRetro = s(request.getParameter("nome_retro"));
                    String numeroRetro = s(request.getParameter("numero_retro"));

                    ProdottoBean p = prodottoDAO.findById(id);
                    if (p == null || !p.isAttivo()) {
                        request.getSession().setAttribute("flashError", "Prodotto non disponibile.");
                        response.sendRedirect(request.getHeader("Referer") != null ? request.getHeader("Referer")
                                : (request.getContextPath() + "/catalogo.jsp"));
                        return;
                    }
                    if (taglia == null || taglia.isBlank()) {
                        request.getSession().setAttribute("flashError", "Seleziona una taglia.");
                        response.sendRedirect(request.getHeader("Referer") != null ? request.getHeader("Referer")
                                : (request.getContextPath() + "/catalogo.jsp"));
                        return;
                    }
                    if (quantita <= 0) quantita = 1;

                    CartItem item = new CartItem(
                            p.getId(),
                            p.getNome(),
                            p.getCosto(),
                            p.getIva(),
                            taglia,
                            quantita,
                            nomeRetro,
                            numeroRetro
                    );
                    cart.addOrMerge(item);
                    updateBadge(request);

                    // sincronizza DB
                    syncIfLogged(request, cart);

                    response.sendRedirect(request.getContextPath() + "/carrello.jsp");
                } catch (Exception ex) {
                    ex.printStackTrace();
                    request.getSession().setAttribute("flashError", "Errore nell'aggiunta al carrello.");
                    response.sendRedirect(request.getContextPath() + "/catalogo.jsp");
                }
                return;
            }
            case "/cart/update": {
                int idx = parseIntSafe(request.getParameter("idx"), -1);
                int qty = parseIntSafe(request.getParameter("quantita"), 1);
                cart.updateQuantity(idx, qty);
                updateBadge(request);

                // sincronizza DB
                syncIfLogged(request, cart);

                response.sendRedirect(request.getContextPath() + "/carrello.jsp");
                return;
            }
            case "/cart/remove": {
                int idx = parseIntSafe(request.getParameter("idx"), -1);
                cart.remove(idx);
                updateBadge(request);

                // sincronizza DB
                syncIfLogged(request, cart);

                response.sendRedirect(request.getContextPath() + "/carrello.jsp");
                return;
            }
            default: {
                response.sendRedirect(request.getContextPath() + "/carrello.jsp");
            }
        }
    }

    private void updateBadge(HttpServletRequest req) {
        Cart cart = (Cart) req.getSession().getAttribute("cart");
        req.getSession().setAttribute("cartCount", cart != null ? cart.getItemCount() : 0);
    }

    private static String n(String s) { return s == null ? null : s.trim(); }
    private static String s(String s) { s = n(s); return (s == null || s.isEmpty()) ? null : s; }
    private static int parseIntSafe(String v, int def) {
        try { return Integer.parseInt(v); } catch (Exception e) { return def; }
    }
}
