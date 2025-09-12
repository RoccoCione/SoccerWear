package control;

import DAO.FatturaDAO;
import model.FatturaBean;
import model.UtenteBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;

@WebServlet(urlPatterns = {
        "/fattura",          // GET: visualizza HTML fattura (cliente o admin)
        "/fattura/create"    // POST: genera fattura (cliente per proprio ordine PAGATO/CONSEGNATO, o admin)
})
public class FatturaController extends HttpServlet {

    private boolean isAdmin(HttpSession s){
        if (s == null) return false;
        UtenteBean u = (UtenteBean) s.getAttribute("utente");
        return (u != null && "admin".equalsIgnoreCase(u.getRuolo()));
    }

    private Integer currentUserId(HttpSession s){
        if (s == null) return null;
        UtenteBean u = (UtenteBean) s.getAttribute("utente");
        return (u != null) ? u.getId() : null;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession s = req.getSession(false);
        Integer ordineId = parseInt(req.getParameter("ordineId"));
        if (ordineId == null) { resp.sendError(400, "ordineId mancante"); return; }

        boolean admin = isAdmin(s);
        Integer uid = currentUserId(s);
        if (!admin && uid == null) { resp.sendRedirect(req.getContextPath()+"/login.jsp"); return; }

        try (Connection con = model.ConnectionDatabase.getConnection()) {
            // Sicurezza: l’ordine deve appartenere al cliente se non admin
            if (!admin) {
                try (PreparedStatement ps = con.prepareStatement("SELECT utente_id FROM ordine WHERE id=?")) {
                    ps.setInt(1, ordineId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next() || rs.getInt(1) != uid) { resp.sendError(403); return; }
                    }
                }
            }

            FatturaDAO dao = new FatturaDAO();
            FatturaBean f = dao.findByOrdineId(con, ordineId);
            if (f == null) {
                // Nessuna fattura: se vuoi reindirizzare a generazione automatica per admin:
                // resp.sendRedirect(req.getContextPath()+"/fattura/create?ordineId="+ordineId);
                resp.sendError(404, "Fattura non trovata");
                return;
            }

            // Per la view, recupero anche i dati ordine e utente
            String cliente = "-", metodo = "-", dataOrd = "-";
            BigDecimal totSpesa = f.getTotaleSpesa()==null?BigDecimal.ZERO:f.getTotaleSpesa();
            BigDecimal totIva   = f.getTotaleIva()==null?BigDecimal.ZERO:f.getTotaleIva();

            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT o.data_ordine, COALESCE(o.metodo_pagamento,'') AS metodo, u.nome AS cliente " +
                    "FROM ordine o JOIN utente u ON u.id=o.utente_id WHERE o.id=?")) {
                ps.setInt(1, ordineId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Timestamp d = rs.getTimestamp("data_ordine");
                        dataOrd = d == null ? "-" : d.toString();
                        metodo  = rs.getString("metodo");
                        cliente = rs.getString("cliente");
                    }
                }
            }

            req.setAttribute("fattura", f);
            req.setAttribute("ordineId", ordineId);
            req.setAttribute("dataOrdine", dataOrd);
            req.setAttribute("cliente", cliente);
            req.setAttribute("metodoPagamento", metodo);
            req.setAttribute("totaleLordo", totSpesa.add(totIva));
            req.getRequestDispatcher("/fattura.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession s = req.getSession(false);
        boolean admin = isAdmin(s);
        Integer uid = currentUserId(s);
        Integer ordineId = parseInt(req.getParameter("ordineId"));
        if (ordineId == null) { writeJson(resp, 400, "{\"success\":false,\"error\":\"ordineId mancante\"}"); return; }
        if (!admin && uid == null) { writeJson(resp, 401, "{\"success\":false,\"error\":\"Login richiesto\"}"); return; }

        try (Connection con = model.ConnectionDatabase.getConnection()) {
            // Permessi: cliente solo sul proprio ordine
            if (!admin) {
                try (PreparedStatement ps = con.prepareStatement("SELECT utente_id, stato FROM ordine WHERE id=?")) {
                    ps.setInt(1, ordineId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next() || rs.getInt("utente_id") != uid) {
                            writeJson(resp, 403, "{\"success\":false,\"error\":\"Non autorizzato\"}");
                            return;
                        }
                        // opzionale: consenti fattura solo se PAGATO o CONSEGNATO
                        String stato = rs.getString("stato");
                        if (stato == null || !(stato.equalsIgnoreCase("PAGATO") || stato.equalsIgnoreCase("CONSEGNATO"))) {
                            writeJson(resp, 409, "{\"success\":false,\"error\":\"Fattura disponibile dopo il pagamento\"}");
                            return;
                        }
                    }
                }
            }

            FatturaDAO dao = new FatturaDAO();
            FatturaBean f = dao.createIfAbsentForOrder(con, ordineId);
            writeJson(resp, 200, "{\"success\":true,\"fatturaId\":"+f.getId()+"}");
        } catch (Exception e) {
            e.printStackTrace();
            writeJson(resp, 500, "{\"success\":false,\"error\":\"Errore interno\"}");
        }
    }

    private static Integer parseInt(String s){
        try { return (s==null||s.isBlank())?null:Integer.valueOf(s.trim()); }
        catch(Exception e){ return null; }
    }
    private static void writeJson(HttpServletResponse resp, int code, String json) throws IOException {
        resp.setStatus(code); resp.setContentType("application/json; charset=UTF-8"); resp.getWriter().write(json);
    }
}
