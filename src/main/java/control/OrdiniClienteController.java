package control;

import model.UtenteBean;
import model.OrdineBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = {"/ordini"})
public class OrdiniClienteController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession s = req.getSession(false);
        if (s == null) { resp.sendRedirect(req.getContextPath()+"/login.jsp"); return; }
        UtenteBean u = (UtenteBean) s.getAttribute("utente");
        if (u == null) { resp.sendRedirect(req.getContextPath()+"/login.jsp"); return; }

        String order = req.getParameter("order");
        if (order == null) order = "dateDesc";
        String orderBy;
        switch (order) {
            case "dateAsc":   orderBy = "o.data_ordine ASC"; break;
            case "priceAsc":  orderBy = "(o.totale_spesa + o.totale_iva) ASC"; break;
            case "priceDesc": orderBy = "(o.totale_spesa + o.totale_iva) DESC"; break;
            default:          orderBy = "o.data_ordine DESC";
        }

        List<OrdineBean> ordini = new ArrayList<>();

        // LEFT JOIN con l’ultimo reso per ordine (identificato dal MAX(id) su quella tabella)
        String sql =
            "SELECT o.id, o.utente_id, o.spedizione_id, o.data_ordine, o.totale_spesa, o.totale_iva, o.stato, " +
            "       COALESCE(o.metodo_pagamento,'') AS metodo_pagamento, o.spedizione_stato, " +
            "       r.stato AS reso_stato " +
            "FROM ordine o " +
            "LEFT JOIN ( " +
            "   SELECT r1.ordine_id, r1.stato " +
            "   FROM reso r1 " +
            "   JOIN (SELECT ordine_id, MAX(id) AS max_id FROM reso GROUP BY ordine_id) t " +
            "     ON t.ordine_id = r1.ordine_id AND t.max_id = r1.id " +
            ") r ON r.ordine_id = o.id " +
            "WHERE o.utente_id=? " +
            "ORDER BY " + orderBy;

        try (Connection con = model.ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, u.getId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrdineBean ob = new OrdineBean();
                    ob.setId(rs.getInt("id"));
                    ob.setUtenteId(rs.getInt("utente_id"));
                    ob.setSpedizioneId((Integer) rs.getObject("spedizione_id"));
                    ob.setDataOrdine(rs.getTimestamp("data_ordine"));
                    ob.setTotaleSpesa(rs.getBigDecimal("totale_spesa"));
                    ob.setTotaleIva(rs.getBigDecimal("totale_iva"));
                    ob.setStato(rs.getString("stato"));

                    // opzionale: se OrdineBean ha il setter per metodoPagamento
                    try { ob.getClass().getMethod("setMetodoPagamento", String.class)
                            .invoke(ob, rs.getString("metodo_pagamento")); } catch(Exception ignore){}

                    // spedizione_stato passato come attribute separato (se non presente nel bean)
                    req.setAttribute("spedizione_stato_" + ob.getId(), rs.getString("spedizione_stato"));

                    // >>> nuovo: stato del reso (se esiste) per questo ordine
                    String resoStato = rs.getString("reso_stato"); // può essere null
                    req.setAttribute("reso_stato_" + ob.getId(), resoStato);

                    ordini.add(ob);
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
        
        try (Connection con = model.ConnectionDatabase.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement("SELECT ordine_id, id FROM fattura WHERE ordine_id IN (" +
                    ordini.stream().map(o->"?").reduce((a,b)->a+","+b).orElse("0") + ")")) {
                int i=1;
                for (model.OrdineBean o: ordini) ps.setInt(i++, o.getId());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int ordineId = rs.getInt("ordine_id");
                        int fattId   = rs.getInt("id");
                        req.setAttribute("fattura_id_" + ordineId, fattId);
                    }
                }
            }
        } catch (SQLException e) {
        	throw new ServletException(e);
		}

        req.setAttribute("ordini", ordini);
        req.setAttribute("order", order);
        req.getRequestDispatcher("/ordini.jsp").forward(req, resp);
    }
}
