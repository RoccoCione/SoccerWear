package DAO;

import model.ProdottoBean;
import model.ConnectionDatabase;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProdottoDAO {

    // Restituisce tutti i prodotti
    public List<ProdottoBean> findAll() {
        String sql = "SELECT codice, nome_maglia, numero_maglia, costo, iva, taglia, categoria, squadra, foto FROM maglietta";
        List<ProdottoBean> prodotti = new ArrayList<>();

        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                ProdottoBean p = new ProdottoBean();
                p.setCodice(rs.getInt("codice"));
                p.setNome(rs.getString("nome_maglia"));
                p.setNumeroMaglia(rs.getInt("numero_maglia"));
                p.setCosto(rs.getBigDecimal("costo"));
                p.setIva(rs.getBigDecimal("iva"));
                p.setTaglia(rs.getString("taglia"));
                p.setCategoria(rs.getString("categoria"));
                p.setSquadra(rs.getString("squadra"));
                p.setFoto(rs.getBytes("foto")); // opzionale: puoi caricare da file system invece
                prodotti.add(p);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return prodotti;
    }

    // Restituisce un singolo prodotto
    public ProdottoBean findById(int codice) {
        String sql = "SELECT * FROM maglietta WHERE codice=?";
        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, codice);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ProdottoBean p = new ProdottoBean();
                    p.setCodice(rs.getInt("codice"));
                    p.setNome(rs.getString("nome_maglia"));
                    p.setNumeroMaglia(rs.getInt("numero_maglia"));
                    p.setCosto(rs.getBigDecimal("costo"));
                    p.setIva(rs.getBigDecimal("iva"));
                    p.setTaglia(rs.getString("taglia"));
                    p.setCategoria(rs.getString("categoria"));
                    p.setSquadra(rs.getString("squadra"));
                    p.setFoto(rs.getBytes("foto"));
                    return p;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
