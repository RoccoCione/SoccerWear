package control;

import model.UtenteBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = {
        "/admin/ordini",            // GET: lista + filtri (JSP)
        "/admin/ordine",            // GET: dettaglio JSON per modale
        "/admin/ordini/spedizione", // POST: update spedizione_stato
        "/admin/reso",              // GET: dettaglio reso per ordine (JSON)
        "/admin/reso/update"        // POST: aggiorna stato/note/refund del reso
})
public class AdminOrdiniController extends HttpServlet {

    public static class OrdineAdminRow {
        public int id;
        public Timestamp dataOrdine;
        public String stato;
        public BigDecimal totaleSpesa;
        public BigDecimal totaleIva;
        public String metodoPagamento;
        public String clienteNome;
        public String spedizioneStato;
        public boolean resoRichiesto; // TRUE se esiste un reso in stato RICHIESTO
    }

    // ---------- GET ----------
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession s = req.getSession(false);
        UtenteBean u = s == null ? null : (UtenteBean) s.getAttribute("utente");
        boolean isAdmin = (u != null && "admin".equalsIgnoreCase(u.getRuolo()));
        if (!isAdmin) { resp.sendError(403); return; }

        String path = req.getServletPath();

        try (Connection con = model.ConnectionDatabase.getConnection()) {

            if ("/admin/ordini".equals(path)) {
                String order   = nn(req.getParameter("order")); if (order == null) order = "dateDesc";
                String stato   = nn(req.getParameter("stato"));
                String pay     = nn(req.getParameter("pay"));
                String fromStr = nn(req.getParameter("from"));
                String toStr   = nn(req.getParameter("to"));
                String cliente = nn(req.getParameter("cliente"));

                Timestamp fromTs = null, toTs = null;
                try {
                    if (fromStr != null) fromTs = Timestamp.valueOf(fromStr + " 00:00:00");
                    if (toStr   != null) toTs   = Timestamp.valueOf(toStr   + " 23:59:59");
                } catch (IllegalArgumentException ignored) {}

                StringBuilder sql = new StringBuilder(
                        "SELECT o.id, o.data_ordine, o.stato, o.totale_spesa, o.totale_iva, " +
                        "       COALESCE(o.metodo_pagamento,'') AS metodo_pagamento, " +
                        "       COALESCE(o.spedizione_stato,'IN_ELABORAZIONE') AS spedizione_stato, " +
                        "       u.nome AS cliente_nome, " +
                        "       COALESCE(rr.richiesto, 0) AS reso_richiesto " +
                        "FROM ordine o " +
                        "JOIN utente u ON u.id = o.utente_id " +
                        "LEFT JOIN ( " +
                        "  SELECT ordine_id, MAX(CASE WHEN stato = 'RICHIESTO' THEN 1 ELSE 0 END) AS richiesto " +
                        "  FROM reso GROUP BY ordine_id " +
                        ") rr ON rr.ordine_id = o.id "
                );

                StringBuilder where = new StringBuilder("WHERE 1=1 ");
                List<Object> params = new ArrayList<>();

                if (stato != null) {
                    where.append(" AND o.spedizione_stato = ? ");
                    params.add(stato);
                }
                if (pay != null) {
                    switch (pay.toUpperCase()) {
                        case "CARTA":
                            where.append(" AND o.metodo_pagamento LIKE ? "); params.add("Carta%"); break;
                        case "PAYPAL":
                            where.append(" AND o.metodo_pagamento LIKE ? "); params.add("PayPal%"); break;
                        case "COD":
                            where.append(" AND o.metodo_pagamento LIKE ? "); params.add("Pagamento alla consegna%"); break;
                        default: // ignora
                    }
                }
                if (fromTs != null) { where.append(" AND o.data_ordine >= ? "); params.add(fromTs); }
                if (toTs   != null) { where.append(" AND o.data_ordine <= ? "); params.add(toTs); }

                if (cliente != null) {
                    where.append(" AND (u.nome LIKE ? OR u.username LIKE ? OR u.email LIKE ?) ");
                    String like = "%" + cliente + "%";
                    params.add(like); params.add(like); params.add(like);
                }

                sql.append(where);
                sql.append(" ORDER BY ");
                switch (order) {
                    case "dateAsc":   sql.append("o.data_ordine ASC"); break;
                    case "priceDesc": sql.append("(o.totale_spesa + o.totale_iva) DESC"); break;
                    case "priceAsc":  sql.append("(o.totale_spesa + o.totale_iva) ASC");  break;
                    default:          sql.append("o.data_ordine DESC");
                }

                List<OrdineAdminRow> list = new ArrayList<>();
                try (PreparedStatement ps = con.prepareStatement(sql.toString())) {
                    for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            OrdineAdminRow r = new OrdineAdminRow();
                            r.id = rs.getInt("id");
                            r.dataOrdine = rs.getTimestamp("data_ordine");
                            r.stato = rs.getString("stato");
                            r.totaleSpesa = rs.getBigDecimal("totale_spesa");
                            r.totaleIva = rs.getBigDecimal("totale_iva");
                            r.metodoPagamento = rs.getString("metodo_pagamento");
                            r.clienteNome = rs.getString("cliente_nome");
                            r.spedizioneStato = rs.getString("spedizione_stato");
                            r.resoRichiesto = rs.getInt("reso_richiesto") == 1;
                            list.add(r);
                        }
                    }
                }

