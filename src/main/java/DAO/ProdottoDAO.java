package DAO;

import model.ProdottoBean;
import model.ConnectionDatabase;

import java.sql.*;
import java.util.*;

public class ProdottoDAO {

    // ===============================
    // Utility per mappare ResultSet -> Bean
    // ===============================
    private ProdottoBean mapRow(ResultSet rs) throws SQLException {
        ProdottoBean p = new ProdottoBean();
        p.setId(rs.getInt("id"));
        p.setNome(rs.getString("nome"));
        p.setDescrizione(rs.getString("descrizione"));
        p.setTipo(rs.getString("tipo"));
        p.setCosto(rs.getDouble("costo"));
        p.setIva(rs.getDouble("iva"));
        p.setTaglia(rs.getString("taglia"));
        p.setCategoria(rs.getString("categoria"));
        int unita = rs.getInt("unita_disponibili");
        p.setUnitaDisponibili(rs.wasNull() ? null : unita);
        p.setFoto(rs.getBytes("foto"));
        p.setAttivo(rs.getBoolean("attivo"));
        return p;
    }

    // ===============================
    // CRUD classico
    // ===============================

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

    public boolean insert(ProdottoBean p) throws Exception {
        String sql = "INSERT INTO prodotto " +
                     "(nome, descrizione, categoria, taglia, tipo, costo, iva, unita_disponibili, foto, attivo) " +
                     "VALUES (?,?,?,?,?,?,?,?,?,?)";

        try (Connection con = model.ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {

            
            ps.setString(1, p.getNome());
            ps.setString(2, p.getDescrizione());
            ps.setString(3, p.getCategoria());
            ps.setString(4, p.getTaglia());
            ps.setString(5, p.getTipo());
            ps.setDouble(6, p.getCosto());
            ps.setDouble(7, p.getIva());
            ps.setInt(8, p.getUnitaDisponibili());
            ps.setBytes(9, p.getFoto());
            ps.setBoolean(10, p.isAttivo());

            int upd = ps.executeUpdate();
            if (upd > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) p.setId(rs.getInt(1));
                }
                return true;
            }
            return false;
        }
    }

    
    private String normalizeTipo(String t){
        if (t == null) return "Replica";
        t = t.trim();
        if (t.equalsIgnoreCase("Authentic")) return "Authentic";
        return "Replica";
    }


    public boolean update(ProdottoBean p) {
        String sql = """
            UPDATE prodotto
            SET nome=?, descrizione=?, costo=?, iva=?, taglia=?, categoria=?, unita_disponibili=?, foto=?, attivo=?, tipo=?
            WHERE id=?
        """;

        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, p.getNome());
            ps.setString(2, p.getDescrizione());
            ps.setDouble(4, p.getCosto());
            ps.setDouble(5, p.getIva());
            ps.setString(6, p.getTaglia());
            ps.setString(7, p.getCategoria());
            ps.setInt(8, p.getUnitaDisponibili() != null ? p.getUnitaDisponibili() : 0);
            ps.setBytes(9, p.getFoto());
            ps.setBoolean(10, p.isAttivo());
            ps.setString(8, normalizeTipo(p.getTipo()));
            ps.setInt(11, p.getId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM prodotto WHERE id=?";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ===============================
    // Metodi per catalogo cliente
    // ===============================

    // tutte le varianti di un prodotto per nome
    public List<ProdottoBean> findByNome(String nome) {
        List<ProdottoBean> lista = new ArrayList<>();
        String sql = "SELECT * FROM prodotto WHERE attivo=1 AND nome=? ORDER BY FIELD(taglia,'S','M','L','XL')";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nome);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    // mappa taglie → stock
    public Map<String, Integer> findTaglieDisponibiliByNome(String nome) {
        Map<String, Integer> out = new LinkedHashMap<>();
        String sql = """
            SELECT taglia, SUM(unita_disponibili) AS stock
            FROM prodotto
            WHERE attivo=1 AND nome=?
            GROUP BY taglia
            ORDER BY FIELD(taglia,'S','M','L','XL')
        """;
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nome);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.put(rs.getString("taglia"), rs.getInt("stock"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return out;
    }

    // una variante rappresentativa per nome (per card catalogo)
    public ProdottoBean findFirstVariantByNome(String nome) {
        String sql = "SELECT * FROM prodotto WHERE attivo=1 AND nome=? ORDER BY id LIMIT 1";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, nome);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // foto per id (per servlet /image?id=...)
    public byte[] findFotoById(int id) {
        String sql = "SELECT foto FROM prodotto WHERE id=?";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBytes(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
 // ✅ Prezzo crescente
    public List<ProdottoBean> findAllOrderByPrezzoAsc() {
        return findAllWithOrder("ASC");
    }

    // ✅ Prezzo decrescente
    public List<ProdottoBean> findAllOrderByPrezzoDesc() {
        return findAllWithOrder("DESC");
    }

    // Helper privato
    private List<ProdottoBean> findAllWithOrder(String order) {
        List<ProdottoBean> lista = new ArrayList<>();
        String sql = "SELECT * FROM prodotto WHERE attivo=1 ORDER BY costo " + order;

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
    
 // ✅ Trova tutti i prodotti attivi filtrati per categoria
    public List<ProdottoBean> findAllByCategoria(String categoria) {
        List<ProdottoBean> lista = new ArrayList<>();
        String sql = "SELECT * FROM prodotto WHERE attivo=1 AND categoria=?";

        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, categoria);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapRow(rs));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    public Integer getStockById(int id) {
        String sql = "SELECT unita_disponibili FROM prodotto WHERE id=?";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean decrementStock(int id, int qty) {
        String sql = "UPDATE prodotto SET unita_disponibili = unita_disponibili - ? WHERE id=? AND unita_disponibili >= ?";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, qty);
            ps.setInt(2, id);
            ps.setInt(3, qty);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }


    public List<ProdottoBean> searchByNameOrCategory(String q, int limit) throws Exception {
        List<ProdottoBean> list = new java.util.ArrayList<>();
        String like = "%" + q + "%";

        String sql =
            "SELECT id, nome, descrizione, categoria, taglia, unita_disponibili, costo, iva, tipo" +
            "FROM prodotto " +
            "WHERE nome LIKE ? OR categoria LIKE ? " +
            "ORDER BY nome ASC " +
            "LIMIT ?";

        try (java.sql.Connection con = model.ConnectionDatabase.getConnection();
             java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setInt(3, Math.max(1, limit));
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    model.ProdottoBean p = new model.ProdottoBean();
                    p.setId(rs.getInt("id"));
                    p.setNome(rs.getString("nome"));
                    p.setDescrizione(rs.getString("descrizione"));
                    p.setCategoria(rs.getString("categoria"));
                    p.setTaglia(rs.getString("taglia"));
                    p.setUnitaDisponibili((Integer) rs.getObject("unita_disponibili"));
                    p.setCosto(rs.getDouble("costo"));
                    p.setIva(rs.getDouble("iva"));
                    p.setTipo(rs.getString("tipo"));
                    list.add(p);
                }
            }
        }
        return list;
    }

}
