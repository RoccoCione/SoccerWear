package control;

import model.ConnectionDatabase;
import model.OrdineBean;
import model.UtenteBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/ordini")
public class OrdiniClienteController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Utente da sessione
        HttpSession session = request.getSession(false);
        if (session == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
        UtenteBean u = (UtenteBean) session.getAttribute("utente");
        if (u == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }

        // Ordina per: dateDesc (default) | dateAsc | priceDesc | priceAsc
        String order = request.getParameter("order");
        if (order == null || order.isBlank()) order = "dateDesc";

        String orderBy;
        switch (order) {
            case "dateAsc":   orderBy = "o.data_ordine ASC"; break;
            case "priceAsc":  orderBy = "(o.totale_spesa + o.totale_iva) ASC"; break;
            case "priceDesc": orderBy = "(o.totale_spesa + o.totale_iva) DESC"; break;
            default:          orderBy = "o.data_ordine DESC"; // dateDesc
        }

        List<OrdineBean> ordini = new ArrayList<>();
        String sql =
                "SELECT o.id, o.utente_id, o.spedizione_id, o.data_ordine, o.totale_spesa, o.totale_iva, o.stato " +
                "FROM ordine o " +
                "WHERE o.utente_id=? " +
                "ORDER BY " + orderBy;

        try (Connection con = ConnectionDatabase.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, u.getId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrdineBean o = new OrdineBean();
                    o.setId(rs.getInt("id"));
                    o.setUtenteId(rs.getInt("utente_id"));
                    o.setSpedizioneId((Integer) rs.getObject("spedizione_id"));
                    o.setDataOrdine(rs.getTimestamp("data_ordine"));
                    o.setTotaleSpesa(rs.getBigDecimal("totale_spesa"));
                    o.setTotaleIva(rs.getBigDecimal("totale_iva"));
                    o.setStato(rs.getString("stato"));
                    ordini.add(o);
                }
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        request.setAttribute("order", order);
        request.setAttribute("ordini", ordini);
        request.getRequestDispatcher("/ordini.jsp").forward(request, response);
    }
}
