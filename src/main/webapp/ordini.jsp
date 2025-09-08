<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.math.BigDecimal, java.text.SimpleDateFormat" %>
<%@ page import="model.OrdineBean" %>

<%
  // Se aperta senza controller, reindirizza
  if (request.getAttribute("ordini") == null) {
    response.sendRedirect(request.getContextPath() + "/ordini");
    return;
  }

  @SuppressWarnings("unchecked")
  List<OrdineBean> ordini = (List<OrdineBean>) request.getAttribute("ordini");
  String order = (String) request.getAttribute("order");
  if (order == null) order = "dateDesc";

  SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
  Locale IT = Locale.ITALY;
%>

<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <title>I miei ordini • SoccerWear</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.5.2/css/all.min.css" />
  <style>
    :root { --bg:#111; --panel:#fff; --ring:#ddd; --ink:#111; --muted:#555; --focus:#003366; --radius:16px; }
    *{box-sizing:border-box}
    body{ margin:0; font-family:"Inter",system-ui,Segoe UI,Roboto,Arial,sans-serif; color:var(--ink); background:#111; }
    .page{ min-height:100vh; padding:28px 28px 40px; background:linear-gradient(180deg,#1a1a1a,#0d0d0d); overflow-x:hidden; }
    h1{ text-align:center; margin-bottom:20px; color:#fff; }

    .filter-bar{display:flex;justify-content:center;align-items:center;gap:14px;margin:10px 0 22px}
    .filter-form label{font-weight:700;color:#fff;font-size:15px}
    .filter-form select{
      appearance:none;padding:10px 14px;border-radius:12px;border:1px solid #2c2c39;background:#fff;color:#111;
      font-weight:700;font-size:14px;cursor:pointer;min-width:220px;
      background-image:url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12'><polygon points='0,0 12,0 6,8' fill='%23003366'/></svg>");
      background-repeat:no-repeat;background-position:right 12px center;background-size:12px;
    }

    .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:24px;max-width:1100px;margin:0 auto}
    .card{background:var(--panel);color:var(--ink);border:1px solid var(--ring);border-radius:var(--radius);overflow:hidden;display:flex;flex-direction:column;box-shadow:0 4px 10px rgba(0,0,0,.1)}
    .card-body{padding:16px;display:flex;flex-direction:column;gap:8px}
    .row{display:flex;justify-content:space-between;gap:8px}
    .muted{color:var(--muted)}
    .badge{display:inline-block;padding:4px 8px;border-radius:999px;border:1px solid #ddd;background:#f5f7ff;color:#003366;font-weight:800}
    .btn{margin-top:8px;padding:10px;border-radius:12px;border:1px solid var(--ring);background:#fff;color:#111;font-weight:800;text-align:center;text-decoration:none;cursor:pointer}
    .btn:hover{background:linear-gradient(180deg,#1a1a1a,#0d0d0d);color:#fff}

    /* Modal */
    .modal-backdrop{position:fixed;inset:0;background:rgba(0,0,0,.6);display:none;align-items:center;justify-content:center;z-index:1000}
    .modal-backdrop.open{display:flex}
    .modal{background:#fff;color:#111;border-radius:16px;max-width:820px;width:95%;border:1px solid #ddd;box-shadow:0 14px 40px rgba(0,0,0,.35)}
    .modal header{display:flex;align-items:center;justify-content:space-between;padding:16px 18px;border-bottom:1px solid #eee}
    .modal h2{margin:0;font-size:20px;font-weight:900}
    .modal .content{padding:16px 18px}
    .modal .section{margin-bottom:14px}
    .modal table{width:100%;border-collapse:collapse}
    .modal th,.modal td{padding:8px;border-bottom:1px solid #eee;text-align:left}
    .pill{display:inline-block;padding:4px 8px;border-radius:999px;border:1px solid #ddd;background:#f5f7ff;color:#00366}
    .muted-d{color:#666}
    .right{float:right}
  </style>
</head>
<body>
  <div class="page">
    <%@ include file="header.jspf" %>

    <h1><i class="fa-solid fa-receipt"></i> I miei ordini</h1>

    <!-- Filtro Ordina per -->
    <div class="filter-bar">
      <form method="get" action="<%=ctx%>/ordini" class="filter-form">
        <label for="order">Ordina per:</label>
        <select name="order" id="order" onchange="this.form.submit()">
          <option value="dateDesc"  <%= "dateDesc".equals(order)  ? "selected" : "" %>>Data: dal più recente</option>
          <option value="dateAsc"   <%= "dateAsc".equals(order)   ? "selected" : "" %>>Data: dal meno recente</option>
          <option value="priceDesc" <%= "priceDesc".equals(order) ? "selected" : "" %>>Prezzo: dal più alto</option>
          <option value="priceAsc"  <%= "priceAsc".equals(order)  ? "selected" : "" %>>Prezzo: dal più basso</option>
        </select>
      </form>
    </div>

    <!-- Elenco ordini in card (stile catalogo) -->
    <main class="grid">
      <% if (ordini == null || ordini.isEmpty()) { %>
        <div class="card"><div class="card-body"><div>Nessun ordine trovato.</div></div></div>
      <% } else {
           for (OrdineBean o : ordini) {
             BigDecimal lordo = (o.getTotaleSpesa()==null?BigDecimal.ZERO:o.getTotaleSpesa())
                               .add(o.getTotaleIva()==null?BigDecimal.ZERO:o.getTotaleIva());
      %>
        <div class="card">
          <div class="card-body">
            <div class="row">
              <div><strong>Ordine #<%= o.getId() %></strong></div>
              <div class="badge"><%= o.getStato() %></div>
            </div>
            <div class="row">
              <div class="muted">Data</div>
              <div><%= o.getDataOrdine()!=null ? sdf.format(o.getDataOrdine()) : "" %></div>
            </div>
            <div class="row">
              <div class="muted">Totale</div>
              <div><%= String.format(IT,"%.2f €", lordo) %></div>
            </div>
            <a href="javascript:void(0)" class="btn" onclick="openOrderDetails(<%= o.getId() %>)">
              <i class="fa-solid fa-eye"></i> Dettagli
            </a>
          </div>
        </div>
      <% } } %>
    </main>

    <%@ include file="footer.jspf" %>
  </div>

  <!-- MODALE DETTAGLIO ORDINE -->
  <div id="order-modal" class="modal-backdrop" aria-hidden="true">
    <div class="modal" role="dialog" aria-modal="true" aria-labelledby="order-title">
      <header>
        <h2 id="order-title">Dettaglio ordine</h2>
        <button type="button" class="btn" id="order-close">Chiudi</button>
      </header>
      <div class="content">
        <div id="order-loading" class="section">Caricamento…</div>
        <div id="order-error" class="section" style="display:none;color:#a10000;background:#ffefef;border:1px solid #ffb3b3;padding:8px;border-radius:10px"></div>

        <div id="order-summary" style="display:none">
          <div class="section">
            <div><strong>Ordine #<span id="o-id"></span></strong> •
              <span class="pill" id="o-stato"></span>
              <span class="right"><span class="muted-d">Data:</span> <span id="o-data"></span></span>
            </div>
            <div class="muted-d">Totale: <strong id="o-totale"></strong></div>
            <div class="muted-d" id="o-pay-wrap" style="display:none">Metodo di pagamento: <strong id="o-pay"></strong></div>
          </div>

          <div class="section" id="o-spedizione-wrap" style="display:none">
            <h3 style="margin:0 0 6px">Spedizione</h3>
            <div class="muted-d" id="o-spedizione"></div>
          </div>

          <div class="section">
            <h3 style="margin:8px 0">Articoli</h3>
            <table>
              <thead><tr><th>Articolo</th><th>Taglia</th><th>Q.tà</th><th>Prezzo</th><th>Totale</th></tr></thead>
              <tbody id="o-righe"></tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>

<script>
(function(){
  var ctx = '<%= ctx %>';
  var modal = document.getElementById('order-modal');
  var btnClose = document.getElementById('order-close');
  var loading = document.getElementById('order-loading');
  var errBox = document.getElementById('order-error');
  var summary = document.getElementById('order-summary');

  var idEl = document.getElementById('o-id');
  var statoEl = document.getElementById('o-stato');
  var dataEl = document.getElementById('o-data');
  var totaleEl = document.getElementById('o-totale');
  var payWrap = document.getElementById('o-pay-wrap');
  var payEl = document.getElementById('o-pay');
  var righeTbody = document.getElementById('o-righe');
  var spedWrap = document.getElementById('o-spedizione-wrap');
  var spedEl = document.getElementById('o-spedizione');

  function openModal(){ modal.classList.add('open'); modal.setAttribute('aria-hidden','false'); }
  function closeModal(){ modal.classList.remove('open'); modal.setAttribute('aria-hidden','true'); }
  btnClose.addEventListener('click', closeModal);
  modal.addEventListener('click', function(e){ if (e.target === modal) closeModal(); });

  function formatMoney(n){
    try { return new Intl.NumberFormat('it-IT',{style:'currency',currency:'EUR'}).format(Number(n)); }
    catch(e){ return n; }
  }
  function formatDateIso(ts){
    var s = String(ts || '').replace(' ', 'T');
    var d = new Date(s);
    if (isNaN(d)) return ts || '';
    return d.toLocaleString('it-IT');
  }
  function escapeHtml(s){
    return String(s||'').replace(/[&<>"']/g,function(m){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]});
  }

  // Usa /api/order esattamente come /api/product nel catalogo
  window.openOrderDetails = async function(id){
    loading.style.display = 'block';
    errBox.style.display = 'none';
    summary.style.display = 'none';
    righeTbody.innerHTML = '';
    spedWrap.style.display = 'none';
    payWrap.style.display = 'none';
    openModal();

    try{
      var url = ctx + '/api/order?id=' + encodeURIComponent(id);
      var res = await fetch(url, { headers: { 'Accept':'application/json' }});
      if (!res.ok) throw new Error('HTTP ' + res.status);
      var payload = await res.json();
      if (!payload.success) throw new Error(payload.error || 'Errore');

      var o = payload.data;

      idEl.textContent = o.id;
      statoEl.textContent = o.stato || '';
      dataEl.textContent = formatDateIso(o.dataOrdine);
      totaleEl.textContent = formatMoney(o.totaleLordo);

      if (o.metodoPagamento && o.metodoPagamento.trim() !== '') {
        payEl.textContent = o.metodoPagamento;
        payWrap.style.display = 'block';
      }

      if (o.spedizione){
        var s = o.spedizione;
        var line = (s.indirizzo||'') + ' ' + (s.numeroCivico||'') + ', ' + (s.cap||'') + ' ' + (s.citta||'');
        if (s.data) line += ' • ' + s.data;
        spedEl.textContent = line;
        spedWrap.style.display = 'block';
      }

      (o.righe || []).forEach(function(r){
        var tr = document.createElement('tr');
        tr.innerHTML =
          '<td>' + escapeHtml(r.nome) + '</td>' +
          '<td>' + escapeHtml(r.taglia || '') + '</td>' +
          '<td>' + r.q + '</td>' +
          '<td>' + formatMoney(r.prezzo) + '</td>' +
          '<td>' + formatMoney(r.totale) + '</td>';
        righeTbody.appendChild(tr);
      });

      loading.style.display = 'none';
      summary.style.display = 'block';
    }catch(err){
      loading.style.display = 'none';
      errBox.textContent = 'Impossibile caricare il dettaglio ordine. ' + err.message;
      errBox.style.display = 'block';
    }
  };
})();
</script>
</body>
</html>
