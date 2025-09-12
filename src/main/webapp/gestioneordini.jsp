<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.math.BigDecimal, java.text.SimpleDateFormat" %>
<%@ page import="control.AdminOrdiniController.OrdineAdminRow" %>

<%
  @SuppressWarnings("unchecked")
  List<OrdineAdminRow> ordini = (List<OrdineAdminRow>) request.getAttribute("ordini");
  String order       = (String) request.getAttribute("order");
  String statoFilter = (String) request.getAttribute("stato");   // può essere null
  String payFilter   = (String) request.getAttribute("pay");     // può essere null
  String fromFilter  = (String) request.getAttribute("from");    // YYYY-MM-DD o null
  String toFilter    = (String) request.getAttribute("to");      // YYYY-MM-DD o null
  String clienteQ    = (String) request.getAttribute("cliente"); // testo o null

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

  /* === FILTER BAR === */
  .filters{background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.16);border-radius:18px;padding:16px;margin:12px 0 24px;backdrop-filter:saturate(115%) blur(4px)}
  .filters form{display:grid;grid-template-columns:repeat(12,1fr);gap:12px 14px;align-items:end}
  .fld{grid-column:span 3;display:grid;gap:6px;min-width:180px}
  .fld--short{grid-column:span 2;min-width:150px}
  .fld--wide{grid-column:span 4}
  .fld label{font-size:12.5px;letter-spacing:.02em;color:#e6e8ff;font-weight:800;display:inline-flex;gap:8px;align-items:center;opacity:.95}
  .fld label i{font-size:12px;opacity:.9}
  .sel,.inp{width:100%;padding:11px 12px;border-radius:12px;border:1px solid rgba(255,255,255,.20);background:rgba(12,12,18,.78);color:#fff;font-weight:700;outline:none;transition:border-color .15s ease,box-shadow .15s ease,background .15s ease}
  .sel:hover,.inp:hover{border-color:rgba(255,255,255,.28);background:rgba(16,16,24,.84)}
  .sel:focus,.inp:focus{border-color:#fff6b0;box-shadow:0 0 0 3px rgba(143,177,255,.22)}
  .sel option{color:#000}
  .f-actions{grid-column:span 12;display:flex;gap:12px;justify-content:flex-end;padding-top:4px}
  .btn-ghost,.btn-primary{padding:11px 16px;border-radius:12px;font-weight:900;letter-spacing:.02em;cursor:pointer;border:1px solid rgba(255,255,255,.20);background:rgba(255,255,255,.08);color:#fff;transition:filter .15s ease,transform .06s ease,background .15s ease,border-color .15s ease}
  .btn-ghost:hover{filter:brightness(1.06);border-color:rgba(255,255,255,.28)}
  .btn-ghost:active,.btn-primary:active{transform:translateY(1px)}
  .btn-primary{background:linear-gradient(180deg,#ffffff,#e6ecff);color:#0c0c12;border-color:rgba(255,255,255,.85)}
  .btn-primary:hover{filter:brightness(1.02)}
  @media(max-width:1080px){.fld{grid-column:span 4}.fld--wide{grid-column:span 6}.fld--short{grid-column:span 3}}
  @media(max-width:760px){.filters{padding:14px;border-radius:16px}.filters form{grid-template-columns:repeat(6,1fr);gap:10px}.fld,.fld--wide,.fld--short{grid-column:span 6;min-width:0}.f-actions{justify-content:stretch;flex-wrap:wrap;gap:10px}.btn-primary,.btn-ghost{flex:1 1 auto}}

  /* toast */
  #toast{position:fixed;left:50%;bottom:24px;transform:translateX(-50%);background:#111;color:#fff;padding:10px 14px;border-radius:12px;border:1px solid #333;display:none;z-index:9999}

	/* === MODALE GESTIONE RESO (light style) === */
#reso-modal .modal {
  background: #fff;
  color: #111;
  border-radius: 18px;
  border: 1px solid #ddd;
  box-shadow: 0 14px 36px rgba(0,0,0,.25);
  padding-bottom: 12px;
}

#reso-modal header {
  background: #f8f9fc;
  border-bottom: 1px solid #eee;
  padding: 14px 18px;
  border-radius: 18px 18px 0 0;
}

#reso-modal h2 {
  margin: 0;
  font-size: 20px;
  font-weight: 800;
  color: #111;
}

#reso-modal .content {
  padding: 18px;
}

/* campi form */
#reso-modal label {
  display: block;
  font-size: 13px;
  font-weight: 700;
  color: #333;
  margin: 8px 0 4px;
}

#reso-modal .sel,
#reso-modal textarea,
#reso-modal input[type="number"] {
  width: 100%;
  padding: 10px 12px;
  border-radius: 12px;
  border: 1px solid #ccc;
  background: #fafafa;
  color: #111;
  font-weight: 600;
  resize: vertical;
  transition: border-color .15s ease, background .15s ease;
}

#reso-modal .sel:focus,
#reso-modal textarea:focus,
#reso-modal input[type="number"]:focus {
  border-color: #003366;
  background: #fff;
  outline: none;
}

