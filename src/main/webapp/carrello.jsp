<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Cart,model.CartItem,java.util.*" %>
<%
  Cart cart = (Cart) session.getAttribute("cart");
  if (cart == null) { cart = new model.Cart(); session.setAttribute("cart", cart); }
  String flashError = (String) session.getAttribute("flashError");
  if (flashError != null) session.removeAttribute("flashError");
%>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <title>Carrello • SoccerWear</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.5.2/css/all.min.css" />
  <style>
    :root { --bg:#111; --panel:#fff; --ring:#ddd; --ink:#111; --muted:#555; --focus:#003366; --radius:16px; }
    *{box-sizing:border-box}
    body{margin:0;background:#111;color:#fff;font-family:"Inter",system-ui,Segoe UI,Roboto,Arial,sans-serif}
    .page{min-height:100vh;padding:28px 28px 80px;background:linear-gradient(180deg,#1a1a1a,#0d0d0d)}

    .container{max-width:1100px;margin:0 auto}

    .card{background:#fff;color:#111;border:1px solid #ddd;border-radius:16px;padding:18px}
    h1{font-weight:900;margin:10px 0 20px}
    .msg-err{background:#ffefef;color:#a10000;border:1px solid #ffb3b3;padding:10px 12px;border-radius:12px;margin-bottom:14px}

    table{width:100%;border-collapse:collapse}
    th,td{padding:12px;border-bottom:1px solid #eee;text-align:left;vertical-align:middle}
    th{color:#003366;font-weight:900}
    .qty-input{width:70px;padding:8px;border:1px solid #ccc;border-radius:10px}
    .actions-row form{display:inline}
    .btn{padding:10px 14px;border-radius:12px;border:1px solid #2c2c39;background:#fff;color:#111;font-weight:800;cursor:pointer}
    .btn:hover{background:#111;color:#fff}
    .btn-danger{border-color:#cc0000;color:#cc0000;background:#fff}
    .btn-danger:hover{background:#cc0000;color:#fff}
    .btn-ghost{background:#fff}
    .totals{margin-top:16px;text-align:right}
    .totals div{margin:6px 0}
    .price{color:#003366;font-weight:900}
    
    /* === Migliorie layout & bottoni === */
.card { background:#fff; color:#111; border:1px solid #ddd; border-radius:16px; padding:18px; box-shadow:0 8px 24px rgba(0,0,0,.12); }

.table-wrap { overflow-x:auto; border-radius:12px; }
table { width:100%; border-collapse:collapse; min-width:760px; }
th,td { padding:12px; border-bottom:1px solid #eee; text-align:left; vertical-align:middle; }
th { color:#003366; font-weight:900; }

.qty-input { width:80px; padding:8px; border:1px solid #ccc; border-radius:10px; text-align:center; }

/* Barra bottoni finali */
.checkout-actions {
  margin-top:18px;
  display:flex;
  justify-content:flex-end;
  gap:12px;
  flex-wrap:wrap;
}
@media (max-width: 640px) {
  .checkout-actions { justify-content:stretch; }
  .checkout-actions .btn { flex:1 1 auto; text-align:center; }
}

/* Bottoni */
.btn{padding:10px 14px;border-radius:12px;border:1px solid #2c2c39;background:#fff;color:#111;font-weight:800;cursor:pointer;transition:.15s}
.btn:hover{background:#111;color:#fff}
.btn-primary{background:#111;color:#fff;border-color:#111}
.btn-primary:hover{filter:brightness(1.05)}
.btn-ghost{background:#fff;border-color:#bbb}
.btn-danger{border-color:#cc0000;color:#cc0000;background:#fff}
.btn-danger:hover{background:#cc0000;color:#fff}

/* Totali */
.totals{margin-top:16px;text-align:right}
.totals div{margin:6px 0}
.price{color:#003366;font-weight:900}

/* === Dialoghi personalizzati === */
.dialog-backdrop{
  display:none; position:fixed; inset:0; background:rgba(0,0,0,.6); z-index:2000;
}
.dialog{
  background:#fff; color:#111; width:min(520px,92vw);
  margin:10% auto; border-radius:16px; border:1px solid #ddd; overflow:hidden;
  box-shadow:0 16px 48px rgba(0,0,0,.25);
}
.dialog-header{
  padding:16px 18px; border-bottom:1px solid #eee; display:flex; align-items:center; gap:10px;
}
.dialog-header .icon{
  width:36px; height:36px; display:inline-flex; align-items:center; justify-content:center;
  border-radius:10px; background:#ffefef; color:#a10000; border:1px solid #ffb3b3;
}
.dialog-body{ padding:16px 18px; color:#333; }
.dialog-footer{
  padding:12px 18px; border-top:1px solid #eee; display:flex; gap:10px; justify-content:flex-end; flex-wrap:wrap;
}
    
  </style>
</head>
<body>
  <div class="page">
  
    <%@ include file="header.jspf" %>

    <div class="container">
      <h1 style="text-align:center;margin-bottom:20px;color:#FFFFFF"><i class="fa-solid fa-cart-shopping"></i> Il tuo carrello</h1>

      <% if (flashError != null) { %>
        <div class="msg-err"><%= flashError %></div>
      <% } %>

      <div class="card">
        <% if (cart.isEmpty()) { %>
          <p style="color:#111;font-weight:900">Il carrello è vuoto. <a href="<%=ctx%>/catalogo.jsp" style="color:#cc0000;font-weight:900">Vai al catalogo</a></p>
        <% } else { %>
          <table>
            <thead>
              <tr>
                <th>Prodotto</th>
                <th>Taglia</th>
                <th>Personalizzazione</th>
                <th>Prezzo</th>
                <th>Q.tà</th>
                <th>Totale riga</th>
                <th>Azioni</th>
              </tr>
            </thead>
            <tbody>
            <%
              List<CartItem> items = cart.getItems();
              for (int i=0; i<items.size(); i++) {
                CartItem it = items.get(i);
            %>
              <tr>
                <td><strong><%= it.getNome() %></strong></td>
                <td><%= it.getTaglia() %></td>
                <td>
                  <% if (it.getNomeRetro()!=null || it.getNumeroRetro()!=null) { %>
                    Nome: <%= it.getNomeRetro()!=null? it.getNomeRetro() : "-" %><br/>
                    Numero: <%= it.getNumeroRetro()!=null? it.getNumeroRetro() : "-" %>
                  <% } else { %>-<% } %>
                </td>
                <td class="price"><%= String.format(java.util.Locale.ITALY,"%.2f", it.getPrezzo()) %> € + <%= String.format(java.util.Locale.ITALY,"%.2f", it.getIva()) %>% IVA</td>
                <td>
                  <form action="<%=ctx%>/cart/update" method="post">
                    <input type="hidden" name="idx" value="<%= i %>">
                    <input type="number" name="quantita" class="qty-input" min="1" value="<%= it.getQuantita() %>">
                    <button type="submit" class="btn">Aggiorna</button>
                  </form>
                </td>
                <td class="price"><%= String.format(java.util.Locale.ITALY,"%.2f", it.getTotaleRigaLordo()) %> €</td>
                <td class="actions-row">
  					<form action="<%=ctx%>/cart/remove" method="post" class="remove-form">
    				<input type="hidden" name="idx" value="<%= i %>">
    				<button type="button" class="btn btn-danger remove-btn" data-idx="<%= i %>">
      				<i class="fa-solid fa-trash"></i>
    				</button>
  					</form>
				</td>
              </tr>
            <% } %>
            </tbody>
          </table>

          <div class="totals">
            <div>Subtotale: <span class="price"><%= String.format(java.util.Locale.ITALY,"%.2f", cart.getSubtotaleNetto()) %> €</span></div>
            <div>IVA: <span class="price"><%= String.format(java.util.Locale.ITALY,"%.2f", cart.getTotaleIva()) %> €</span></div>
            <div style="font-size:20px;">Totale: <span class="price"><%= String.format(java.util.Locale.ITALY,"%.2f", cart.getTotaleLordo()) %> €</span></div>
            <div style="margin-top:12px;">
              <a class="btn btn-ghost" href="<%=ctx%>/catalogo.jsp"><i class="fa-solid fa-arrow-left"></i> Continua a comprare</a>
              <a class="btn" href="<%=ctx%>/checkout.jsp"><i class="fa-solid fa-credit-card"></i> Procedi all’ordine</a>
              <button type="button" class="btn btn-danger" id="btnClearCart">
  				<i class="fa-solid fa-ban"></i> Svuota carrello</button>
            </div>
          </div>
        <% } %>
      </div>
    </div>

    <%@ include file="footer.jspf" %>
  </div>
  
 <script>
  // === Dialoghi custom ===
  function openConfirm(message){
    return new Promise((resolve) => {
      const modal = document.getElementById('confirmDialog');
      const msg   = document.getElementById('confirmMessage');
      const okBtn = document.getElementById('confirmOk');
      const noBtn = document.getElementById('confirmCancel');

      msg.textContent = message || 'Confermi?';
      modal.style.display = 'block';
      modal.setAttribute('aria-hidden','false');

      const close = (ans) => {
        modal.style.display = 'none';
        modal.setAttribute('aria-hidden','true');
        okBtn.onclick = noBtn.onclick = null;
        modal.onclick = null;
        resolve(ans);
      };

      okBtn.onclick = () => close(true);
      noBtn.onclick = () => close(false);
      modal.onclick = (e) => { if (e.target === modal) close(false); };
    });
  }

  function openAlert(message, title){
    const modal = document.getElementById('alertDialog');
    const msg   = document.getElementById('alertMessage');
    const okBtn = document.getElementById('alertOk');
    if (title){
      modal.querySelector('.dialog-header strong').textContent = title;
    }
    msg.textContent = message || '';
    modal.style.display = 'block';
    modal.setAttribute('aria-hidden','false');

    const close = () => {
      modal.style.display = 'none';
      modal.setAttribute('aria-hidden','true');
      okBtn.onclick = null;
      modal.onclick = null;
    };
    okBtn.onclick = close;
    modal.onclick = (e) => { if (e.target === modal) close(); };
  }

  // === Hook rimozione singolo articolo (usa confirm custom) ===
  document.querySelectorAll('.remove-btn').forEach(btn => {
    btn.addEventListener('click', async () => {
      const idx = btn.getAttribute('data-idx');
      const ok = await openConfirm('Rimuovere questo articolo dal carrello?');
      if (ok) {
        // invia la form più vicina
        btn.closest('form').submit();
      }
    });
  });

  // === Hook "Svuota carrello" ===
  const clearBtn = document.getElementById('btnClearCart');
  if (clearBtn) {
    clearBtn.addEventListener('click', async () => {
      const ok = await openConfirm('Svuotare completamente il carrello?');
      if (ok) window.location.href = '<%=ctx%>/cart/clear';
    });
  }
</script>

<!-- Dialogo conferma (riutilizzabile) -->
<div id="confirmDialog" class="dialog-backdrop" role="dialog" aria-modal="true" aria-hidden="true">
  <div class="dialog">
    <div class="dialog-header">
      <div class="icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
      <strong>Confermi l’azione?</strong>
    </div>
    <div class="dialog-body">
      <p id="confirmMessage">Sei sicuro?</p>
    </div>
    <div class="dialog-footer">
      <button type="button" class="btn btn-ghost" id="confirmCancel">Annulla</button>
      <button type="button" class="btn btn-danger" id="confirmOk">Conferma</button>
    </div>
  </div>
</div>

<!-- Dialogo info (per messaggi o piccoli alert) -->
<div id="alertDialog" class="dialog-backdrop" role="dialog" aria-modal="true" aria-hidden="true">
  <div class="dialog">
    <div class="dialog-header">
      <div class="icon" style="background:#eef6ff;border-color:#b6d7ff;color:#0b5ed7">
        <i class="fa-solid fa-circle-info"></i>
      </div>
      <strong>Attenzione</strong>
    </div>
    <div class="dialog-body">
      <p id="alertMessage">Messaggio…</p>
    </div>
    <div class="dialog-footer">
      <button type="button" class="btn btn-primary" id="alertOk">Ok</button>
    </div>
  </div>
</div>
</body>
</html>
