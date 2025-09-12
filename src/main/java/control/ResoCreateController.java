package control;

import model.UtenteBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;

@WebServlet("/reso/create")
public class ResoCreateController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        HttpSession s = req.getSession(false);
        UtenteBean u = (s == null) ? null : (UtenteBean) s.getAttribute("utente");
        if (u == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"success\":false,\"error\":\"Non autenticato\"}");
            return;
        }

        String ordineIdStr = nn(req.getParameter("ordineId")); // ← NOME PARAMETRO atteso
        String motivo      = nn(req.getParameter("motivo"));

        // Validazioni minime chiare
        if (ordineIdStr == null || motivo == null) {
            resp.setStatus(400);
            resp.getWriter().write("{\"success\":false,\"error\":\"richiesta non valida: ordineId o motivo mancanti\"}");
            return;
        }

        int ordineId;
        try { ordineId = Integer.parseInt(ordineIdStr); }
        catch (NumberFormatException ex) {
            resp.setStatus(400);
            resp.getWriter().write("{\"success\":false,\"error\":\"ordineId non valido\"}");
            return;
        }

        // (opzionale) limiti su motivo
        if (motivo.length() > 500) motivo = motivo.substring(0, 500);

        try (Connection con = model.ConnectionDatabase.getConnection()) {
            // 1) Verifica che l'ordine esista e appartenga all’utente
            Integer ownerId = null;
            String statoOrd = null;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT utente_id, stato FROM ordine WHERE id=?")) {
                ps.setInt(1, ordineId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        ownerId = rs.getInt("utente_id");
                        statoOrd = rs.getString("stato");
                    }
                }
            }
            if (ownerId == null || ownerId != u.getId()) {
                resp.setStatus(403);
                resp.getWriter().write("{\"success\":false,\"error\":\"Ordine non trovato o non tuo\"}");
                return;
            }

            // (facoltativo) consenti reso solo se consegnato
            // if (!"CONSEGNATO".equalsIgnoreCase(statoOrd)) { ... }

            // 2) Inserisci richiesta di reso (stato=RICHIESTO), uno per ordine se vuoi evitare duplicati
            // (Se vuoi bloccare multipli: controlla che non esista già un reso RICHIESTO/APERTO)
            Integer existingId = null;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT id FROM reso WHERE ordine_id=? AND stato IN ('RICHIESTO','RICEVUTO','APPROVATO') ORDER BY id DESC LIMIT 1")) {
                ps.setInt(1, ordineId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) existingId = rs.getInt(1);
                }
            }
            if (existingId != null) {
                resp.setStatus(409);
                resp.getWriter().write("{\"success\":false,\"error\":\"Esiste già una pratica di reso per questo ordine\"}");
                return;
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO reso (ordine_id, utente_id, motivo, stato, refund_amount, note, created_at, updated_at) " +
                    "VALUES (?,?,?,?,?,?,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP)")) {
                ps.setInt(1, ordineId);
                ps.setInt(2, u.getId());
                ps.setString(3, motivo);
                ps.setString(4, "RICHIESTO");
                ps.setBigDecimal(5, BigDecimal.ZERO);  // default 0
                ps.setString(6, null); // note inizialmente null
                ps.executeUpdate();
            }

            resp.getWriter().write("{\"success\":true}");
        } catch (Exception ex) {
            ex.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"success\":false,\"error\":\"Errore interno\"}");
        }
    }

    private static String nn(String s){
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }
}
