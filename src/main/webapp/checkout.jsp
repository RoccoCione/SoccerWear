<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Cart,model.CartItem,java.util.*" %>

<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <title>Checkout • SoccerWear</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.5.2/css/all.min.css" />
  <style>
    :root{ --bg:#111; --panel:#fff; --ring:#ddd; --ink:#111; --muted:#555; --focus:#003366; --radius:16px; }
    *{box-sizing:border-box}
    body{margin:0;background:#111;color:#fff;font-family:"Inter",system-ui,Segoe UI,Roboto,Arial,sans-serif}
    .page{min-height:100vh;padding:28px 28px 80px;background:linear-gradient(180deg,#1a1a1a,#0d0d0d)}
    .container{max-width:1100px;margin:0 auto;display:grid;grid-template-columns:1.2fr .8fr;gap:18px}
    @media (max-width: 960px){ .container{grid-template-columns:1fr; } }
    .card{background:#fff;color:#111;border:1px solid #ddd;border-radius:16px;padding:18px}
    h1{font-weight:900;margin:10px 0 20px}
    .msg-err{background:#ffefef;color:#a10000;border:1px solid #ffb3b3;padding:10px 12px;border-radius:12px;margin-bottom:14px}
    label{font-weight:700;font-size:14px;color:#333;margin-bottom:6px;display:block}
    input[type=text], input[type=number]{width:100%;padding:10px;border:1px solid #ccc;border-radius:10px}
    .grid2{display:grid;grid-template-columns:1fr 1fr;gap:12px}
    .btn{padding:12px 16px;border-radius:12px;border:1px solid #2c2c39;background:#111;color:#fff;font-weight:800;cursor:pointer}
    .btn:hover{filter:brightness(1.1)}
    .right .row{display:flex;justify-content:space-between;margin:6px 0}
    .price{color:#003366;font-weight:900}
    table{width:100%;border-collapse:collapse}
    th,td{padding:10px;border-bottom:1px solid #eee;text-align:left}
    th{color:#003366;font-weight:900}

    /* Payment group */
    .section{margin-top:16px}
    .pay-group{display:grid;gap:10px;margin-top:6px}
    .radio-tile{display:flex;align-items:center;gap:10px;border:1px solid #ddd;border-radius:12px;padding:12px;cursor:pointer}
    .radio-tile:hover{border-color:#bbb}
    .radio-tile input{accent-color:#003366;transform:scale(1.1)}
    .radio-tile i{color:#003366}
    .hint{color:#666;font-size:12px;margin-top:4px}

    /* Modal */
    .modal-backdrop{position:fixed;inset:0;background:rgba(0,0,0,.6);display:none;align-items:center;justify-content:center;z-index:1000}
    .modal{background:#fff;color:#111;border-radius:16px;max-width:520px;width:92%;border:1px solid #ddd;box-shadow:0 14px 40px rgba(0,0,0,.35)}
    .modal header{display:flex;align-items:center;justify-content:space-between;padding:16px 18px;border-bottom:1px solid #eee}
    .modal h2{margin:0;font-size:20px;font-weight:900}
    .modal .content{padding:16px 18px;display:grid;gap:12px}
    .modal .grid2{grid-template-columns:1fr 1fr}
    .modal .actions{display:flex;gap:10px;justify-content:flex-end;padding:12px 18px;border-top:1px solid #eee}
    .modal .btn.secondary{background:#fff;color:#111;border:1px solid #ccc}
    .modal .error{background:#ffefef;border:1px solid #ffb3b3;color:#a10000;padding:8px 10px;border-radius:10px;display:none}
    .modal-backdrop.open{display:flex}
    /* Modal carta centrato */
    #cc-modal{
      position:fixed; inset:0; background:rgba(0,0,0,.6);
      z-index:1000; display:none; align-items:center; justify-content:center; padding:24px;
    }
    #cc-modal.open{ display:flex; }
    .cc-dialog{
      background:#fff; color:#111; width:100%; max-width:520px;
      border-radius:16px; overflow:hidden; border:1px solid #ddd; box-shadow:0 14px 40px rgba(0,0,0,.35);
    }
    .cc-header{display:flex;align-items:center;justify-content:space-between;padding:14px 16px;border-bottom:1px solid #eee}
    .cc-content{padding:16px}
    .cc-grid2{display:grid;grid-template-columns:1fr 1fr;gap:10px}
    .cc-error{display:none;background:#ffefef;color:#a10000;border:1px solid #ffb3b3;padding:10px;border-radius:10px;margin-top:6px}
  </style>
</head>
  </style>
</head>
<body>
<div class="page">
  <%@ include file="header.jspf" %>
  <%
    Cart cart = (Cart) session.getAttribute("cart");
    if (cart == null || cart.isEmpty()) {
      response.sendRedirect(ctx + "/catalogo.jsp"); return;
    }
    String flashError = (String) session.getAttribute("flashError");
    if (flashError != null) session.removeAttribute("flashError");
  %>

  <div class="container">
    <!-- Indirizzo + Pagamento -->
    <div class="card">
      <h1><i class="fa-solid fa-location-dot"></i> Spedizione</h1>
      <% if (flashError != null) { %><div class="msg-err"><%=flashError%></div><% } %>

      <form id="checkout-form" method="post" action="<%=ctx%>/checkout/submit">
        <input type="hidden" name="_csrf" value="${sessionScope.csrf}"/>

        <label>Indirizzo</label>
        <input type="text" name="indirizzo" required>
        <div class="grid2">
          <div>
            <label>CAP</label>
            <input type="text" name="cap" required>
          </div>
          <div>
            <label>Numero civico</label>
            <input type="text" name="numero_civico" required>
          </div>
        </div>
        <label>Città</label>
        <input type="text" name="citta" required>

        <!-- =================== PAGAMENTO =================== -->
        <div class="section">
          <h1 style="margin-top:18px"><i class="fa-solid fa-credit-card"></i> Pagamento</h1>

          <label>Scegli un metodo</label>
          <div class="pay-group">
            <label class="radio-tile">
              <input type="radio" name="payment_method" value="CARTA" id="pm-carta" checked>
              <i class="fa-solid fa-credit-card"></i>
              <div>
                <div style="font-weight:700">Carta di credito/debito</div>
                <div class="hint">Inserisci i dati della carta.</div>
              </div>
            </label>

            <label class="radio-tile">
              <input type="radio" name="payment_method" value="PAYPAL" id="pm-paypal">
              <i class="fa-brands fa-paypal"></i>
              <div>
                <div style="font-weight:700">PayPal</div>
                <div class="hint">Nessun dato aggiuntivo richiesto.</div>
              </div>
            </label>

            <label class="radio-tile">
              <input type="radio" name="payment_method" value="COD" id="pm-cod">
              <i class="fa-solid fa-truck"></i>
              <div>
                <div style="font-weight:700">Contrassegno</div>
                <div class="hint">Paghi alla consegna.</div>
              </div>
            </label>
          </div>

          <!-- Pulsante/avviso solo per CARTA -->
          <div id="cc-inline-btn-wrap" style="margin-top:10px">
            <button type="button" class="btn" id="cc-open-inline">
              <i class="fa-solid fa-credit-card"></i> Inserisci dati carta
            </button>
            <div class="hint">Obbligatorio per completare il pagamento con carta.</div>
          </div>

          <!-- Hidden popolati dal modale -->
          <input type="hidden" name="card_number" id="card_number">
          <input type="hidden" name="card_circuit" id="card_circuit">
        </div>

        <!-- =================== MODALE CARTA =================== -->
        <div id="cc-modal" class="modal-backdrop" aria-hidden="true">
          <div class="modal" role="dialog" aria-modal="true" aria-labelledby="cc-title">
            <header>
              <h2 id="cc-title"><i class="fa-solid fa-credit-card"></i> Dati carta</h2>
              <button type="button" id="cc-close" class="btn" style="padding:6px 10px">Chiudi</button>
            </header>
            <div class="content">
              <div class="error" id="cc-error"></div>

              <label>
                <div style="font-weight:700;font-size:14px;margin-bottom:6px">Numero carta</div>
                <input type="text" id="cc-num" inputmode="numeric" autocomplete="off" placeholder="4111 1111 1111 1111"
                       maxlength="19" style="width:100%;padding:10px;border:1px solid #ccc;border-radius:10px">
              </label>

              <div class="grid2">
                <label>
                  <div style="font-weight:700;font-size:14px;margin-bottom:6px">Scadenza (MM/YY)</div>
                  <input type="text" id="cc-exp" placeholder="12/29"
                         style="width:100%;padding:10px;border:1px solid #ccc;border-radius:10px">
                </label>
                <label>
                  <div style="font-weight:700;font-size:14px;margin-bottom:6px">CVV</div>
                  <input type="text" id="cc-cvv" inputmode="numeric" placeholder="123"
                         style="width:100%;padding:10px;border:1px solid #ccc;border-radius:10px">
                </label>
              </div>

              <label>
                <div style="font-weight:700;font-size:14px;margin-bottom:6px">Circuito</div>
                <select id="cc-circuit" style="width:100%;padding:10px;border:1px solid #ccc;border-radius:10px;background:#fff">
                  <option value="">-- Seleziona --</option>
                  <option value="VISA">VISA</option>
                  <option value="MASTERCARD">Mastercard</option>
                  <option value="AMEX">American Express</option>
                </select>
              </label>
            </div>
            <div class="actions">
              <button type="button" class="btn secondary" id="cc-cancel">Annulla</button>
              <button type="button" class="btn" id="cc-save"><i class="fa-solid fa-check"></i> Salva dati carta</button>
            </div>
          </div>
        </div>

        <div style="margin-top:16px;display:flex;gap:10px;align-items:center">
          <a class="btn" href="<%=ctx%>/carrello.jsp"><i class="fa-solid fa-arrow-left"></i> Torna al carrello</a>
          <button class="btn" type="submit"><i class="fa-solid fa-check"></i> Conferma e paga</button>
        </div>
      </form>
    </div>

    <!-- Riepilogo ordine -->
    <div class="card right">
      <h1><i class="fa-solid fa-receipt"></i> Riepilogo</h1>
      <table>
        <thead><tr><th>Articolo</th><th>Taglia</th><th>Q.tà</th><th>Totale</th></tr></thead>
        <tbody>
        <%
          for (CartItem it : cart.getItems()) {
        %>
          <tr>
            <td><strong><%=it.getNome()%></strong></td>
            <td><%=it.getTaglia()%></td>
            <td><%=it.getQuantita()%></td>
            <td class="price"><%= String.format(java.util.Locale.ITALY,"%.2f", it.getTotaleRigaLordo()) %> €</td>
          </tr>
        <% } %>
        </tbody>
      </table>

      <div style="height:10px"></div>
      <div class="row"><span>Subtotale</span><span class="price"><%= String.format(java.util.Locale.ITALY,"%.2f", cart.getSubtotaleNetto()) %> €</span></div>
      <div class="row"><span>IVA</span><span class="price"><%= String.format(java.util.Locale.ITALY,"%.2f", cart.getTotaleIva()) %> €</span></div>
      <div class="row" style="font-size:18px;"><span>Totale</span><span class="price"><%= String.format(java.util.Locale.ITALY,"%.2f", cart.getTotaleLordo()) %> €</span></div>
    </div>
  </div>

  <%@ include file="footer.jspf" %>
</div>

<script>
(function(){
  const pmRadios = document.querySelectorAll('input[name="payment_method"]');
  const ccBtnWrap = document.getElementById('cc-inline-btn-wrap');
  const btnOpen = document.getElementById('cc-open-inline');

  const modal = document.getElementById('cc-modal');
  const btnClose = document.getElementById('cc-close');
  const btnCancel = document.getElementById('cc-cancel');
  const btnSave = document.getElementById('cc-save');
  const errBox = document.getElementById('cc-error');

  const inNum = document.getElementById('cc-num');
  const inExp = document.getElementById('cc-exp');
  const inCvv = document.getElementById('cc-cvv');
  const inCirc = document.getElementById('cc-circuit');

  const outNum = document.getElementById('card_number');
  const outCirc = document.getElementById('card_circuit');

  function show(el){ el.style.display='block'; el.classList.add('open'); el.setAttribute('aria-hidden','false'); }
  function hide(el){ el.style.display='none'; el.classList.remove('open'); el.setAttribute('aria-hidden','true'); }

  function isCardSelected(){
    const sel = document.querySelector('input[name="payment_method"]:checked');
    return sel && sel.value === 'CARTA';
  }
  function toggleCardUi(){ if (isCardSelected()) show(ccBtnWrap); else hide(ccBtnWrap); }
  function openModal(){ show(modal); }
  function closeModal(){ hide(modal); errBox.textContent=''; hide(errBox); }

  // helpers
  const onlyDigits = s => String(s||'').replace(/\D+/g,'');
  const validPan   = pan => onlyDigits(pan).length >= 12;        // mock
  const validExp   = exp => /^\d{2}\/\d{2}$/.test((exp||'').trim());
  const validCvv   = cvv => /^\d{3,4}$/.test((cvv||'').trim());

  btnSave.addEventListener('click', function(){
    const pan = onlyDigits(inNum.value);
    const exp = inExp.value.trim();
    const cvv = inCvv.value.trim();
    const circ = inCirc.value.trim();

    if (!validPan(pan)) { errBox.textContent = 'Numero carta non valido.'; show(errBox); return; }
    if (!validExp(exp)) { errBox.textContent = 'Scadenza non valida (usa MM/YY).'; show(errBox); return; }
    if (!validCvv(cvv)) { errBox.textContent = 'CVV non valido.'; show(errBox); return; }
    if (!circ)          { errBox.textContent = 'Seleziona un circuito.'; show(errBox); return; }

    outNum.value = pan;
    outCirc.value = circ;
    closeModal();
  });

  btnOpen.addEventListener('click', openModal);
  btnClose.addEventListener('click', closeModal);
  btnCancel.addEventListener('click', closeModal);
  modal.addEventListener('click', (e)=>{ if (e.target === modal) closeModal(); });

  pmRadios.forEach(r => r.addEventListener('change', toggleCardUi));
  toggleCardUi();

  // Blocca submit se CARTA e dati non salvati
  const form = document.getElementById('checkout-form');
  form.addEventListener('submit', function(e){
    if (isCardSelected() && (!outNum.value || !outCirc.value)) {
      e.preventDefault();
      openModal();
    }
  });

  // formattazione numero carta
  inNum.addEventListener('input', function(){
    const d = onlyDigits(inNum.value).slice(0,19);
    inNum.value = d.replace(/(.{4})/g,'$1 ').trim();
  });
})();
</script>

</body>
</html>