                req.setAttribute("ordini", list);
                req.setAttribute("order", order);
                req.setAttribute("stato", stato);
                req.setAttribute("pay",   pay);
                req.setAttribute("from",  fromStr);
                req.setAttribute("to",    toStr);
                req.setAttribute("cliente", cliente);

                req.getRequestDispatcher("/gestioneordini.jsp").forward(req, resp);
                return;
            }

            if ("/admin/ordine".equals(path)) {
                int id = Integer.parseInt(req.getParameter("id"));

                String sqlOrd = "SELECT o.id, o.data_ordine, o.stato, o.totale_spesa, o.totale_iva, " +
                        "COALESCE(o.metodo_pagamento,'') AS metodo_pagamento, " +
                        "COALESCE(o.spedizione_stato,'IN_ELABORAZIONE') AS spedizione_stato, " +
                        "u.nome AS cliente_nome, o.spedizione_id " +
                        "FROM ordine o JOIN utente u ON u.id=o.utente_id WHERE o.id=?";
                Integer spedId = null;
                Integer oid = null; String statoOrd = null, metodo = null, clienteNome = null, spedStato = null;
                Timestamp dataOrd = null; BigDecimal tNet = null, tIva = null;

                try (PreparedStatement ps = con.prepareStatement(sqlOrd)) {
                    ps.setInt(1, id);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            oid = rs.getInt("id");
                            dataOrd = rs.getTimestamp("data_ordine");
                            statoOrd = rs.getString("stato");
                            tNet = rs.getBigDecimal("totale_spesa");
                            tIva = rs.getBigDecimal("totale_iva");
                            metodo = rs.getString("metodo_pagamento");
                            clienteNome = rs.getString("cliente_nome");
                            spedStato = rs.getString("spedizione_stato");
                            Object oSp = rs.getObject("spedizione_id");
                            if (oSp != null) spedId = ((Number)oSp).intValue();
                        }
                    }
                }
                if (oid == null) { resp.sendError(404); return; }

                List<String> righeJson = new ArrayList<>();
                try (PreparedStatement ps = con.prepareStatement(
                        "SELECT nome_prodotto, taglia, prezzo_unitario, quantita, totale_riga " +
                        "FROM riga_ordine WHERE ordine_id=?")) {
                    ps.setInt(1, oid);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            String nome = esc(rs.getString("nome_prodotto"));
                            String taglia = esc(rs.getString("taglia"));
                            BigDecimal prezzo = rs.getBigDecimal("prezzo_unitario");
                            int q = rs.getInt("quantita");
                            BigDecimal tot = rs.getBigDecimal("totale_riga");
                            righeJson.add("{\"nome\":\""+nome+"\",\"taglia\":\""+taglia+"\",\"q\":"+q+",\"prezzo\":"+fmt(prezzo)+",\"totale\":"+fmt(tot)+"}");
                        }
                    }
                }

                String spedJson = "null";
                if (spedId != null) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "SELECT indirizzo, cap, numero_civico, citta, data FROM spedizione WHERE id=?")) {
                        ps.setInt(1, spedId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                String ind = esc(rs.getString("indirizzo"));
                                String cap = esc(rs.getString("cap"));
                                String civ = esc(rs.getString("numero_civico"));
                                String cit = esc(rs.getString("citta"));
                                Date d = rs.getDate("data");
                                spedJson = "{\"indirizzo\":\""+ind+"\",\"cap\":\""+cap+"\",\"numeroCivico\":\""+civ+"\",\"citta\":\""+cit+"\",\"data\":\""+(d!=null?d.toString():"")+"\"}";
                            }
                        }
                    }
                }

                resp.setContentType("application/json; charset=UTF-8");
                BigDecimal lordo = nz(tNet).add(nz(tIva));
                String json = "{"
                        + "\"id\":"+oid+","
                        + "\"dataOrdine\":\""+(dataOrd!=null?dataOrd.toString():"")+"\","
                        + "\"stato\":\""+esc(statoOrd)+"\","
                        + "\"totaleNetto\":"+fmt(tNet)+","
                        + "\"totaleIva\":"+fmt(tIva)+","
                        + "\"totaleLordo\":"+fmt(lordo)+","
                        + "\"metodoPagamento\":\""+esc(metodo)+"\","
                        + "\"cliente\":\""+esc(clienteNome)+"\","
                        + "\"spedizioneStato\":\""+esc(spedStato)+"\","
                        + "\"spedizione\":"+spedJson+","
                        + "\"righe\":["+String.join(",", righeJson)+"]"
                        + "}";
                try (PrintWriter out = resp.getWriter()) { out.print(json); }
                return;
            }

            if ("/admin/reso".equals(path)) {
                int ordineId = Integer.parseInt(req.getParameter("ordineId"));

                String sql = "SELECT id, ordine_id, utente_id, motivo, stato, refund_amount, note, created_at, updated_at " +
                             "FROM reso WHERE ordine_id=? ORDER BY id DESC LIMIT 1";
                Integer id = null, utenteId = null;
                String motivo = null, stato = null, note = null, created = null, updated = null;
                BigDecimal refund = null;

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, ordineId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            id = rs.getInt("id");
                            utenteId = rs.getInt("utente_id");
                            motivo = rs.getString("motivo");
                            stato = rs.getString("stato");
                            refund = rs.getBigDecimal("refund_amount");
                            note = rs.getString("note");
                            created = String.valueOf(rs.getTimestamp("created_at"));
                            updated = String.valueOf(rs.getTimestamp("updated_at"));
                        }
                    }
                }

                resp.setContentType("application/json; charset=UTF-8");
                if (id == null) {
                    resp.getWriter().write("{\"success\":false,\"error\":\"Nessun reso per questo ordine\"}");
                } else {
                    String json = "{"
                            + "\"success\":true,"
                            + "\"data\":{"
                            + "\"id\":"+id+","
                            + "\"ordineId\":"+ordineId+","
                            + "\"utenteId\":"+utenteId+","
                            + "\"motivo\":\""+esc(motivo)+"\","
                            + "\"stato\":\""+esc(stato)+"\","
                            + "\"refund\":"+(refund==null?"0":refund.toPlainString())+","
                            + "\"note\":\""+esc(note==null ? "" : note)+"\","
                            + "\"createdAt\":\""+esc(created)+"\","
                            + "\"updatedAt\":\""+esc(updated)+"\""
                            + "}"
                            + "}";
                    resp.getWriter().write(json);
                }
                return;
            }

            resp.sendError(404);
        } catch (NumberFormatException nfe) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"success\":false,\"error\":\"Parametro non valido\"}");
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ---------- POST ----------
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession s = req.getSession(false);
        UtenteBean u = s == null ? null : (UtenteBean) s.getAttribute("utente");
        boolean isAdmin = (u != null && "admin".equalsIgnoreCase(u.getRuolo()));
        if (!isAdmin) { resp.sendError(403); return; }

        String path = req.getServletPath();

        if ("/admin/ordini/spedizione".equals(path)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                String stato = nn(req.getParameter("stato"));
                if (stato == null ||
                    !(stato.equals("IN_ELABORAZIONE") || stato.equals("IN_TRANSITO") || stato.equals("CONSEGNATO"))) {
                    writeJson(resp, 400, "{\"success\":false,\"error\":\"Stato non valido.\"}");
                    return;
                }

                int upd;
                try (Connection con = model.ConnectionDatabase.getConnection();
                     PreparedStatement ps = con.prepareStatement("UPDATE ordine SET spedizione_stato=? WHERE id=?")) {
                    ps.setString(1, stato);
                    ps.setInt(2, id);
                    upd = ps.executeUpdate();
                }
                if (upd == 0) writeJson(resp, 404, "{\"success\":false,\"error\":\"Ordine non trovato.\"}");
                else writeJson(resp, 200, "{\"success\":true}");
                return;

            } catch (NumberFormatException nfe) {
                writeJson(resp, 400, "{\"success\":false,\"error\":\"id non valido.\"}");
            } catch (Exception ex) {
                ex.printStackTrace();
                writeJson(resp, 500, "{\"success\":false,\"error\":\"Errore interno.\"}");
            }
            return;
        }

        if ("/admin/reso/update".equals(path)) {
            try (Connection con = model.ConnectionDatabase.getConnection()) {
                int ordineId    = Integer.parseInt(req.getParameter("ordineId"));
                String stato    = nn(req.getParameter("stato"));
                String note     = req.getParameter("note");
                String refund   = nn(req.getParameter("refund_amount"));

                if (stato == null) { writeJson(resp, 400, "{\"success\":false,\"error\":\"Stato mancante\"}"); return; }

                Integer resoId = null;
                try (PreparedStatement ps = con.prepareStatement("SELECT id FROM reso WHERE ordine_id=? ORDER BY id DESC LIMIT 1")) {
                    ps.setInt(1, ordineId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) resoId = rs.getInt(1);
                    }
                }
                if (resoId == null) { writeJson(resp, 404, "{\"success\":false,\"error\":\"Reso non trovato\"}"); return; }

                String sql = "UPDATE reso SET stato=?, note=?, updated_at=CURRENT_TIMESTAMP"
                           + (refund != null ? ", refund_amount=?" : "")
                           + " WHERE id=?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    int ix = 1;
                    ps.setString(ix++, stato);
                    ps.setString(ix++, (note==null? null : note));
                    if (refund != null) ps.setBigDecimal(ix++, new java.math.BigDecimal(refund.replace(',', '.')));
                    ps.setInt(ix, resoId);
                    ps.executeUpdate();
                }

                writeJson(resp, 200, "{\"success\":true}");
                return;

            } catch (NumberFormatException nfe) {
                writeJson(resp, 400, "{\"success\":false,\"error\":\"Parametri non validi\"}");
            } catch (Exception ex) {
                ex.printStackTrace();
                writeJson(resp, 500, "{\"success\":false,\"error\":\"Errore interno\"}");
            }
        } else {
            resp.sendError(404);
        }
    }

    // ---- helpers ----
    private static String nn(String s){ if (s==null) return null; s=s.trim(); return s.isEmpty()?null:s; }
    private static String esc(String s){
        if (s==null) return "";
        return s.replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n").replace("\r","");
    }
    private static String fmt(BigDecimal b){ return (b==null? "0" : b.toPlainString()); }
    private static BigDecimal nz(BigDecimal b){ return b==null? java.math.BigDecimal.ZERO : b; }
    private static void writeJson(HttpServletResponse resp, int code, String json) throws IOException {
        resp.setStatus(code); resp.setContentType("application/json; charset=UTF-8"); resp.getWriter().write(json);
    }
}