/* bottone salva */
#reso-modal button[type="submit"] {
  margin-top: 12px;
  background: linear-gradient(180deg, #ffffff, #e6ecff);
  color: #0c0c12;
  font-weight: 800;
  border: 1px solid #bbb;
  border-radius: 12px;
  padding: 10px 18px;
  cursor: pointer;
  transition: filter .15s ease, transform .05s ease;
}
#reso-modal button[type="submit"]:hover {
  filter: brightness(1.05);
}
#reso-modal button[type="submit"]:active {
  transform: translateY(1px);
}

/* motivo cliente */
#reso-modal #r-motivo {
  background: #f5f5f5;
  border: 1px solid #ddd;
  border-radius: 10px;
  padding: 8px 10px;
  margin-top: 4px;
  font-size: 14px;
  color: #111;
}
	/* Assicura che padding/border non facciano "sbordare" gli input */
#reso-modal *, 
#reso-modal *::before, 
#reso-modal *::after {
  box-sizing: border-box;
}

/* Il modale non deve superare lo schermo e deve scrollare internamente */
#reso-modal .modal {
  max-height: calc(100vh - 40px);   /* margine respiro */
  overflow: auto;                    /* scroll interno */
  -webkit-overflow-scrolling: touch; /* scroll fluido su iOS */
}

/* Evita overflow orizzontale sugli input/textarea/select */
#reso-modal .sel,
#reso-modal textarea,
#reso-modal input[type="number"],
#reso-modal input[type="text"],
#reso-modal select {
  display: block;
  width: 100%;
  max-width: 100%;   /* non oltre il contenitore */
}

/* Se la textarea cresce troppo in altezza, limita e rendi scrollabile */
#reso-modal textarea {
  max-height: 40vh;
  overflow: auto;
  resize: vertical;
}

/* Su schermi piccoli il padding interno è più contenuto */
@media (max-width: 640px) {
  #reso-modal .content { padding: 14px; }
}
	
</style>
</head>
<body>
<%
  String flashOk = (String) session.getAttribute("flashOk");
  String flashError = (String) session.getAttribute("flashError");
  if (flashOk != null) session.removeAttribute("flashOk");
  if (flashError != null) session.removeAttribute("flashError");
%>

