package model;

import DAO.CartPersistenceDAO;
import model.Cart;
import model.CartItem;

public class CartService {

    private final CartPersistenceDAO dao = new CartPersistenceDAO();

    // Al login: merge tra cart sessione (ospite) e cart DB (se esiste)
    public Cart mergeSessionWithDb(int userId, Cart sessionCart) {
        Cart dbCart = dao.loadCartForUser(userId);

        if (sessionCart != null && !sessionCart.isEmpty()) {
            for (CartItem it : sessionCart.getItems()) {
                // merge by prodottoId + taglia + personalizzazione
                dbCart.mergeItem(it); // implementa mergeItem in Cart → se "uguale" somma quantita
            }
            try {
                dao.saveCartForUser(userId, dbCart);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return dbCart;
    }

    // Dopo qualsiasi modifica al carrello (se loggato), persisti
    public void persistIfLogged(Integer userId, Cart cart) {
        if (userId == null) return;
        try { dao.saveCartForUser(userId, cart); } catch (Exception e) { e.printStackTrace(); }
    }
}
