package control;

import model.ConnectionDatabase;
import model.UtenteBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/api/order")
public class OrdineApiController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding(StandardCharsets.UTF_8.name());
        resp.setContentType("application/json; charset=UTF-8");

        // Auth
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("utente") == null) {
            writeJson(resp, 401, jsonError("Non autenticato."));
            return;
        }
        UtenteBean u = (UtenteBean) session.getAttribute("utente");

        String idStr = trimOrNull(req.getParameter("id"));
        if (idStr == null) {
            writeJson(resp, 400, jsonError("Parametro mancante: specifica ?id=..."));
            return;
        }

        try (Connection con = ConnectionDatabase.getConnection()) {
            int ordineId;
            try { ordineId = Integer.parseInt(idStr); }
            catch (NumberFormatException nfe) {
                writeJson(resp, 400, jsonError("Parametro id non valido."));
                return;
            }

            // ===== Ordine (solo se appartiene all’utente) =====
            Integer spedId = null;
            Timestamp dataOrdine = null;
            String stato = null;
            BigDecimal totNetto = null, totIva = null;
            String metodoPagamento = null; // opzionale, se lo salvi su colonna ordine.metodo_pagamento

            String sqlOrdine =
                "SELECT id, utente_id, spedizione_id, data_ordine, totale_spesa, totale_iva, stato, " +
                "       COALESCE(metodo_pagamento,'') AS metodo_pagamento " +
                "FROM ordine WHERE id=? AND utente_id=?";

            try (PreparedStatement ps = con.prepareStatement(sqlOrdine)) {
                ps.setInt(1, ordineId);
                ps.setInt(2, u.getId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        writeJson(resp, 404, jsonError("Ordine non trovato."));
                        return;
                    }
                    spedId          = (Integer) rs.getObject("spedizione_id");
                    dataOrdine      = rs.getTimestamp("data_ordine");
                    stato           = rs.getString("stato");
                    totNetto        = rs.getBigDecimal("totale_spesa");
                    totIva          = rs.getBigDecimal("totale_iva");
                    metodoPagamento = rs.getString("metodo_pagamento");
                }
            }

            // ===== Righe =====
            List<Row> righe = new ArrayList<>();
            String sqlRighe =
                "SELECT nome_prodotto, taglia, prezzo_unitario, quantita, totale_riga " +
                "FROM riga_ordine WHERE ordine_id=?";
            try (PreparedStatement ps = con.prepareStatement(sqlRighe)) {
                ps.setInt(1, ordineId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Row r = new Row();
                        r.nome   = rs.getString("nome_prodotto");
                        r.taglia = rs.getString("taglia");
                        r.prezzo = rs.getBigDecimal("prezzo_unitario");
                        r.q      = rs.getInt("quantita");
                        r.totale = rs.getBigDecimal("totale_riga");
                        righe.add(r);
                    }
                }
            }

            // ===== Spedizione =====
            Sped sDto = null;
            if (spedId != null) {
                String sqlSped = "SELECT indirizzo, cap, numero_civico, citta, data FROM spedizione WHERE id=?";
                try (PreparedStatement ps = con.prepareStatement(sqlSped)) {
                    ps.setInt(1, spedId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            sDto = new Sped();
                            sDto.indirizzo    = rs.getString("indirizzo");
                            sDto.cap          = rs.getString("cap");
                            sDto.numeroCivico = rs.getString("numero_civico");
                            sDto.citta        = rs.getString("citta");
                            Date d            = rs.getDate("data");
                            sDto.data         = (d != null ? d.toString() : null);
                        }
                    }
                }
            }

            // ===== JSON success =====
            BigDecimal lordo = safe(totNetto).add(safe(totIva));
            String json = buildOrderJson(
                    ordineId,
                    dataOrdine,
                    stato,
                    lordo,
                    metodoPagamento,
                    sDto,
                    righe
            );
            writeJson(resp, 200, json);

        } catch (Exception ex) {
            ex.printStackTrace();
            writeJson(resp, 500, jsonError("Errore interno: " + ex.getMessage()));
        }
    }

    // ================= Helpers =================

    private static String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private static void writeJson(HttpServletResponse resp, int status, String json) throws IOException {
        resp.setStatus(status);
        try (PrintWriter out = resp.getWriter()) { out.write(json); }
    }

    private static String jsonError(String msg) {
        return "{\"success\":false,\"error\":\"" + jsonEscape(msg) + "\"}";
    }

    private static String buildOrderJson(int id,
                                         Timestamp dataOrdine,
                                         String stato,
                                         BigDecimal totaleLordo,
                                         String metodoPagamento,
                                         Sped sped,
                                         List<Row> righe) {

        StringBuilder sb = new StringBuilder(512);
        sb.append("{\"success\":true,\"data\":{");
        sb.append("\"id\":").append(id).append(",");
        sb.append("\"dataOrdine\":\"").append(jsonEscape(tsIso(dataOrdine))).append("\",");
        sb.append("\"stato\":\"").append(jsonEscape(nullToEmpty(stato))).append("\",");

        // numeri come numeri (US decimal point)
        sb.append("\"totaleLordo\":").append(num(totaleLordo)).append(",");

        // metodo pagamento (opzionale, stringa)
        sb.append("\"metodoPagamento\":\"").append(jsonEscape(nullToEmpty(metodoPagamento))).append("\",");

        // spedizione
        sb.append("\"spedizione\":");
        if (sped != null) {
            sb.append("{")
              .append("\"indirizzo\":\"").append(jsonEscape(nullToEmpty(sped.indirizzo))).append("\",")
              .append("\"cap\":\"").append(jsonEscape(nullToEmpty(sped.cap))).append("\",")
              .append("\"numeroCivico\":\"").append(jsonEscape(nullToEmpty(sped.numeroCivico))).append("\",")
              .append("\"citta\":\"").append(jsonEscape(nullToEmpty(sped.citta))).append("\",")
              .append("\"data\":\"").append(jsonEscape(nullToEmpty(sped.data))).append("\"")
              .append("}");
        } else {
            sb.append("null");
        }
        sb.append(",");

        // righe
        sb.append("\"righe\":[");
        if (righe != null && !righe.isEmpty()) {
            for (int i = 0; i < righe.size(); i++) {
                Row r = righe.get(i);
                sb.append("{")
                  .append("\"nome\":\"").append(jsonEscape(nullToEmpty(r.nome))).append("\",")
                  .append("\"taglia\":\"").append(jsonEscape(nullToEmpty(r.taglia))).append("\",")
                  .append("\"q\":").append(r.q).append(",")
                  .append("\"prezzo\":").append(num(r.prezzo)).append(",")
                  .append("\"totale\":").append(num(r.totale))
                  .append("}");
                if (i < righe.size() - 1) sb.append(",");
            }
        }
        sb.append("]");

        sb.append("}}");
        return sb.toString();
    }

    private static String tsIso(Timestamp ts) {
        if (ts == null) return "";
        // formato semplice compatibile con JS Date (YYYY-MM-DDTHH:mm:ss)
        return ts.toString().replace(' ', 'T');
    }

    private static String nullToEmpty(String s) { return s == null ? "" : s; }

    private static String jsonEscape(String s) {
        StringBuilder out = new StringBuilder(Math.max(16, s.length() + 16));
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"':  out.append("\\\""); break;
                case '\\': out.append("\\\\"); break;
                case '\b': out.append("\\b");  break;
                case '\f': out.append("\\f");  break;
                case '\n': out.append("\\n");  break;
                case '\r': out.append("\\r");  break;
                case '\t': out.append("\\t");  break;
                default:
                    if (c < 0x20) out.append(String.format("\\u%04x", (int)c));
                    else out.append(c);
            }
        }
        return out.toString();
    }

    private static String num(BigDecimal b) {
        if (b == null) return "0";
        return b.stripTrailingZeros().toPlainString();
    }

    private static BigDecimal safe(BigDecimal b) { return b == null ? BigDecimal.ZERO : b; }

    // DTO interni
    static class Row { String nome; String taglia; BigDecimal prezzo; int q; BigDecimal totale; }
    static class Sped { String indirizzo, cap, numeroCivico, citta, data; }
}
