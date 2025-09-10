<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.math.BigDecimal, java.text.SimpleDateFormat" %>
<%@ page import="control.AdminOrdiniController.OrdineAdminRow" %>

<%
  @SuppressWarnings("unchecked")
  List<OrdineAdminRow> ordini = (List<OrdineAdminRow>) request.getAttribute("ordini");
  String order = (String) request.getAttribute("order");
  String statoFilter = (String) request.getAttribute("stato");
  String payFilter = (String) request.getAttribute("pay");
  if (order == null) order = "dateDesc";
  SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
  Locale IT = Locale.ITALY;
%>

<!doctype html>
<html lang="it">
<head>
<meta charset="utf-8">
<title>Gestione Ordini • Admin</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.5.2/css/all.min.css" />
<style>
  body{margin:0;font-family:Inter,system-ui,Segoe UI,Arial,sans-serif;background:#111;color:#fff}
  .page{min-height:100vh;padding:28px;background:linear-gradient(180deg,#1a1a1a,#0d0d0d)}
  h1{margin:0 0 18px;text-align:center}
  .filter-bar{display:flex;gap:12px;align-items:center;margin:8px 0 18px;flex-wrap:wrap}
  .filter-bar select{padding:8px 12px;border-radius:10px;border:1px solid #2c2c39;background:#fff;color:#111;font-weight:700}
  .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:20px}
  .card{background:#fff;color:#111;border:1px solid #ddd;border-radius:16px;overflow:hidden}
  .card-body{padding:16px;display:flex;flex-direction:column;gap:8px}
  .row{display:flex;justify-content:space-between;gap:8px}
  .badge{display:inline-block;padding:4px 8px;border-radius:999px;border:1px solid #ddd;background:#f5f7ff;color:#003366;font-weight:800}
  .muted{color:#666}
  .btn{padding:10px;border-radius:12px;border:1px solid #2c2c39;background:#111;color:#fff;font-weight:800;cursor:pointer;text-decoration:none;text-align:center}
  .btn:hover{filter:brightness(1.1)}
  .sel{padding:6px 8px;border-radius:10px;border:1px solid #ccc;background:#fff;color:#111;font-weight:700}
  /* modal */
  .modal-backdrop{position:fixed;inset:0;background:rgba(0,0,0,.6);display:none;align-items:center;justify-content:center;z-index:1000}
  .modal-backdrop.open{display:flex}
  .modal{background:#fff;color:#111;border-radius:16px;max-width:820px;width:95%;border:1px solid #ddd;box-shadow:0 14px 40px rgba(0,0,0,.35)}
  .modal header{display:flex;align-items:center;justify-content:space-between;padding:16px 18px;border-bottom:1px solid #eee}
  .modal h2{margin:0;font-size:20px;font-weight:900}
  .modal .content{padding:16px 18px}
  table{width:100%;border-collapse:collapse}
  th,td{padding:8px;border-bottom:1px solid #eee;text-align:left}
  /* toast */
  #toast{position:fixed;left:50%;bottom:24px;transform:translateX(-50%);background:#111;color:#fff;padding:10px 14px;border-radius:12px;border:1px solid #333;display:none;z-index:9999}
</style>
</head>
<body>
<div class="page">
  <%@ include file="header.jspf" %>

  <h1><i class="fa-solid fa-truck-fast"></i> Gestione Ordini</h1>

  <div class="filter-bar">
    <form method="get" action="<%=ctx%>/admin/ordini" style="display:flex;gap:10px;align-items:center;flex-wrap:wrap">
      <label>Ordina per</label>
      <select name="order" class="sel" onchange="this.form.submit()">
        <option value="dateDesc"  <%= "dateDesc".equals(order)  ? "selected":"" %>>Data: dal più recente</option>
        <option value="dateAsc"   <%= "dateAsc".equals(order)   ? "selected":"" %>>Data: dal meno recente</option>
        <option value="priceDesc" <%= "priceDesc".equals(order) ? "selected":"" %>>Prezzo: dal più alto</option>
        <option value="priceAsc"  <%= "priceAsc".equals(order)  ? "selected":"" %>>Prezzo: dal più basso</option>
      </select>

      <label>Spedizione</label>
      <select name="stato" class="sel" onchange="this.form.submit()">
        <option value="_ALL" <%= (statoFilter==null ? "selected": "") %>>Tutti</option>
        <option value="IN_ELABORAZIONE" <%= "IN_ELABORAZIONE".equals(statoFilter)?"selected":"" %>>In elaborazione</option>
        <option value="IN_TRANSITO"     <%= "IN_TRANSITO".equals(statoFilter)?"selected":"" %>>In transito</option>
        <option value="CONSEGNATO"      <%= "CONSEGNATO".equals(statoFilter)?"selected":"" %>>Consegnato</option>
      </select>

      <label>Pagamento</label>
      <select name="pay" class="sel" onchange="this.form.submit()">
        <option value="_ALL" <%= (payFilter==null ? "selected": "") %>>Tutti i metodi</option>
        <option value="CARTA"  <%= "CARTA".equalsIgnoreCase(String.valueOf(payFilter)) ? "selected": "" %>>Carta</option>
        <option value="PAYPAL" <%= "PAYPAL".equalsIgnoreCase(String.valueOf(payFilter)) ? "selected": "" %>>PayPal</option>
        <option value="COD"    <%= "COD".equalsIgnoreCase(String.valueOf(payFilter)) ? "selected": "" %>>Contrassegno</option>
      </select>
    </form>
  </div>

  <main class="grid">
    <% if (ordini == null || ordini.isEmpty()) { %>
      <div class="card"><div class="card-body"><div>Nessun ordine trovato.</div></div></div>
    <% } else {
         for (OrdineAdminRow o : ordini) {
           BigDecimal lordo = (o.totaleSpesa==null?BigDecimal.ZERO:o.totaleSpesa)
                              .add(o.totaleIva==null?BigDecimal.ZERO:o.totaleIva);
    %>
      <div class="card">
        <div class="card-body">
          <div class="row">
            <div><strong>Ordine #<%= o.id %></strong></div>
            <div class="badge"><%= o.stato %></div>
          </div>
          <div class="row">
            <div class="muted">Cliente</div>
            <div><i class="fa-solid fa-user"></i> <%= o.clienteNome %></div>
          </div>
          <div class="row">
            <div class="muted">Data</div>
            <div><%= o.dataOrdine!=null ? sdf.format(o.dataOrdine) : "" %></div>
          </div>
          <div class="row">
            <div class="muted">Totale</div>
            <div><%= String.format(IT,"%.2f €", lordo) %></div>
          </div>
          <div class="row">
            <div class="muted">Pagamento</div>
            <div><%= (o.metodoPagamento==null||o.metodoPagamento.isEmpty())? "-" : o.metodoPagamento %></div>
          </div>

          <div class="row" style="align-items:center">
            <div class="muted">Spedizione</div>
            <div>
              <select class="sel ship-select" data-id="<%=o.id%>">
                <option value="IN_ELABORAZIONE" <%= "IN_ELABORAZIONE".equals(o.spedizioneStato)?"selected":"" %>>In elaborazione</option>
                <option value="IN_TRANSITO"     <%= "IN_TRANSITO".equals(o.spedizioneStato)?"selected":"" %>>In transito</option>
                <option value="CONSEGNATO"      <%= "CONSEGNATO".equals(o.spedizioneStato)?"selected":"" %>>Consegnato</option>
              </select>
            </div>
          </div>

          <a href="javascript:void(0)" class="btn" onclick="openOrderAdminDetails(<%= o.id %>)">
            <i class="fa-solid fa-eye"></i> Dettagli
          </a>
        </div>
      </div>
    <% } } %>
  </main>

  <%@ include file="footer.jspf" %>
</div>

<!-- MODALE DETTAGLIO (identico a prima) -->
<div id="order-modal" class="modal-backdrop" aria-hidden="true">
  <div class="modal" role="dialog" aria-modal="true" aria-labelledby="order-title">
    <header>
      <h2 id="order-title">Dettaglio ordine (Admin)</h2>
      <button type="button" class="btn" id="order-close">Chiudi</button>
    </header>
    <div class="content">
      <div id="order-loading">Caricamento…</div>
      <div id="order-error" style="display:none;color:#a10000;background:#ffefef;border:1px solid #ffb3b3;padding:8px;border-radius:10px"></div>
      <div id="order-summary" style="display:none">
        <div style="margin-bottom:10px">
          <div><strong>Ordine #<span id="o-id"></span></strong> •
            <span class="badge" id="o-stato"></span>
            <span style="float:right"><span class="muted">Data:</span> <span id="o-data"></span></span>
          </div>
          <div class="muted">Cliente: <strong id="o-cliente"></strong></div>
          <div class="muted">Pagamento: <strong id="o-metodo"></strong></div>
          <div class="muted">Totale: <strong id="o-totale"></strong></div>
          <div class="muted">Spedizione: <strong id="o-sped-stato"></strong></div>
        </div>
        <div id="o-spedizione-wrap" style="display:none">
          <h3 style="margin:8px 0 6px">Spedizione</h3>
          <div id="o-spedizione" class="muted"></div>
        </div>
        <h3 style="margin:8px 0">Articoli</h3>
        <table>
          <thead><tr><th>Articolo</th><th>Taglia</th><th>Q.tà</th><th>Prezzo</th><th>Totale</th></tr></thead>
          <tbody id="o-righe"></tbody>
        </table>
      </div>
    </div>
  </div>
</div>

<div id="toast"></div>

<script>
(function(){
  var ctx = '<%= ctx %>';

  // toast
  var toast = document.getElementById('toast');
  function showToast(msg){
    toast.textContent = msg; toast.style.display='block';
    setTimeout(function(){ toast.style.display='none'; }, 1800);
  }

  // Update spedizione inline
  Array.prototype.forEach.call(document.querySelectorAll('.ship-select'), function(sel){
    sel.addEventListener('change', async function(){
      var id = sel.getAttribute('data-id');
      var stato = sel.value;
      try{
        var res = await fetch(ctx + '/admin/ordini/spedizione', {
          method:'POST',
          headers:{ 'Content-Type':'application/x-www-form-urlencoded' },
          body: 'id='+encodeURIComponent(id)+'&stato='+encodeURIComponent(stato)
        });
        if (!res.ok) { showToast('Errore aggiornamento'); return; }
        var j = await res.json();
        if (j && j.success) showToast('Spedizione aggiornata');
        else showToast('Errore: ' + (j && j.error ? j.error : ''));
      }catch(e){ showToast('Errore di rete'); }
    });
  });

  // Modale dettaglio
  var modal = document.getElementById('order-modal');
  var btnClose = document.getElementById('order-close');
  var loading = document.getElementById('order-loading');
  var errBox = document.getElementById('order-error');
  var summary = document.getElementById('order-summary');

  var idEl = document.getElementById('o-id');
  var statoEl = document.getElementById('o-stato');
  var dataEl = document.getElementById('o-data');
  var clienteEl = document.getElementById('o-cliente');
  var metodoEl = document.getElementById('o-metodo');
  var totaleEl = document.getElementById('o-totale');
  var righeTbody = document.getElementById('o-righe');
  var spedWrap = document.getElementById('o-spedizione-wrap');
  var spedEl = document.getElementById('o-spedizione');
  var spedStatoEl = document.getElementById('o-sped-stato');

  function openModal(){ modal.classList.add('open'); modal.setAttribute('aria-hidden','false'); }
  function closeModal(){ modal.classList.remove('open'); modal.setAttribute('aria-hidden','true'); }
  btnClose.addEventListener('click', closeModal);
  modal.addEventListener('click', function(e){ if (e.target === modal) closeModal(); });

  function fmtMoney(n){ try { return new Intl.NumberFormat('it-IT',{style:'currency',currency:'EUR'}).format(Number(n)); } catch(e){ return n; } }
  function fmtDateIso(ts){ var d = new Date(String(ts||'').replace(' ','T')); return isNaN(d) ? (ts||'') : d.toLocaleString('it-IT'); }
  function escHtml(s){ return String(s||'').replace(/[&<>"']/g, m=>({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;' }[m])); }

  window.openOrderAdminDetails = async function(id){
    loading.style.display='block'; errBox.style.display='none'; summary.style.display='none';
    righeTbody.innerHTML=''; spedWrap.style.display='none'; openModal();

    try{
      var res = await fetch(ctx + '/admin/ordine?id='+encodeURIComponent(id), { headers:{'Accept':'application/json'} });
      if (!res.ok) throw new Error('HTTP '+res.status);
      var o = await res.json();

      idEl.textContent = o.id;
      statoEl.textContent = o.stato || '';
      dataEl.textContent = fmtDateIso(o.dataOrdine);
      clienteEl.textContent = o.cliente || '';
      metodoEl.textContent = o.metodoPagamento || '';
      totaleEl.textContent = fmtMoney(o.totaleLordo);
      spedStatoEl.textContent = o.spedizioneStato || 'IN_ELABORAZIONE';

      if (o.spedizione){
        var s = o.spedizione;
        var line = (s.indirizzo||'')+' '+(s.numeroCivico||'')+', '+(s.cap||'')+' '+(s.citta||'');
        if (s.data) line += ' • ' + s.data;
        spedEl.textContent = line;
        spedWrap.style.display='block';
      }

      (o.righe||[]).forEach(function(r){
        var tr = document.createElement('tr');
        tr.innerHTML =
          '<td>'+escHtml(r.nome)+'</td>'+
          '<td>'+escHtml(r.taglia||'')+'</td>'+
          '<td>'+r.q+'</td>'+
          '<td>'+fmtMoney(r.prezzo)+'</td>'+
          '<td>'+fmtMoney(r.totale)+'</td>';
        righeTbody.appendChild(tr);
      });

      loading.style.display='none';
      summary.style.display='block';
    } catch(err){
      loading.style.display='none';
      errBox.textContent = 'Impossibile caricare il dettaglio. ' + err.message;
      errBox.style.display='block';
    }
  };
})();
</script>
</body>
</html>
