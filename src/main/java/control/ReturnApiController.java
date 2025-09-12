package control;

import model.UtenteBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.sql.*;

@WebServlet("/api/reso")
public class ReturnApiController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding(StandardCharsets.UTF_8.name());
        resp.setContentType("application/json; charset=UTF-8");

        HttpSession s = req.getSession(false);
        UtenteBean u = (s == null) ? null : (UtenteBean) s.getAttribute("utente");
        if (u == null) { write(resp, 401, "{\"success\":false,\"error\":\"Non autenticato\"}"); return; }

        String ordineIdStr = req.getParameter("ordineId");
        Integer ordineId = null;
        try { ordineId = Integer.valueOf(ordineIdStr); } catch (Exception ignored) {}
        if (ordineId == null) { write(resp, 400, "{\"success\":false,\"error\":\"ordineId mancante\"}"); return; }

        try (Connection con = model.ConnectionDatabase.getConnection()) {
            // 1) sicurezza: l’ordine deve appartenere a questo utente
            Integer ownerId = null;
            try (PreparedStatement ps = con.prepareStatement("SELECT utente_id FROM ordine WHERE id=?")) {
                ps.setInt(1, ordineId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) ownerId = rs.getInt(1);
                }
            }
            if (ownerId == null || ownerId != u.getId()) {
                write(resp, 403, "{\"success\":false,\"error\":\"Accesso negato\"}");
                return;
            }

            // 2) prendi l’ultimo reso registrato per quell’ordine
            String sql = "SELECT id, motivo, stato, refund_amount, created_at, updated_at " +
                         "FROM reso WHERE ordine_id=? ORDER BY id DESC LIMIT 1";
            Integer id = null;
            String motivo = null, stato = null, created = null, updated = null;
            java.math.BigDecimal refund = null;

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, ordineId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        id      = rs.getInt("id");
                        motivo  = rs.getString("motivo");
                        stato   = rs.getString("stato");
                        refund  = rs.getBigDecimal("refund_amount");
                        Timestamp c = rs.getTimestamp("created_at");
                        Timestamp m = rs.getTimestamp("updated_at");
                        created = (c != null ? c.toString() : null);
                        updated = (m != null ? m.toString() : null);
                    }
                }
            }

            if (id == null) {
                write(resp, 404, "{\"success\":false,\"error\":\"Nessun reso trovato per questo ordine\"}");
                return;
            }

            String json = "{"
                    + "\"success\":true,"
                    + "\"data\":{"
                    + "\"id\":" + id + ","
                    + "\"ordineId\":" + ordineId + ","
                    + "\"motivo\":\"" + esc(motivo) + "\","
                    + "\"stato\":\"" + esc(stato) + "\","
                    + "\"refund\":" + (refund == null ? "null" : refund.toPlainString()) + ","
                    + "\"createdAt\":\"" + esc(created) + "\","
                    + "\"updatedAt\":\"" + esc(updated) + "\""
                    + "}"
                    + "}";
            write(resp, 200, json);

        } catch (Exception ex) {
            ex.printStackTrace();
            write(resp, 500, "{\"success\":false,\"error\":\"Errore interno\"}");
        }
    }

    private static void write(HttpServletResponse r, int code, String body) throws IOException {
        r.setStatus(code);
        try (PrintWriter out = r.getWriter()) { out.write(body); }
    }
    private static String esc(String s){
        if (s == null) return "";
        return s.replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n").replace("\r","");
    }
}
