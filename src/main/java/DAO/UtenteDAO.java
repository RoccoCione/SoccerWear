package DAO;

import java.sql.*;
import model.UtenteBean;
import model.ConnectionDatabase;

public class UtenteDAO {

    // 🔹 Login (nota: qui di solito NON si confronta la password in chiaro nel DB,
    // ma usi PasswordUtils.verify() fuori dal DAO)
    public UtenteBean login(String username, String password) {
        UtenteBean utente = null;
        String sql = "SELECT * FROM utente WHERE username = ? AND passw = ?";

        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    utente = mapUtente(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return utente;
    }

    // 🔹 Registrazione
    public boolean register(UtenteBean u) {
        String sql = "INSERT INTO utente (username, email, passw, nome, cognome, ruolo) VALUES (?,?,?,?,?,?)";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, u.getUsername());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPassw());
            ps.setString(4, u.getNome());
            ps.setString(5, u.getCognome());
            ps.setString(6, u.getRuolo());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 🔹 Check se username esiste
    public boolean existsByUsername(String username) {
        String sql = "SELECT 1 FROM utente WHERE username = ?";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return true; // per sicurezza, blocca registrazione in caso di errore
        }
    }

    // 🔹 Check se email esiste
    public boolean existsByEmail(String email) {
        String sql = "SELECT 1 FROM utente WHERE email = ?";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return true;
        }
    }

    // 🔹 Trova utente per username
    public UtenteBean findByUsername(String username) {
        UtenteBean u = null;
        String sql = "SELECT * FROM utente WHERE username = ?";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    u = mapUtente(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return u;
    }

    // 🔹 Check email univoca (escludendo utente stesso)
    public boolean existsByEmailExceptUser(String email, int excludeUserId) {
        String sql = "SELECT 1 FROM utente WHERE email = ? AND id <> ?";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setInt(2, excludeUserId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return true;
        }
    }

    // 🔹 Aggiorna password
    public boolean updatePasswordHash(int userId, String newHash) {
        String sql = "UPDATE utente SET passw = ? WHERE id = ?";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newHash);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 🔹 Aggiorna profilo
    public boolean updateProfile(UtenteBean u) {
        String sql = "UPDATE utente SET nome=?, cognome=?, email=?, telefono=?, eta=?, indirizzo=? WHERE id=?";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, u.getNome());
            ps.setString(2, u.getCognome());
            ps.setString(3, u.getEmail());
            ps.setString(4, u.getTelefono());
            if (u.getEta() == null) {
                ps.setNull(5, Types.INTEGER);
            } else {
                ps.setInt(5, u.getEta());
            }
            ps.setString(6, u.getIndirizzo());
            ps.setInt(7, u.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // 🔹 Utility per mappare un ResultSet → UtenteBean
    private UtenteBean mapUtente(ResultSet rs) throws SQLException {
        UtenteBean u = new UtenteBean();
        u.setId(rs.getInt("id"));
        u.setNome(rs.getString("nome"));
        u.setCognome(rs.getString("cognome"));
        u.setUsername(rs.getString("username"));
        u.setPassw(rs.getString("passw"));
        u.setTelefono(rs.getString("telefono"));
        int eta = rs.getInt("eta");
        u.setEta(rs.wasNull() ? null : eta);
        u.setIndirizzo(rs.getString("indirizzo"));
        u.setEmail(rs.getString("email"));
        u.setRuolo(rs.getString("ruolo"));
        return u;
    }
}
