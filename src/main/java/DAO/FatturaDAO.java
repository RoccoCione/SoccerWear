package DAO;

import model.FatturaBean;
import java.sql.*;
import java.math.BigDecimal;

public class FatturaDAO {

    private static FatturaBean mapRow(ResultSet rs) throws SQLException {
        FatturaBean f = new FatturaBean();
        f.setId(rs.getInt("id"));
        f.setOrdineId(rs.getInt("ordine_id"));
        f.setDataEmissione(rs.getTimestamp("data_emissione"));
        f.setTotaleSpesa(rs.getBigDecimal("totale_spesa"));
        f.setTotaleIva(rs.getBigDecimal("totale_iva"));
        return f;
    }

    public FatturaBean findById(Connection con, int id) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT id, ordine_id, data_emissione, totale_spesa, totale_iva FROM fattura WHERE id=?")) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    public FatturaBean findByOrdineId(Connection con, int ordineId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT id, ordine_id, data_emissione, totale_spesa, totale_iva FROM fattura WHERE ordine_id=?")) {
            ps.setInt(1, ordineId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    /** Crea fattura per l'ordine (se non esiste) usando i totali dell’ordine. Ritorna la fattura esistente/creata. */
    public FatturaBean createIfAbsentForOrder(Connection con, int ordineId) throws SQLException {
        FatturaBean existing = findByOrdineId(con, ordineId);
        if (existing != null) return existing;

        BigDecimal spesa = BigDecimal.ZERO, iva = BigDecimal.ZERO;
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT totale_spesa, totale_iva FROM ordine WHERE id=?")) {
            ps.setInt(1, ordineId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new SQLException("Ordine non trovato");
                spesa = rs.getBigDecimal("totale_spesa");
                iva   = rs.getBigDecimal("totale_iva");
            }
        }

        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO fattura (ordine_id, totale_spesa, totale_iva) VALUES (?,?,?)",
                Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, ordineId);
            ps.setBigDecimal(2, spesa);
            ps.setBigDecimal(3, iva);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int id = rs.getInt(1);
                    return findById(con, id);
                }
            }
        }
        // Se non ci sono generated keys (alcune configurazioni), rileggi per ordine_id
        return findByOrdineId(con, ordineId);
    }
}