<div class="page">
  <%@ include file="header.jspf" %>

  <h1><i class="fa-solid fa-truck-fast"></i> Gestione Ordini</h1>

  <div class="filters">
    <form method="get" action="<%=ctx%>/admin/ordini" id="filterForm">
      <div class="fld fld--wide">
        <label><i class="fa-solid fa-sort"></i> Ordina per</label>
        <select name="order" class="sel" onchange="this.form.submit()">
          <option value="dateDesc"  <%= "dateDesc".equals(order)  ? "selected":"" %>>Data: dal più recente</option>
          <option value="dateAsc"   <%= "dateAsc".equals(order)   ? "selected":"" %>>Data: dal meno recente</option>
          <option value="priceDesc" <%= "priceDesc".equals(order) ? "selected":"" %>>Prezzo: dal più alto</option>
          <option value="priceAsc"  <%= "priceAsc".equals(order)  ? "selected":"" %>>Prezzo: dal più basso</option>
        </select>
      </div>

      <div class="fld">
        <label><i class="fa-solid fa-truck-fast"></i> Spedizione</label>
        <select name="stato" class="sel" onchange="this.form.submit()">
          <option value="" <%= (statoFilter == null || statoFilter.isEmpty()) ? "selected": "" %>>Tutte</option>
          <option value="IN_ELABORAZIONE" <%= "IN_ELABORAZIONE".equals(statoFilter)?"selected":"" %>>In elaborazione</option>
          <option value="IN_TRANSITO"     <%= "IN_TRANSITO".equals(statoFilter)?"selected":"" %>>In transito</option>
          <option value="CONSEGNATO"      <%= "CONSEGNATO".equals(statoFilter)?"selected":"" %>>Consegnato</option>
        </select>
      </div>

      <div class="fld">
        <label><i class="fa-solid fa-money-check-dollar"></i> Pagamento</label>
        <select name="pay" class="sel" onchange="this.form.submit()">
          <option value="" <%= (payFilter == null || payFilter.isEmpty()) ? "selected": "" %>>Tutti</option>
          <option value="CARTA"  <%= "CARTA".equalsIgnoreCase(String.valueOf(payFilter)) ? "selected": "" %>>Carta</option>
          <option value="PAYPAL" <%= "PAYPAL".equalsIgnoreCase(String.valueOf(payFilter)) ? "selected": "" %>>PayPal</option>
          <option value="COD"    <%= "COD".equalsIgnoreCase(String.valueOf(payFilter)) ? "selected": "" %>>Contrassegno</option>
        </select>
      </div>

      <div class="fld fld--short">
        <label><i class="fa-regular fa-calendar"></i> Dal</label>
        <input type="date" name="from" class="inp" value="<%= fromFilter != null ? fromFilter : "" %>">
      </div>

      <div class="fld fld--short">
        <label><i class="fa-regular fa-calendar-days"></i> Al</label>
        <input type="date" name="to" class="inp" value="<%= toFilter != null ? toFilter : "" %>">
      </div>

      <div class="fld fld--wide">
        <label><i class="fa-solid fa-user"></i> Cliente</label>
        <input type="text" name="cliente" class="inp" placeholder="nome, username o email"
               value="<%= clienteQ != null ? clienteQ : "" %>">
      </div>

      <div class="f-actions">
        <button class="btn-ghost btn-icon" type="button" id="resetFilters">
          <i class="fa-solid fa-rotate-left"></i> Reset
        </button>
        <button class="btn-primary btn-icon" type="submit">
          <i class="fa-solid fa-filter"></i> Applica filtri
        </button>
      </div>
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

          <!-- Stato Reso (se presente) + Gestione -->
          <% if (o.resoRichiesto) { %>
        	<a href="javascript:void(0)" class="btn" style="margin-top:8px;background:#fff;color:#111;border-color:#bbb"
           	onclick="openReso(<%= o.id %>)">
          	<i class="fa-solid fa-rotate-left"></i> Gestisci reso
        	</a>
      		<% } %>


          <a href="javascript:void(0)" class="btn" style="margin-top:8px" onclick="openOrderAdminDetails(<%= o.id %>)">
            <i class="fa-solid fa-eye"></i> Dettagli
          </a>

          <form method="post" action="<%=ctx%>/admin/ordini/delete" style="margin-top:8px" onsubmit="return confirmDelete(<%= o.id %>)">
            <input type="hidden" name="id" value="<%= o.id %>">
            <label style="display:inline-flex;gap:6px;align-items:center;font-size:12px;color:#555">
              <input type="checkbox" name="restock" value="1"> Ripristina stock
            </label>
            <button type="submit" class="btn" style="background:#fff0f0;border-color:#f3b0b0;color:#9d0000;margin-left:8px">
              <i class="fa-solid fa-trash"></i> Elimina
            </button>
          </form>

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

