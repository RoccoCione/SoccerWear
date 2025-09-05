package control;

import DAO.ProdottoDAO;
import model.ProdottoBean;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.*;

@WebServlet("/api/product")
public class ProductApiController extends HttpServlet {

    private ProdottoDAO prodottoDAO;

    @Override
    public void init() throws ServletException {
        prodottoDAO = new ProdottoDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding(StandardCharsets.UTF_8.name());
        resp.setContentType("application/json; charset=UTF-8");

        String nome = trimOrNull(req.getParameter("nome"));
        String idStr = trimOrNull(req.getParameter("id"));

        try {
            // 1) Se c'è "nome", usiamo il gruppo varianti per nome
            if (nome != null) {
                ProdottoBean representative = prodottoDAO.findFirstVariantByNome(nome);
                if (representative == null) {
                    writeJson(resp, 404, jsonError("Prodotto non trovato per nome: " + nome));
                    return;
                }
                Map<String, Integer> taglieStock = prodottoDAO.findTaglieDisponibiliByNome(nome);

                String imageUrl = representative.getId() > 0
                        ? req.getContextPath() + "/image?id=" + representative.getId()
                        : null;

                String json = buildProductJson(
                        representative.getNome(),
                        representative.getDescrizione(),
                        representative.getCategoria(),
                        representative.getCosto(),
                        representative.getIva(),
                        taglieStock,
                        imageUrl
                );
                writeJson(resp, 200, json);
                return;
            }

            // 2) Fallback: se non c'è nome ma c'è id, carica la singola variante
            if (idStr != null) {
                int id = Integer.parseInt(idStr);
                ProdottoBean p = prodottoDAO.findById(id);
                if (p == null || !p.isAttivo()) {
                    writeJson(resp, 404, jsonError("Prodotto non trovato per id: " + id));
                    return;
                }
                // Mappa taglie solo per lo stesso nome
                Map<String, Integer> taglieStock = prodottoDAO.findTaglieDisponibiliByNome(p.getNome());
                String imageUrl = req.getContextPath() + "/image?id=" + p.getId();

                String json = buildProductJson(
                        p.getNome(),
                        p.getDescrizione(),
                        p.getCategoria(),
                        p.getCosto(),
                        p.getIva(),
                        taglieStock,
                        imageUrl
                );
                writeJson(resp, 200, json);
                return;
            }

            // 3) Nessun parametro valido
            writeJson(resp, 400, jsonError("Parametro mancante: specifica ?nome=... oppure ?id=..."));

        } catch (NumberFormatException nfe) {
            writeJson(resp, 400, jsonError("Parametro id non valido."));
        } catch (Exception ex) {
            ex.printStackTrace();
            writeJson(resp, 500, jsonError("Errore interno: " + ex.getMessage()));
        }
    }

    // ----------------- Helpers -----------------

    private static String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private static void writeJson(HttpServletResponse resp, int status, String json) throws IOException {
        resp.setStatus(status);
        resp.getWriter().write(json);
    }

    private static String jsonError(String msg) {
        return "{\"success\":false,\"error\":\"" + jsonEscape(msg) + "\"}";
    }

    /**
     * JSON “flat”:
     * {
     *   "success": true,
     *   "data": {
     *     "nome": "...",
     *     "descrizione": "...",
     *     "categoria": "...",
     *     "prezzo": 79.90,
     *     "iva": 22.00,
     *     "taglie": { "S": 5, "M": 0, "L": 3, "XL": 2 },
     *     "imageUrl": "/SoccerWear/image?id=123"
     *   }
     * }
     */
    private static String buildProductJson(String nome,
                                           String descrizione,
                                           String categoria,
                                           double prezzo,
                                           double iva,
                                           Map<String, Integer> taglie,
                                           String imageUrl) {

        StringBuilder sb = new StringBuilder(256);
        sb.append("{\"success\":true,\"data\":{");
        sb.append("\"nome\":\"").append(jsonEscape(nullToEmpty(nome))).append("\",");
        sb.append("\"descrizione\":\"").append(jsonEscape(nullToEmpty(descrizione))).append("\",");
        sb.append("\"categoria\":\"").append(jsonEscape(nullToEmpty(categoria))).append("\",");

        // numeri come numeri
        sb.append("\"prezzo\":").append(String.format(java.util.Locale.US, "%.2f", prezzo)).append(",");
        sb.append("\"iva\":").append(String.format(java.util.Locale.US, "%.2f", iva)).append(",");

        // taglie
        sb.append("\"taglie\":{");
        if (taglie != null && !taglie.isEmpty()) {
            boolean first = true;
            for (Map.Entry<String, Integer> e : taglie.entrySet()) {
                if (!first) sb.append(',');
                sb.append("\"").append(jsonEscape(e.getKey())).append("\":").append(e.getValue());
                first = false;
            }
        }
        sb.append("},");

        // imageUrl (stringa o null)
        sb.append("\"imageUrl\":");
        if (imageUrl != null) {
            sb.append("\"").append(jsonEscape(imageUrl)).append("\"");
        } else {
            sb.append("null");
        }

        sb.append("}}");
        return sb.toString();
    }

    private static String nullToEmpty(String s) { return (s == null) ? "" : s; }

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
                    if (c < 0x20) {
                        out.append(String.format("\\u%04x", (int)c));
                    } else {
                        out.append(c);
                    }
            }
        }
        return out.toString();
    }
}
