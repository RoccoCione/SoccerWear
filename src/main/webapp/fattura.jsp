<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal, java.text.SimpleDateFormat" %>
<%@ page import="model.FatturaBean" %>
<%
  FatturaBean f = (FatturaBean) request.getAttribute("fattura");
  if (f == null) { response.sendError(404); return; }
  String cliente = (String) request.getAttribute("cliente");
  String metodo  = (String) request.getAttribute("metodoPagamento");
  String dataOrd = (String) request.getAttribute("dataOrdine");
  BigDecimal lordo = (BigDecimal) request.getAttribute("totaleLordo");
  String ctx = request.getContextPath();
  java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!doctype html>
<html lang="it">
<head>
<meta charset="utf-8">
<title>Fattura #<%=f.getId()%> • Ordine <%=f.getOrdineId()%></title>
<style>
  :root{ --ink:#111; --muted:#555; --ring:#ddd; --focus:#003366; }
  *{box-sizing:border-box}
  body{font-family:Inter,system-ui,Segoe UI,Arial,sans-serif;color:var(--ink);background:#fff;margin:0;padding:28px}
  .sheet{max-width:900px;margin:0 auto;border:1px solid var(--ring);border-radius:16px;overflow:hidden}
  header{display:flex;justify-content:space-between;align-items:center;padding:18px;border-bottom:1px solid #eee;background:#f9fbff}
  header h1{margin:0;font-size:20px}
  .meta{padding:18px;display:grid;grid-template-columns:1fr 1fr;gap:16px}
  .card{border:1px solid var(--ring);border-radius:12px;padding:12px;background:#fff}
  .muted{color:var(--muted)}
  table{width:100%;border-collapse:collapse;margin:0 18px 18px}
  th,td{padding:10px;border-bottom:1px solid #eee;text-align:left}
  tfoot td{font-weight:800}
  .actions{padding:0 18px 18px;display:flex;gap:10px;justify-content:flex-end}
  .btn{padding:10px 14px;border:1px solid var(--ring);border-radius:12px;background:#fff;color:#111;font-weight:800;cursor:pointer}
  .btn:hover{background:#111;color:#fff}
  @media print{
    .actions{display:none}
    body{padding:0}
    .sheet{border:none;border-radius:0}
  }
</style>
</head>
<body>
<div class="sheet">
  <header>
    <h1>Fattura #<%= f.getId() %></h1>
    <div class="muted">
      Emessa il <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(f.getDataEmissione()) %>
    </div>
  </header>

  <div class="meta">
    <div class="card">
      <div class="muted">Cliente</div>
      <div><strong><%= cliente %></strong></div>
    </div>
    <div class="card">
      <div class="muted">Riferimenti</div>
      <div>Ordine: <strong>#<%= f.getOrdineId() %></strong></div>
      <div>Data ordine: <strong><%= dataOrd %></strong></div>
      <div>Pagamento: <strong><%= metodo==null?"":metodo %></strong></div>
    </div>
  </div>

  <!-- Se vuoi elencare le righe dell’ordine, puoi leggerle qui come fatto per i dettagli ordine -->
  <table>
    <thead><tr><th>Descrizione</th><th>Imponibile</th><th>IVA</th><th>Totale</th></tr></thead>
    <tbody>
      <tr>
        <td>Ordine #<%= f.getOrdineId() %></td>
        <td><%= String.format(java.util.Locale.ITALY,"%.2f €", f.getTotaleSpesa()) %></td>
        <td><%= String.format(java.util.Locale.ITALY,"%.2f €", f.getTotaleIva()) %></td>
        <td><%= String.format(java.util.Locale.ITALY,"%.2f €", f.getTotaleSpesa().add(f.getTotaleIva())) %></td>
      </tr>
    </tbody>
    <tfoot>
      <tr><td colspan="3" style="text-align:right">TOTALE</td>
          <td><%= String.format(java.util.Locale.ITALY,"%.2f €", lordo) %></td></tr>
    </tfoot>
  </table>

  <div class="actions">
    <a href="<%=ctx%>/ordini" class="btn">Torna ai miei ordini</a>
    <button class="btn" onclick="window.print()">Stampa / Salva PDF</button>
  </div>
</div>
</body>
</html>
