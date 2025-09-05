package DAO;

import model.*;
import java.sql.*;
import java.util.*;

public class CartPersistenceDAO {

    // Trova o crea l'ordine CREATO per l’utente (carrello DB)
    public Integer findOrCreateDraftOrderId(int userId, Connection con) throws SQLException {
        // 1) prova a trovare
        try (PreparedStatement ps = con.prepareStatement(
            "SELECT id FROM ordine WHERE utente_id=? AND stato='CREATO' ORDER BY id DESC LIMIT 1")) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        // 2) crea
        try (PreparedStatement ps = con.prepareStatement(
            "INSERT INTO ordine(utente_id, spedizione_id, stato, totale_spesa, totale_iva) VALUES(?, null, 'CREATO', 0, 0)",
            Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        throw new SQLException("Impossibile creare ordine bozza (CREATO).");
    }

    // Carica il carrello DB in un oggetto Cart
    public Cart loadCartForUser(int userId) {
        Cart cart = new Cart();
        try (Connection con = ConnectionDatabase.getConnection()) {
            Integer ordineId = null;
            try (PreparedStatement ps = con.prepareStatement(
                "SELECT id FROM ordine WHERE utente_id=? AND stato='CREATO' ORDER BY id DESC LIMIT 1")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) ordineId = rs.getInt(1);
                }
            }
            if (ordineId == null) return cart; // vuoto

            // righe
            try (PreparedStatement ps = con.prepareStatement(
                "SELECT id, prodotto_id, nome_prodotto, taglia, prezzo_unitario, iva, quantita " +
                "FROM riga_ordine WHERE ordine_id=? ORDER BY id")) {
                ps.setInt(1, ordineId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        CartItem it = new CartItem();
                        it.setProductId(rs.getInt("prodotto_id")); // può essere NULL → allora gestisci come snapshot
                        it.setNome(rs.getString("nome_prodotto"));
                        it.setTaglia(rs.getString("taglia"));
                        it.setPrezzo(rs.getDouble("prezzo_unitario"));
                        it.setIva(rs.getDouble("iva"));
                        it.setQuantita(rs.getInt("quantita"));
                        // personalizzazioni
                        it = fillCustomizations(con, rs.getInt("id"), it);
                        cart.addOrMerge(it);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return cart;
    }

    private CartItem fillCustomizations(Connection con, int rigaId, CartItem it) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
            "SELECT opzione_label, valore FROM riga_ordine_personalizzazione WHERE riga_ordine_id=?")) {
            ps.setInt(1, rigaId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String label = rs.getString("opzione_label");
                    String value = rs.getString("valore");
                    if ("Nome maglia".equalsIgnoreCase(label)) it.setNomeRetro(value);
                    if ("Numero".equalsIgnoreCase(label))     it.setNumeroRetro(value);
                }
            }
        }
        return it;
    }

    // Sovrascrive il carrello DB con la versione di sessione (più semplice e robusto)
    public void saveCartForUser(int userId, Cart cart) throws SQLException {
        try (Connection con = ConnectionDatabase.getConnection()) {
            con.setAutoCommit(false);
            try {
                int ordineId = findOrCreateDraftOrderId(userId, con);

                // pulisci righe e personalizzazioni esistenti
                try (PreparedStatement ps = con.prepareStatement(
                    "DELETE rop FROM riga_ordine_personalizzazione rop " +
                    "JOIN riga_ordine ro ON rop.riga_ordine_id=ro.id WHERE ro.ordine_id=?")) {
                    ps.setInt(1, ordineId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = con.prepareStatement("DELETE FROM riga_ordine WHERE ordine_id=?")) {
                    ps.setInt(1, ordineId);
                    ps.executeUpdate();
                }

                // reinserisci snapshot dal cart
                String insRiga = "INSERT INTO riga_ordine(ordine_id, prodotto_id, nome_prodotto, taglia, prezzo_unitario, iva, quantita, totale_riga) " +
                                 "VALUES(?,?,?,?,?,?,?,?)";
                String insPers = "INSERT INTO riga_ordine_personalizzazione(riga_ordine_id, opzione_label, valore, prezzo_extra) VALUES(?,?,?,?)";

                for (CartItem it : cart.getItems()) {
                    double totaleRiga = it.getPrezzo() * it.getQuantita(); // (eventuale extra personalizzazioni lo sommi se previsto)
                    int rigaId;
                    try (PreparedStatement ps = con.prepareStatement(insRiga, Statement.RETURN_GENERATED_KEYS)) {
                        if (it.getProductId() > 0) ps.setInt(2, it.getProductId()); else ps.setNull(2, Types.INTEGER);
                        ps.setInt(1, ordineId);
                        ps.setString(3, it.getNome());
                        ps.setString(4, it.getTaglia());
                        ps.setDouble(5, it.getPrezzo());
                        ps.setDouble(6, it.getIva());
                        ps.setInt(7, it.getQuantita());
                        ps.setDouble(8, totaleRiga);
                        ps.executeUpdate();
                        try (ResultSet rs = ps.getGeneratedKeys()) {
                            rs.next();
                            rigaId = rs.getInt(1);
                        }
                    }
                    // personalizzazioni (facoltative)
                    if (it.getNomeRetro() != null && !it.getNomeRetro().isBlank()) {
                        try (PreparedStatement ps = con.prepareStatement(insPers)) {
                            ps.setInt(1, rigaId);
                            ps.setString(2, "Nome maglia");
                            ps.setString(3, it.getNomeRetro());
                            ps.setDouble(4, 0.00); // se vuoi extra prezzo
                            ps.executeUpdate();
                        }
                    }
                    if (it.getNumeroRetro() != null && !it.getNumeroRetro().isBlank()) {
                        try (PreparedStatement ps = con.prepareStatement(insPers)) {
                            ps.setInt(1, rigaId);
                            ps.setString(2, "Numero");
                            ps.setString(3, it.getNumeroRetro());
                            ps.setDouble(4, 0.00);
                            ps.executeUpdate();
                        }
                    }
                }

                // opzionale: aggiorna totali bozza (non obbligatorio qui)
                try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE ordine SET totale_spesa=?, totale_iva=? WHERE id=?")) {
                    ps.setDouble(1, cart.getSubtotaleNetto());
                    ps.setDouble(2, cart.getTotaleIva());
                    ps.setInt(3, ordineId);
                    ps.executeUpdate();
                }

                con.commit();
            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        }
    }
}
