package DAO;

import model.ProdottoBean;
import model.ConnectionDatabase;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProdottoDAO {

    // ✅ Mappa una riga del ResultSet in un ProdottoBean
    private ProdottoBean mapRow(ResultSet rs) throws SQLException {
        ProdottoBean p = new ProdottoBean();
        p.setId(rs.getInt("id"));
        p.setNome(rs.getString("nome"));
        p.setDescrizione(rs.getString("descrizione"));
        int numero = rs.getInt("numero_maglia");
        p.setNumeroMaglia(rs.wasNull() ? null : numero);
        p.setCosto(rs.getDouble("costo"));
        p.setIva(rs.getDouble("iva"));
        p.setTaglia(rs.getString("taglia"));
        p.setCategoria(rs.getString("categoria"));
        p.setUnitaDisponibili(rs.getInt("unita_disponibili"));
        p.setFoto(rs.getBytes("foto"));
        p.setAttivo(rs.getBoolean("attivo"));
        return p;
    }

    // ✅ Recupera tutti i prodotti attivi
    public List<ProdottoBean> findAll() {
        List<ProdottoBean> lista = new ArrayList<>();
        String sql = "SELECT * FROM prodotto WHERE attivo=1 ORDER BY updated_at DESC";

        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(mapRow(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    // ✅ Trova prodotto per ID
    public ProdottoBean findById(int id) {
        String sql = "SELECT * FROM prodotto WHERE id=?";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ✅ Inserisce nuovo prodotto
    public boolean insert(ProdottoBean p) {
        String sql = "INSERT INTO prodotto (nome, descrizione, numero_maglia, costo, iva, taglia, categoria, unita_disponibili, foto, attivo) VALUES (?,?,?,?,?,?,?,?,?,?)";

        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, p.getNome());
            ps.setString(2, p.getDescrizione());
            if (p.getNumeroMaglia() != null) ps.setInt(3, p.getNumeroMaglia()); else ps.setNull(3, Types.INTEGER);
            ps.setDouble(4, p.getCosto());
            ps.setDouble(5, p.getIva());
            ps.setString(6, p.getTaglia());
            ps.setString(7, p.getCategoria());
            ps.setInt(8, p.getUnitaDisponibili() != null ? p.getUnitaDisponibili() : 0);
            ps.setBytes(9, p.getFoto());
            ps.setBoolean(10, p.isAttivo());

            int rows = ps.executeUpdate();

            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) p.setId(keys.getInt(1));
                }
                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ Aggiorna un prodotto
    public boolean update(ProdottoBean p) {
        String sql = "UPDATE prodotto SET nome=?, descrizione=?, numero_maglia=?, costo=?, iva=?, taglia=?, categoria=?, unita_disponibili=?, foto=?, attivo=? WHERE id=?";

        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, p.getNome());
            ps.setString(2, p.getDescrizione());
            if (p.getNumeroMaglia() != null) ps.setInt(3, p.getNumeroMaglia()); else ps.setNull(3, Types.INTEGER);
            ps.setDouble(4, p.getCosto());
            ps.setDouble(5, p.getIva());
            ps.setString(6, p.getTaglia());
            ps.setString(7, p.getCategoria());
            ps.setInt(8, p.getUnitaDisponibili() != null ? p.getUnitaDisponibili() : 0);
            ps.setBytes(9, p.getFoto());
            ps.setBoolean(10, p.isAttivo());
            ps.setInt(11, p.getId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ✅ Cancella un prodotto (soft delete → attivo=0)
    public boolean delete(int id) {
        String sql = "UPDATE prodotto SET attivo=0 WHERE id=?";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
