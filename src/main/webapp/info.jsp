<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Info • SoccerWear</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.5.2/css/all.min.css" />
  <style>
    :root{ --ink:#f2f2f2; --muted:#cfcfd4; --ring:#2c2c39; --panel:#1a1a1f; --soft:#0f0f12; --radius:16px; }
    *{box-sizing:border-box}
    body{margin:0;background:#111;color:var(--ink);font-family:Inter,system-ui,sans-serif}
    .page{min-height:100vh;padding:28px;background:linear-gradient(180deg,#1a1a1a,#0d0d0d)}
    .container{max-width:1100px;margin:0 auto;display:grid;gap:18px}
    .card{background:var(--panel);border:1px solid #2c2c39;border-radius:16px;padding:18px}
    h1{margin:0 0 10px;font-weight:900;color:#fff}
    h2{margin:0 0 12px;color:#fff}
    p{color:#e5e5ea;line-height:1.6}
    .grid-2{display:grid;grid-template-columns:1fr 1fr;gap:18px}
    @media (max-width: 900px){ .grid-2{grid-template-columns:1fr} }
    .list{margin:0;padding-left:18px;color:#ddd}
    /* FAQ */
    .faq{display:grid;gap:10px}
    .faq .item{border:1px solid #2c2c39;background:#121217;border-radius:14px;overflow:hidden;color:#fff}
    .faq summary{cursor:pointer;padding:14px 16px;font-weight:800;list-style:none}
    .faq summary::-webkit-details-marker{display:none}
    .faq .content{padding:0 16px 14px;color:#d9d9e2}
    /* Contatto */
    label{font-size:14px;color:#cfcfd4;margin-bottom:6px;display:block}
    input,textarea{width:100%;padding:12px;border-radius:12px;border:1px solid #2c2c39;background:#0f0f12;color:#fff}
    textarea{min-height:120px;resize:vertical}
    .btn{padding:12px 16px;border-radius:12px;border:1px solid var(--ring);background:#fff;color:#111;font-weight:900;cursor:pointer}
    .btn:hover{filter:brightness(1.06)}
    .muted{color:#cfcfd4}
    /* toast minimal */
    #toast{position:fixed;left:50%;bottom:24px;transform:translateX(-50%);display:none;
           background:#121217;border:1px solid #2c2c39;border-radius:14px;color:#fff;padding:10px 14px;z-index:9999}
  </style>
</head>
<body>
<div class="page">
  <%@ include file="header.jspf" %>

  <div class="container">
    <header class="card">
      <h1><i class="fa-solid fa-circle-info"></i> Informazioni</h1>
      <p>Benvenuto su <strong>SoccerWear</strong>. Siamo un e-commerce dedicato alle maglie da calcio: campionati nazionali, nazionali e selezione vintage. Qualità, sicurezza nei pagamenti e spedizioni rapide.</p>
    </header>

    <section class="grid-2">
      <article class="card">
        <h2><i class="fa-solid fa-truck-fast"></i> Spedizioni & Resi</h2>
        <ul class="list">
          <li>Spedizione in 24/48h lavorative (tracking incluso).</li>
          <li>Reso entro 14 giorni: prodotto in condizioni originali.</li>
          <li>Assistenza dedicata per taglie e personalizzazioni.</li>
        </ul>
      </article>

      <article class="card">
        <h2><i class="fa-solid fa-shield-halved"></i> Pagamenti</h2>
        <ul class="list">
          <li>Carta (Visa, Mastercard, Amex).</li>
          <li>PayPal.</li>
          <li>Contrassegno (paghi alla consegna).</li>
        </ul>
        <p class="muted">I pagamenti sono gestiti su canali sicuri. I dati sensibili non vengono memorizzati sui nostri server.</p>
      </article>
    </section>

    <section class="card">
      <h2><i class="fa-solid fa-circle-question"></i> FAQ</h2>
      <div class="faq">
        <details class="item">
          <summary>Come scelgo la taglia corretta?</summary>
          <div class="content">Consulta la guida taglie nella pagina prodotto. In caso di dubbi, contattaci prima dell’ordine.</div>
        </details>
        <details class="item">
          <summary>Posso personalizzare nome/numero?</summary>
          <div class="content">Sì, dove indicato. Le personalizzazioni potrebbero allungare i tempi di spedizione di 1–2 giorni.</div>
        </details>
        <details class="item">
          <summary>Quanto impiega il reso?</summary>
          <div class="content">Una volta ricevuto e verificato il prodotto, il rimborso avviene in 3–5 giorni lavorativi.</div>
        </details>
      </div>
    </section>

    <section class="card">
      <h2><i class="fa-solid fa-envelope"></i> Contattaci</h2>
      <form id="contact-form" action="<%=request.getContextPath()%>/contatti" method="post" novalidate>
        <input type="hidden" name="_csrf" value="${sessionScope.csrf}">
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
          <div>
            <label>Nome</label>
            <input type="text" name="nome" required placeholder="Mario">
          </div>
          <div>
            <label>Email</label>
            <input type="text" name="email" required placeholder="mario.rossi@email.com">
          </div>
        </div>
        <div style="margin-top:10px">
          <label>Messaggio</label>
          <textarea name="messaggio" required placeholder="Come possiamo aiutarti?"></textarea>
        </div>
        <div style="margin-top:12px"><button class="btn" type="submit">Invia</button></div>
      </form>
      <p class="muted" style="margin-top:10px"><i class="fa-solid fa-location-dot"></i> Bagnoli Irpino (AV) – Italy</p>
    </section>

    <section class="card">
      <h2><i class="fa-solid fa-map"></i> Dove siamo</h2>
      <div style="aspect-ratio:16/9;border:1px solid #2c2c39;border-radius:12px;background:#0f0f12;display:grid;place-items:center">
        <span class="muted">Mappa (embed) – opzionale</span>
      </div>
    </section>
  </div>

  <%@ include file="footer.jspf" %>
</div>

<div id="toast" role="status" aria-live="polite"></div>
<script>
(function(){
  const form = document.getElementById('contact-form');
  const toast = document.getElementById('toast');
  const emailRe = /^[\w.+-]+@[\w-]+\.[\w.-]{2,}$/;

  function showToast(t){ toast.textContent=t; toast.style.display='block';
    setTimeout(()=>toast.style.display='none', 2200); }

  form.addEventListener('submit', function(e){
    const fd = new FormData(form);
    const nome = (fd.get('nome')||'').trim();
    const mail = (fd.get('email')||'').trim();
    const msg  = (fd.get('messaggio')||'').trim();

    if (!nome || !emailRe.test(mail) || msg.length<5) {
      e.preventDefault();
      showToast('Controlla i campi e riprova.');
    }
  });
})();
</script>
</body>
</html>