<!-- MODALE GESTIONE RESO -->
<div id="reso-modal" class="modal-backdrop" aria-hidden="true">
  <div class="modal" role="dialog" aria-modal="true" aria-labelledby="reso-title">
    <header>
      <h2 id="reso-title">Gestione Reso</h2>
      <button type="button" class="btn" id="reso-close">Chiudi</button>
    </header>
    <div class="content">
      <div id="reso-loading">Caricamento…</div>
      <div id="reso-error" style="display:none;color:#a10000;background:#ffefef;border:1px solid #ffb3b3;padding:8px;border-radius:10px"></div>

      <div id="reso-body" style="display:none">
        <div class="row" style="justify-content:space-between">
          <div>Ordine #<span id="r-ordine"></span></div>
          <div>Stato attuale: <span class="badge" id="r-stato"></span></div>
        </div>

        <div style="margin:10px 0">
          <div class="muted">Motivo cliente:</div>
          <div id="r-motivo" style="white-space:pre-wrap"></div>
        </div>

        <form id="reso-form" onsubmit="return saveReso(event)">
          <input type="hidden" id="r-ordineId" value="">
          <label>Nuovo stato</label>
          <select id="r-new-stato" class="sel">
            <option>RICHIESTO</option>
            <option>APPROVATO</option>
            <option>RIFIUTATO</option>
            <option>RICEVUTO</option>
            <option>RIMBORSATO</option>
            <option>ANNULLATO</option>
          </select>

          <label style="margin-top:8px">Importo rimborso (€)</label>
          <input type="number" step="0.01" id="r-refund" class="sel" placeholder="0.00">

          <label style="margin-top:8px">Note interne</label>
          <textarea id="r-note" rows="3" class="sel" placeholder="Note visibili solo all'admin"></textarea>

          <div style="margin-top:12px;text-align:right">
            <button type="submit" class="btn"><i class="fa-solid fa-save"></i> Salva</button>
          </div>
        </form>
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

  // Modale dettaglio ordine
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

  // conferma delete
  window.confirmDelete = function(id){
    return confirm('Eliminare definitivamente l\'ordine #' + id + '?\nQuesta azione non è reversibile.');
  };

  // ---------- GESTIONE RESO (ADMIN) ----------
  var Rmodal = document.getElementById('reso-modal');
  var Rclose = document.getElementById('reso-close');
  var Rload  = document.getElementById('reso-loading');
  var Rerr   = document.getElementById('reso-error');
  var Rbody  = document.getElementById('reso-body');

  function rOpen(){ Rmodal.classList.add('open'); Rmodal.setAttribute('aria-hidden','false'); }
  function rClose(){ Rmodal.classList.remove('open'); Rmodal.setAttribute('aria-hidden','true'); }
  Rclose.addEventListener('click', rClose);
  Rmodal.addEventListener('click', function(e){ if (e.target === Rmodal) rClose(); });

  window.openReso = async function(ordineId){
    document.getElementById('r-ordineId').value = ordineId;
    document.getElementById('r-ordine').textContent = ordineId;

    Rload.style.display = 'block';
    Rerr.style.display  = 'none';
    Rbody.style.display = 'none';
    rOpen();
    try{
      const res = await fetch(ctx + '/admin/reso?ordineId=' + encodeURIComponent(ordineId),
                              { headers:{ 'Accept':'application/json' }});
      const js  = await res.json();
      if (!res.ok || !js.success){
        throw new Error(js.error || ('HTTP ' + res.status));
      }
      const d = js.data;

      document.getElementById('r-stato').textContent = d.stato || '-';
      document.getElementById('r-motivo').textContent = d.motivo || '-';
      document.getElementById('r-new-stato').value = d.stato || 'RICHIESTO';
      document.getElementById('r-refund').value = (d.refund != null ? d.refund : 0);
      document.getElementById('r-note').value = d.note || '';

      var cell = document.getElementById('reso-state-' + ordineId);
      if (cell) cell.textContent = d.stato || '—';

      Rload.style.display = 'none';
      Rbody.style.display = 'block';
    }catch(err){
      Rload.style.display = 'none';
      Rerr.textContent = 'Impossibile caricare il reso: ' + err.message;
      Rerr.style.display = 'block';
    }
  };

  window.saveReso = async function(ev){
    ev.preventDefault();
    const ordineId = document.getElementById('r-ordineId').value;
    const stato    = document.getElementById('r-new-stato').value;
    const refund   = document.getElementById('r-refund').value;
    const note     = document.getElementById('r-note').value;

    const body = new URLSearchParams();
    body.set('ordineId', ordineId);
    body.set('stato', stato);
    if (refund && refund.trim() !== '') body.set('refund_amount', refund);
    if (note) body.set('note', note);

    try{
      const res = await fetch(ctx + '/admin/reso/update', {
        method:'POST',
        headers:{ 'Content-Type':'application/x-www-form-urlencoded' },
        body: body.toString()
      });
      const js = await res.json().catch(()=>({success:false,error:'Risposta non valida'}));
      if (!res.ok || !js.success) throw new Error(js.error || ('HTTP ' + res.status));

      document.getElementById('r-stato').textContent = stato;
      var cell = document.getElementById('reso-state-' + ordineId);
      if (cell) cell.textContent = stato;

      showToast('Reso aggiornato');
      rClose();
    }catch(err){
      alert('Errore salvataggio reso: ' + err.message);
    }
  };
})();
</script>

<script>
(function(){
  const form = document.getElementById('filterForm');
  const from = form.querySelector('input[name="from"]');
  const to   = form.querySelector('input[name="to"]');
  const resetBtn = document.getElementById('resetFilters');

  function syncDates(){
    if (from.value) to.min = from.value; else to.removeAttribute('min');
    if (to.value)   from.max = to.value; else from.removeAttribute('max');
  }
  from.addEventListener('change', syncDates);
  to.addEventListener('change', syncDates);
  syncDates();

  from.addEventListener('change', ()=>form.submit());
  to.addEventListener('change', ()=>form.submit());
  form.cliente && form.cliente.addEventListener('keydown', e=>{
    if(e.key==='Enter'){ e.preventDefault(); form.submit(); }
  });

  resetBtn.addEventListener('click', ()=>{
    ['order','stato','pay','from','to','cliente'].forEach(n=>{
      const el = form.elements[n];
      if(!el) return;
      if (el.tagName==='SELECT') el.selectedIndex = 0;
      else el.value = '';
    });
    form.submit();
  });
})();
</script>

</body>
</html>
