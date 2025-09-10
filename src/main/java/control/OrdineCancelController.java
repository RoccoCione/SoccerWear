package control;

import model.UtenteBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet(urlPatterns = "/ordine/cancel")
public class OrdineCancelController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("utente") == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"success\":false,\"error\":\"Non autenticato.\"}");
            return;
        }
        UtenteBean u = (UtenteBean) s.getAttribute("utente");

        Integer ordineId;
        try {
            ordineId = Integer.valueOf(req.getParameter("id"));
        } catch (Exception e) {
            resp.setStatus(400);
            resp.getWriter().write("{\"success\":false,\"error\":\"Parametro id non valido.\"}");
            return;
        }

        try (Connection con = model.ConnectionDatabase.getConnection()) {
            con.setAutoCommit(false);

            Integer owner = null;
            String stato = null;
            String spedStato = null;

            // Blocca la riga per coerenza
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT utente_id, stato, spedizione_stato " +
                    "FROM ordine WHERE id=? FOR UPDATE")) {
                ps.setInt(1, ordineId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        owner = rs.getInt("utente_id");
                        // utente_id è NOT NULL in schema tipici, ma gestiamo comunque:
                        if (rs.wasNull()) owner = null;
                        stato = rs.getString("stato");
                        spedStato = rs.getString("spedizione_stato");
                    }
                }
            }

            if (owner == null) {
                con.rollback();
                resp.setStatus(404);
                resp.getWriter().write("{\"success\":false,\"error\":\"Ordine non trovato.\"}");
                return;
            }
            if (!owner.equals(u.getId())) {
                con.rollback();
                resp.setStatus(403);
                resp.getWriter().write("{\"success\":false,\"error\":\"Non autorizzato.\"}");
                return;
            }

            // Regola richiesta: annullabile SOLO se spedizione è IN_COSTRUZIONE
            if (spedStato == null || !spedStato.equalsIgnoreCase("IN_COSTRUZIONE")) {
                con.rollback();
                resp.setStatus(409);
                resp.getWriter().write("{\"success\":false,\"error\":\"Ordine non annullabile: spedizione non è in costruzione.\"}");
                return;
            }

            // (Opzionale) se vuoi evitare annullo quando è già ANNULLATO o CONSEGNATO
            if ("ANNULLATO".equalsIgnoreCase(stato) || "CONSEGNATO".equalsIgnoreCase(stato)) {
                con.rollback();
                resp.setStatus(409);
                resp.getWriter().write("{\"success\":false,\"error\":\"Ordine già concluso o annullato.\"}");
                return;
            }

            // Ripristina stock per righe con prodotto_id valorizzato
            try (PreparedStatement sel = con.prepareStatement(
                        "SELECT prodotto_id, quantita FROM riga_ordine WHERE ordine_id=?");
                 PreparedStatement upd = con.prepareStatement(
                        "UPDATE prodotto SET unita_disponibili = unita_disponibili + ? WHERE id=?")) {
                sel.setInt(1, ordineId);
                try (ResultSet rs = sel.executeQuery()) {
                    while (rs.next()) {
                        Integer prodId = (Integer) rs.getObject("prodotto_id");
                        int q = rs.getInt("quantita");
                        if (prodId != null) {
                            upd.setInt(1, q);
                            upd.setInt(2, prodId);
                            upd.executeUpdate();
                        }
                    }
                }
            }

            // Stato ordine -> ANNULLATO
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE ordine SET stato='ANNULLATO' WHERE id=?")) {
                ps.setInt(1, ordineId);
                ps.executeUpdate();
            }

            // Pagamento (mock) -> RIMBORSATO
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE pagamento SET esito='RIMBORSATO' WHERE ordine_id=?")) {
                ps.setInt(1, ordineId);
                ps.executeUpdate();
            }

            con.commit();

            try (PrintWriter out = resp.getWriter()) {
                out.write("{\"success\":true}");
            }

        } catch (SQLSyntaxErrorException sx) {
            // Tipico se la colonna 'spedizione_stato' non esiste
            resp.setStatus(500);
            resp.getWriter().write("{\"success\":false,\"error\":\"Colonna o tabella mancante. Verifica la migrazione SQL.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"success\":false,\"error\":\"Errore interno del server.\"}");
        }
    }
}
