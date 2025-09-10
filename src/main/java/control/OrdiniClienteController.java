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
        try (Connection con = model.ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(
               "SELECT o.id, o.utente_id, o.spedizione_id, o.data_ordine, o.totale_spesa, o.totale_iva, o.stato, " +
               "       COALESCE(o.metodo_pagamento,'') AS metodo_pagamento, o.spedizione_stato " +
               "FROM ordine o WHERE o.utente_id=? ORDER BY " + orderBy)) {
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
                    // se OrdineBean non ha il campo spedizioneStato, passalo come attribute separato
                    req.setAttribute("spedizione_stato_" + ob.getId(), rs.getString("spedizione_stato"));
                    // opzionale: se hai get/setMetodoPagamento sul bean
                    try { ob.getClass().getMethod("setMetodoPagamento", String.class).invoke(ob, rs.getString("metodo_pagamento")); } catch(Exception ignore){}
                    ordini.add(ob);
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        req.setAttribute("ordini", ordini);
        req.setAttribute("order", order);
        req.getRequestDispatcher("/ordini.jsp").forward(req, resp);
    }
}
