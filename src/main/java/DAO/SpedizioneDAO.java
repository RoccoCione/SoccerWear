package DAO;

import model.ConnectionDatabase;
import model.SpedizioneBean;

import java.sql.*;

public class SpedizioneDAO {

    // Trova spedizione per ID
    public SpedizioneBean findById(int id) {
        String sql = "SELECT id, indirizzo, cap, numero_civico, citta, data FROM spedizione WHERE id=?";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Inserisce nuova spedizione e ritorna l'ID generato
    public int insert(SpedizioneBean s) {
        String sql = "INSERT INTO spedizione (indirizzo, cap, numero_civico, citta, data) VALUES (?,?,?,?,?)";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, s.getIndirizzo());
            ps.setString(2, s.getCap());
            ps.setString(3, s.getNumeroCivico());
            ps.setString(4, s.getCitta());
            ps.setDate(5, s.getData());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        return keys.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1; // errore
    }

    // Mapper ResultSet → Bean
    private SpedizioneBean mapRow(ResultSet rs) throws SQLException {
        SpedizioneBean s = new SpedizioneBean();
        s.setId(rs.getInt("id"));
        s.setIndirizzo(rs.getString("indirizzo"));
        s.setCap(rs.getString("cap"));
        s.setNumeroCivico(rs.getString("numero_civico"));
        s.setCitta(rs.getString("citta"));
        s.setData(rs.getDate("data"));
        return s;
    }
    
 // Inserisce usando una Connection esistente (stessa transazione)
    public int insert(Connection con, SpedizioneBean s) throws SQLException {
        String sql = "INSERT INTO spedizione (indirizzo, cap, numero_civico, citta, data) VALUES (?,?,?,?,?)";
        try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, s.getIndirizzo());
            ps.setString(2, s.getCap());
            ps.setString(3, s.getNumeroCivico());
            ps.setString(4, s.getCitta());
            ps.setDate(5, s.getData());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) return keys.getInt(1);
                }
            }
        }
        return -1; // errore
    }

}
