<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.math.BigDecimal, java.text.SimpleDateFormat" %>
<%@ page import="model.OrdineBean" %>
<%
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
    .btn-danger{background:#fff0f0;border:1px solid #ffb3b3;color:#a10000}
    .btn-danger:hover{background:#ffe5e5}

    /* Modal */
    .modal-backdrop{position:fixed;inset:0;background:rgba(0,0,0,.6);display:none;align-items:center;justify-content:center;z-index:1000}
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

    /* Toast */
    #toast {
      position: fixed; left: 50%; bottom: 24px; transform: translateX(-50%);
      display: none; z-index: 9999;
      background: #101013; color: #fff; border: 1px solid #2c2c39;
      padding: 10px 14px; border-radius: 12px; box-shadow: 0 10px 30px rgba(0,0,0,.4);
      font-weight: 800; min-width: 220px; text-align: center;
    }
    #toast.success { border-color:#22c55e; }
    #toast.error   { border-color:#ef4444; }
  </style>
</head>
<body>
<div class="page">
  <%@ include file="header.jspf" %>

  <h1><i class="fa-solid fa-receipt"></i> I miei ordini</h1>

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

  <main class="grid">
  <% if (ordini == null || ordini.isEmpty()) { %>
    <div class="card"><div class="card-body"><div>Nessun ordine trovato.</div></div></div>
  <% } else {
       for (OrdineBean o : ordini) {
         BigDecimal lordo = (o.getTotaleSpesa()==null?BigDecimal.ZERO:o.getTotaleSpesa())
                           .add(o.getTotaleIva()==null?BigDecimal.ZERO:o.getTotaleIva());
         String ship = (String) request.getAttribute("spedizione_stato_" + o.getId());
         String st = o.getStato()==null? "" : o.getStato();

         boolean cancellabile = "IN_COSTRUZIONE".equalsIgnoreCase(ship);
         boolean resoAbilitato = "CONSEGNATO".equalsIgnoreCase(String.valueOf(ship));
         String resoStato = (String) request.getAttribute("reso_stato_" + o.getId()); // può essere null
         boolean hasReso = (resoStato != null && !resoStato.isBlank());
  %>
    <div class="card">
      <div class="card-body">
        <div class="row">
          <div><strong>Ordine #<%= o.getId() %></strong></div>
          <div class="badge"><%= st %></div>
        </div>
        <div class="row">
          <div class="muted">Spedizione</div>
          <div><%= ship == null ? "-" : ship.replace('_',' ') %></div>
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

        <% if (cancellabile) { %>
          <a href="javascript:void(0)" class="btn btn-danger" onclick="cancelOrder(<%= o.getId() %>)">
            <i class="fa-solid fa-ban"></i> Annulla ordine
          </a>
        <% } %>

        <% if (hasReso) { %>
          <a href="javascript:void(0)" class="btn" onclick="openReturnDetails(<%= o.getId() %>)">
            <i class="fa-solid fa-rotate-left"></i> Dettagli reso
          </a>
        <% } else if (resoAbilitato) { %>
          <a href="javascript:void(0)" class="btn" onclick="openReturnRequest(<%= o.getId() %>)">
            <i class="fa-solid fa-rotate-left"></i> Richiedi reso
          </a>
        <% } %>
        <%
Integer fattId = (Integer) request.getAttribute("fattura_id_" + o.getId());
boolean fatturaEsiste = (fattId != null);
%>

<% if (fatturaEsiste) { %>
  <a href="<%=ctx%>/fattura?ordineId=<%=o.getId()%>" class="btn">
    <i class="fa-solid fa-file-invoice"></i> Fattura
  </a>
<% } else if ("PAGATO".equalsIgnoreCase(st) || "CONSEGNATO".equalsIgnoreCase(String.valueOf(ship))) { %>
  <a href="javascript:void(0)" class="btn"
     onclick="generateInvoice(<%=o.getId()%>)">
    <i class="fa-solid fa-file-circle-plus"></i> Genera fattura
  </a>
<% } %>
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

<!-- MODALE RICHIESTA RESO -->
<div id="return-request-modal" class="modal-backdrop" aria-hidden="true" style="display:none">
  <div class="modal" role="dialog" aria-modal="true" aria-labelledby="ret-title">
    <header>
      <h2 id="ret-title">Richiedi reso</h2>
      <button type="button" class="btn" onclick="closeReturnRequest()">Chiudi</button>
    </header>
    <div class="content">
      <form id="ret-form" method="post" action="<%=ctx%>/reso/create">
        <input type="hidden" name="ordineId" id="retOrdineId">
        <label>Motivo del reso</label>
        <textarea name="motivo" id="retMotivo" required
                  style="width:100%;min-height:90px;padding:10px;border:1px solid #ccc;border-radius:10px"></textarea>
        <div style="margin-top:12px;display:flex;gap:10px;justify-content:flex-end">
          <button type="button" class="btn" onclick="closeReturnRequest()">Annulla</button>
          <button type="submit" class="btn"><i class="fa-solid fa-paper-plane"></i> Invia richiesta</button>
        </div>
      </form>
      <div id="ret-error-req" style="display:none;margin-top:10px;background:#ffefef;border:1px solid #ffb3b3;color:#a10000;padding:8px;border-radius:10px"></div>
    </div>
  </div>
</div>

<!-- MODALE DETTAGLI RESO -->
<div id="return-details-modal" class="modal-backdrop" aria-hidden="true" style="display:none">
  <div class="modal" role="dialog" aria-modal="true" aria-labelledby="retd-title">
    <header>
      <h2 id="retd-title"><i class="fa-solid fa-rotate-left"></i> Dettagli reso</h2>
      <button type="button" class="btn" onclick="closeReturnDetails()">Chiudi</button>
    </header>
    <div class="content">
      <div id="ret-loading-d">Caricamento…</div>
      <div id="ret-error-d" style="display:none;background:#ffefef;color:#a10000;border:1px solid #ffb3b3;padding:8px;border-radius:10px"></div>

      <div id="ret-body-d" style="display:none">
        <div style="display:flex;gap:8px;justify-content:space-between;margin-bottom:10px">
          <div><strong>Ordine #<span id="ret-ordine-d"></span></strong></div>
          <div>Stato: <span id="ret-stato-d" style="font-weight:800;color:#0d47a1"></span></div>
        </div>

        <div style="margin:8px 0">
          <div style="color:#666;font-weight:700">Motivo reso</div>
          <div id="ret-motivo-d" style="white-space:pre-wrap"></div>
        </div>

        <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-top:10px">
          <div>
            <div style="color:#666;font-weight:700">Importo rimborso</div>
            <div id="ret-refund-d">—</div>
          </div>
          <div>
            <div style="color:#666;font-weight:700">Creato il</div>
            <div id="ret-created-d">—</div>
          </div>
          <div>
            <div style="color:#666;font-weight:700">Aggiornato il</div>
            <div id="ret-updated-d">—</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Toast -->
<div id="toast"></div>

<script>
(function(){
  const ctx = '<%= ctx %>';

  // Toast
  const toast = document.getElementById('toast');
  function showToast(msg, kind){
    toast.textContent = msg || '';
    toast.className = kind ? kind : '';
    toast.style.display = 'block';
    setTimeout(()=>{ toast.style.display='none'; }, 2000);
  }
  window._toast = showToast;

  // --------- Modale DETTAGLIO ORDINE ---------
  const omBack = document.getElementById('order-modal');
  const omClose= document.getElementById('order-close');
  const oLoad  = document.getElementById('order-loading');
  const oErr   = document.getElementById('order-error');
  const oSum   = document.getElementById('order-summary');
  const idEl   = document.getElementById('o-id');
  const statoEl= document.getElementById('o-stato');
  const dataEl = document.getElementById('o-data');
  const totEl  = document.getElementById('o-totale');
  const payWrap= document.getElementById('o-pay-wrap');
  const payEl  = document.getElementById('o-pay');
  const righe  = document.getElementById('o-righe');
  const spWrap = document.getElementById('o-spedizione-wrap');
  const spEl   = document.getElementById('o-spedizione');

  function openOrderModal(){ omBack.style.display='flex'; omBack.setAttribute('aria-hidden','false'); }
  function closeOrderModal(){ omBack.style.display='none'; omBack.setAttribute('aria-hidden','true'); }
  omClose.addEventListener('click', closeOrderModal);
  omBack.addEventListener('click', (e)=>{ if (e.target===omBack) closeOrderModal(); });

  function fmtMoney(n){ try { return new Intl.NumberFormat('it-IT',{style:'currency',currency:'EUR'}).format(Number(n)); } catch(_) { return String(n); } }
  function fmtDate(s){ const d = new Date(String(s||'').replace(' ','T')); return isNaN(d)? (s||'') : d.toLocaleString('it-IT'); }
  function esc(s){ return String(s||'').replace(/[&<>"']/g,m=>({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;' }[m])); }

  window.openOrderDetails = async function(id){
    oLoad.style.display='block'; oErr.style.display='none'; oSum.style.display='none';
    righe.innerHTML=''; spWrap.style.display='none'; payWrap.style.display='none';
    openOrderModal();
    try{
      const r = await fetch(ctx + '/api/order?id=' + encodeURIComponent(id), { headers:{'Accept':'application/json'} });
      const p = await r.json();
      if (!r.ok || !p.success) throw new Error(p.error || ('HTTP '+r.status));
      const o = p.data;
      idEl.textContent = o.id;
      statoEl.textContent = o.stato || '';
      dataEl.textContent = fmtDate(o.dataOrdine);
      totEl.textContent  = fmtMoney(o.totaleLordo);
      if (o.metodoPagamento && o.metodoPagamento.trim() !== '') { payEl.textContent = o.metodoPagamento; payWrap.style.display='block'; }
      if (o.spedizione){
        const s = o.spedizione;
        let line = (s.indirizzo||'') + ' ' + (s.numeroCivico||'') + ', ' + (s.cap||'') + ' ' + (s.citta||'');
        if (s.data) line += ' • ' + s.data;
        spEl.textContent = line; spWrap.style.display='block';
      }
      (o.righe||[]).forEach(rw=>{
        const tr = document.createElement('tr');
        tr.innerHTML = '<td>'+esc(rw.nome)+'</td><td>'+esc(rw.taglia||'')+'</td><td>'+rw.q+'</td><td>'+fmtMoney(rw.prezzo)+'</td><td>'+fmtMoney(rw.totale)+'</td>';
        righe.appendChild(tr);
      });
      oLoad.style.display='none'; oSum.style.display='block';
    }catch(err){
      oLoad.style.display='none'; oErr.textContent = 'Impossibile caricare il dettaglio ordine. ' + err.message; oErr.style.display='block';
    }
  };

  // --------- Annulla ordine ---------
  window.cancelOrder = async function(id){
    if(!confirm("Confermi l'annullamento di questo ordine?")) return;
    try{
      const res = await fetch(ctx + '/ordine/cancel', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:'id='+encodeURIComponent(id) });
      const js = await res.json().catch(()=>({success:false,error:'Risposta non valida'}));
      if(!res.ok || !js.success){ showToast(js.error || 'Impossibile annullare l\'ordine.','error'); return; }
      showToast('Ordine annullato correttamente.','success'); setTimeout(()=>location.reload(),900);
    }catch(e){ showToast('Errore di rete: ' + e.message,'error'); }
  };

  // --------- RICHIESTA RESO (MODALE) ---------
  const reqModal = document.getElementById('return-request-modal');
  const reqForm  = document.getElementById('ret-form');
  const reqErr   = document.getElementById('ret-error-req');

  window.openReturnRequest = function(ordineId){
    document.getElementById('retOrdineId').value = ordineId;
    document.getElementById('retMotivo').value   = '';
    reqErr.style.display='none';
    reqModal.style.display='flex';
    reqModal.setAttribute('aria-hidden','false');
  };
  window.closeReturnRequest = function(){
    reqModal.style.display='none';
    reqModal.setAttribute('aria-hidden','true');
  };
  reqModal.addEventListener('click', (e)=>{ if (e.target===reqModal) window.closeReturnRequest(); });

  // invio come x-www-form-urlencoded (compatibile con req.getParameter)
  reqForm.addEventListener('submit', async (e)=>{
    e.preventDefault();
    const fd = new FormData(reqForm);
    const params = new URLSearchParams();
    fd.forEach((v,k)=>params.append(k,v));
    try{
      const res = await fetch(reqForm.action, { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, body: params.toString() });
      const js  = await res.json().catch(()=>({success:false,error:'Risposta non valida'}));
      if(!res.ok || !js.success){
        reqErr.textContent = js.error || 'Errore durante la richiesta di reso';
        reqErr.style.display='block';
        return;
      }
      window.closeReturnRequest();
      alert('Richiesta di reso inviata con successo.');
      location.reload();
    }catch(ex){
      reqErr.textContent = ex.message; reqErr.style.display='block';
    }
  });

  // --------- DETTAGLI RESO (MODALE) ---------
  const detModal = document.getElementById('return-details-modal');
  const detLoad  = document.getElementById('ret-loading-d');
  const detErr   = document.getElementById('ret-error-d');
  const detBody  = document.getElementById('ret-body-d');

  window.openReturnDetails = function(ordineId){
    document.getElementById('ret-ordine-d').textContent = ordineId;
    detLoad.style.display='block'; detErr.style.display='none'; detBody.style.display='none';
    detModal.style.display='flex'; detModal.setAttribute('aria-hidden','false');

    fetch(ctx + '/api/reso?ordineId=' + encodeURIComponent(ordineId), { headers:{'Accept':'application/json'} })
      .then(r => r.json().then(j=>({ok:r.ok,j})))
      .then(({ok,j})=>{
        if(!ok || !j.success) throw new Error(j.error || 'Errore');
        const d = j.data || {};
        document.getElementById('ret-stato-d').textContent   = d.stato || '—';
        document.getElementById('ret-motivo-d').textContent  = d.motivo || '—';
        document.getElementById('ret-refund-d').textContent  =
          (d.refund!=null) ? new Intl.NumberFormat('it-IT',{style:'currency',currency:'EUR'}).format(d.refund) : '—';
        document.getElementById('ret-created-d').textContent = fmtDate(d.createdAt);
        document.getElementById('ret-updated-d').textContent = fmtDate(d.updatedAt);
        detLoad.style.display='none'; detBody.style.display='block';
      })
      .catch(err=>{
        detLoad.style.display='none';
        detErr.textContent = 'Impossibile caricare i dettagli del reso. ' + err.message;
        detErr.style.display='block';
      });
  };
  window.closeReturnDetails = function(){
    detModal.style.display='none'; detModal.setAttribute('aria-hidden','true');
  };
  detModal.addEventListener('click', (e)=>{ if (e.target===detModal) window.closeReturnDetails(); });

})();
</script>
<script>
async function generateInvoice(ordineId){
  try{
    const res = await fetch('<%=ctx%>/fattura/create', {
      method:'POST',
      headers:{'Content-Type':'application/x-www-form-urlencoded'},
      body:'ordineId='+encodeURIComponent(ordineId)
    });
    const j = await res.json().catch(()=>({success:false,error:'Risposta non valida'}));
    if(!res.ok || !j.success){ alert(j.error || 'Errore creazione fattura'); return; }
    // Apri subito la fattura
    window.location.href = '<%=ctx%>/fattura?ordineId=' + ordineId;
  }catch(e){ alert('Errore di rete: '+e.message); }
}
</script>

</body>
</html>
