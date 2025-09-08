<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.ProdottoBean, model.UtenteBean, DAO.ProdottoDAO" %>
<%
    
    // Parametri filtro/ordinamento
    String order     = request.getParameter("order");       // priceAsc | priceDesc | null
    String categoria = request.getParameter("categoria");   // SerieA | PremierLeague | LaLiga | Vintage | null
    String size      = request.getParameter("size");        // S | M | L | XL | null

    ProdottoDAO dao = new ProdottoDAO();
    List<ProdottoBean> prodotti;

    // 1) Base list: categoria
    if (categoria != null && !categoria.isBlank()) {
        prodotti = dao.findAllByCategoria(categoria);
    } else {
        prodotti = dao.findAll();
    }

    // 2) Filtro taglia in memoria
    if (size != null && !size.isBlank()) {
        List<ProdottoBean> filtered = new ArrayList<>();
        for (ProdottoBean p : prodotti) {
            if (p.getTaglia() != null && p.getTaglia().equalsIgnoreCase(size)) {
                filtered.add(p);
            }
        }
        prodotti = filtered;
    }

    // 3) Ordinamento prezzo (applicato DOPO i filtri)
    if ("priceAsc".equals(order)) {
        prodotti.sort(Comparator.comparingDouble(ProdottoBean::getCosto));
    } else if ("priceDesc".equals(order)) {
        prodotti.sort(Comparator.comparingDouble(ProdottoBean::getCosto).reversed());
    }
%>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <title>Catalogo • SoccerWear</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.5.2/css/all.min.css" />
  <style>
    :root { --bg:#111; --panel:#fff; --ring:#ddd; --ink:#111; --muted:#555; --focus:#003366; --radius:16px; }
    *{box-sizing:border-box}
    body{ margin:0; font-family:"Inter",system-ui,Segoe UI,Roboto,Arial,sans-serif; color:var(--ink); background:#111; }
    .page{ min-height:100vh; padding:28px 28px 40px; background:linear-gradient(180deg,#1a1a1a,#0d0d0d); overflow-x:hidden; }

    /* BARRE FILTRI */
    .filter-bar{display:flex;justify-content:flex-start;align-items:center;gap:24px;margin:20px 0}
    .filter-form{display:flex;align-items:center;gap:10px}
    .filter-form label{font-weight:700;color:#fff;font-size:15px}
    .filter-form select{
      appearance:none;padding:10px 14px;border-radius:12px;border:1px solid #2c2c39;background:#fff;color:#111;
      font-weight:700;font-size:14px;cursor:pointer;transition:all .2s ease;min-width:180px;box-shadow:0 2px 6px rgba(0,0,0,.1);
      background-image:url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12'><polygon points='0,0 12,0 6,8' fill='%23003366'/></svg>");
      background-repeat:no-repeat;background-position:right 12px center;background-size:12px;
    }
    .filter-form select:hover{border-color:#003366;box-shadow:0 0 6px rgba(0,51,102,.3)}
    .filter-form select option{background:#fff;color:#111;font-weight:600;padding:8px}

    /* GRID CATALOGO */
    .catalogo{flex:1;padding:20px}
    .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(250px,1fr));gap:24px}
    .card{background:var(--panel);color:var(--ink);border:1px solid var(--ring);border-radius:var(--radius);overflow:hidden;display:flex;flex-direction:column;transition:transform .15s ease,filter .15s ease;box-shadow:0 4px 10px rgba(0,0,0,.1)}
    .card:hover{transform:translateY(-3px);filter:brightness(1.02)}
    .card img{width:100%;height:220px;object-fit:cover}
    .card-body{padding:14px;flex:1;display:flex;flex-direction:column;justify-content:space-between;align-items:center}
    .name{font-weight:800;font-size:16px;margin-bottom:6px}
    .price{color:var(--focus);font-weight:800;font-size:15px;margin-bottom:10px;align-items:center}
    .btn{margin-top:8px;padding:10px;border-radius:12px;border:1px solid var(--ring);background:#fff;color:#111;font-weight:800;text-align:center;text-decoration:none;transition:.15s;cursor:pointer;display:block}
    .btn:hover{background:linear-gradient(180deg,#1a1a1a,#0d0d0d);color:#fff}
	 </style>
</head>
<body>
  <div class="page">
  
    <%@ include file="header.jspf" %>
    
    <h1 style="text-align:center;margin-bottom:20px;color:#FFFFFF"><i class="fa-solid fa-compass"></i> Catalogo prodotti</h1>

    <!-- Barra filtri: ogni form conserva gli altri parametri -->
    <div class="filter-bar">
      <!-- Ordina per prezzo -->
      <form method="get" action="catalogo.jsp" class="filter-form">
        <label for="order">Ordina per:</label>
        <select name="order" id="order" onchange="this.form.submit()">
          <option value="">-- Seleziona --</option>
          <option value="priceAsc"  <%= "priceAsc".equals(order)  ? "selected" : "" %>>Prezzo crescente</option>
          <option value="priceDesc" <%= "priceDesc".equals(order) ? "selected" : "" %>>Prezzo decrescente</option>
        </select>
        <!-- preserva filtri -->
        <input type="hidden" name="categoria" value="<%= categoria!=null?categoria:"" %>">
        <input type="hidden" name="size"      value="<%= size!=null?size:"" %>">
      </form>

      <!-- Filtro categoria -->
      <form method="get" action="catalogo.jsp" class="filter-form">
        <label for="categoria">Categoria:</label>
        <select name="categoria" id="categoria" onchange="this.form.submit()">
          <option value="">Tutte</option>
          <option value="SerieA"        <%= "SerieA".equals(categoria) ? "selected" : "" %>>Serie A</option>
          <option value="PremierLeague" <%= "PremierLeague".equals(categoria) ? "selected" : "" %>>Premier League</option>
          <option value="LaLiga"        <%= "LaLiga".equals(categoria) ? "selected" : "" %>>La Liga</option>
          <option value="Vintage"       <%= "Vintage".equals(categoria) ? "selected" : "" %>>Vintage</option>
        </select>
        <!-- preserva taglia e ordine -->
        <input type="hidden" name="size"  value="<%= size!=null?size:"" %>">
        <input type="hidden" name="order" value="<%= order!=null?order:"" %>">
      </form>

      <!-- Filtro taglia -->
      <form method="get" action="catalogo.jsp" class="filter-form">
        <label for="size">Taglia:</label>
        <select name="size" id="size" onchange="this.form.submit()">
          <option value="">Tutte</option>
          <option value="S"  <%= "S".equalsIgnoreCase(size)  ? "selected" : "" %>>S</option>
          <option value="M"  <%= "M".equalsIgnoreCase(size)  ? "selected" : "" %>>M</option>
          <option value="L"  <%= "L".equalsIgnoreCase(size)  ? "selected" : "" %>>L</option>
          <option value="XL" <%= "XL".equalsIgnoreCase(size) ? "selected" : "" %>>XL</option>
        </select>
        <!-- preserva categoria e ordine -->
        <input type="hidden" name="categoria" value="<%= categoria!=null?categoria:"" %>">
        <input type="hidden" name="order"     value="<%= order!=null?order:"" %>">
      </form>
    </div>

    <!-- CATALOGO -->
    <main class="catalogo">
      <div class="grid">
        <% if (prodotti != null && !prodotti.isEmpty()) { %>
  <%
    Set<String> nomiVisti = new HashSet<>();
    for (ProdottoBean p : prodotti) {
      if (p.getNome() == null) continue;
      if (nomiVisti.contains(p.getNome())) continue;
      nomiVisti.add(p.getNome());
  %>
    <div class="card">
      <% if (p.getFoto() != null) { %>
        <img src="data:image/jpeg;base64,<%= java.util.Base64.getEncoder().encodeToString(p.getFoto()) %>" alt="Immagine <%= p.getNome() %>">
      <% } else { %>
        <img src="<%=ctx%>/img/no-photo.png" alt="Nessuna immagine">
      <% } %>
      <div class="card-body">
        <div class="name"><%= p.getNome() %></div>
        <div>
          <div class="price"><%= String.format(java.util.Locale.ITALY, "%.2f", p.getCosto()) %> €</div>
          <a href="javascript:void(0)" class="btn" onclick="openDetailsById(<%= p.getId() %>)">
            <i class="fa-solid fa-eye"></i> Dettagli
          </a>
          <form action="<%=ctx%>/cart/add" method="post" style="margin-top:6px;">
            <input type="hidden" name="id" value="<%=p.getId()%>">
            <button type="submit" class="btn"><i class="fa-solid fa-cart-plus"></i> Aggiungi al carrello</button>
          </form>
        </div>
      </div>
    </div>
  <%
    } // fine for
  %>
<% } else { %>
  <p style="text-align:center;width:100%;color:#FFF">Nessun prodotto disponibile.</p>
<% } %>
      </div>
    </main>

    <!-- MODAL PRODOTTO -->
    <div id="productModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.6);z-index:1000;">
      <div style="background:#fff;color:#111;max-width:900px;width:92%;margin:5% auto;border-radius:16px;overflow:hidden;">
        <div style="display:flex;gap:18px;flex-wrap:wrap;padding:16px;">
          <img id="modalImg" src="" alt="" style="width:360px;max-width:100%;height:360px;object-fit:cover;background:#eee;">
          <div style="flex:1;min-width:260px;">
            <h2 id="modalTitle" style="margin:0 0 6px;font-weight:900;font-size:26px;"></h2>
            <div style="color:#555;margin-bottom:8px;">Categoria: <span id="modalCat"></span></div>
            <p id="modalDesc" style="margin:10px 0 14px;color:#333;"></p>
            <div id="modalPrice" style="color:#0d47a1;font-weight:900;font-size:20px;margin:6px 0 12px;"></div>

            <div>
              <div style="font-weight:800;margin-bottom:8px;">Seleziona Taglia</div>
              <div id="modalTaglie" style="display:flex;gap:10px;flex-wrap:wrap;"></div>
            </div>

            <div style="margin-top:16px;">
              <div style="font-weight:800;margin-bottom:8px;">Personalizza maglia</div>
              <label style="display:block;margin-bottom:6px;">
                Nome sul retro:
                <input type="text" id="modalCustomName" name="nome_retro" style="width:100%;padding:8px;border:1px solid #ccc;border-radius:8px;">
              </label>
              <label style="display:block;">
                Numero:
                <input type="number" id="modalCustomNumber" name="numero_retro" min="0" max="99" style="width:100%;padding:8px;border:1px solid #ccc;border-radius:8px;">
              </label>
            </div>

            <div style="margin-top:16px;">
  				<label style="font-weight:800;">Quantità</label>
  				<div style="display:flex;align-items:center;gap:8px;margin-top:6px;">
   				<button type="button" id="qtyDec"
            		style="width:36px;height:36px;border:1px solid #ccc;border-radius:10px;background:#fff;cursor:pointer;font-weight:900;">−</button>

    			<input type="number" id="modalQty" name="quantita" value="1" min="1"
           			style="width:90px;padding:8px;border:1px solid #ccc;border-radius:8px;text-align:center;">

    			<button type="button" id="qtyInc"
            		style="width:36px;height:36px;border:1px solid #ccc;border-radius:10px;background:#fff;cursor:pointer;font-weight:900;">+</button>

   				 <span id="qtyHint" style="color:#666;font-size:13px;margin-left:6px;"></span>
  				</div>
			</div>

            <div style="margin-top:16px;display:flex;gap:10px;flex-wrap:wrap;">
              <form id="modalAddToCart" action="<%=ctx%>/cart/add" method="post" onsubmit="return beforeAddToCart();">
                <input type="hidden" name="id" id="modalPid">
                <input type="hidden" name="taglia" id="modalSize">
                <input type="hidden" name="nome_retro" id="modalHiddenName">
                <input type="hidden" name="numero_retro" id="modalHiddenNumber">
                <input type="hidden" name="quantita" id="modalHiddenQty">
                <button type="submit" style="border:1px solid #111;padding:10px 14px;border-radius:12px;background:#111;color:#fff;font-weight:800;cursor:pointer;">
                  <i class="fa-solid fa-cart-plus"></i> Aggiungi al carrello
                </button>
              </form>
              <button type="button" onclick="closeProductModal()" style="border:1px solid #bbb;padding:10px 14px;border-radius:12px;background:#fff;color:#111;font-weight:800;cursor:pointer;">
                Chiudi
              </button>
            </div>

          </div>
        </div>
      </div>
    </div>

    <script>
  let selectedSize = null;
  let stockBySize = {};      // mappa { S: n, M: n, ... } dal backend
  let currentMax = 1;        // limite max per la taglia corrente

  function closeProductModal(){
    document.getElementById('productModal').style.display='none';
  }
  window.addEventListener('click', (e) => {
    const m=document.getElementById('productModal');
    if(e.target===m) closeProductModal();
  });

  // Aggiorna limiti e UI della quantità in base alla taglia selezionata
  function updateQtyLimits(){
    const qtyInput = document.getElementById('modalQty');
    const hint     = document.getElementById('qtyHint');

    currentMax = (selectedSize && stockBySize[selectedSize]) ? stockBySize[selectedSize] : 1;
    if (!Number.isFinite(currentMax) || currentMax < 1) currentMax = 1;

    qtyInput.min = 1;
    qtyInput.max = currentMax;

    // clamp valore corrente
    let v = parseInt(qtyInput.value || '1', 10);
    if (v < 1) v = 1;
    if (v > currentMax) v = currentMax;
    qtyInput.value = v;

    // messaggino di aiuto
    hint.textContent = `(max ${currentMax})`;
  }

  // Pulsanti + / -
  function attachQtyControls(){
    const dec = document.getElementById('qtyDec');
    const inc = document.getElementById('qtyInc');
    const qty = document.getElementById('modalQty');

    // rimuovi eventuali handler precedenti
    dec.onclick = null; inc.onclick = null;
    qty.oninput = null;

    dec.onclick = () => {
      let v = parseInt(qty.value || '1', 10);
      v = isNaN(v) ? 1 : v;
      if (v > 1) v--;
      qty.value = v;
    };
    inc.onclick = () => {
      let v = parseInt(qty.value || '1', 10);
      v = isNaN(v) ? 1 : v;
      const max = parseInt(qty.max || currentMax, 10);
      if (v < max) v++;
      qty.value = v;
    };
    qty.oninput = () => {
      // forza i limiti anche digitando a mano
      let v = parseInt(qty.value || '1', 10);
      if (isNaN(v) || v < 1) v = 1;
      if (v > currentMax) v = currentMax;
      qty.value = v;
    };
  }

  function beforeAddToCart(){
    if(!selectedSize){
      alert('Seleziona una taglia.');
      return false;
    }
    const qtyInput = document.getElementById('modalQty');
    const q = parseInt(qtyInput.value || '1', 10);
    if (!Number.isFinite(q) || q < 1) {
      alert('Quantità non valida.');
      return false;
    }
    if (q > currentMax) {
      alert(`Disponibilità insufficiente per la taglia ${selectedSize}. Max acquistabile: ${currentMax}.`);
      return false;
    }

    document.getElementById('modalSize').value        = selectedSize;
    document.getElementById('modalHiddenName').value  = document.getElementById('modalCustomName').value.trim();
    document.getElementById('modalHiddenNumber').value= document.getElementById('modalCustomNumber').value.trim();
    document.getElementById('modalHiddenQty').value   = q;
    return true;
  }

  async function openDetailsById(id){
    try{
      const res  = await fetch('<%=ctx%>/api/product?id=' + encodeURIComponent(id));
      const json = await res.json();
      if(!json.success){ alert(json.error || 'Errore'); return; }
      const d = json.data;

      document.getElementById('modalPid').value = id;
      document.getElementById('modalTitle').textContent = d.nome || '';
      document.getElementById('modalDesc').textContent  = d.descrizione || '';
      document.getElementById('modalCat').textContent   = d.categoria || '';
      document.getElementById('modalPrice').textContent = Number(d.prezzo).toFixed(2) + ' € + IVA';

      const img = document.getElementById('modalImg');
      img.src = d.imageUrl || '<%=ctx%>/img/no-photo.png';
      img.onerror = () => { img.src = '<%=ctx%>/img/no-photo.png'; };

      // Prepara taglie & quantità
      const wrap = document.getElementById('modalTaglie');
      wrap.innerHTML = '';
      selectedSize = null;

      // salva mappa stock
      stockBySize = d.taglie || {}; // es: {S:5,M:0,L:3,XL:2}
      attachQtyControls();           // collega i bottoni
      currentMax = 1;
      updateQtyLimits();             // reset limiti iniziali

      // crea pulsanti taglia
      ['S','M','L','XL'].forEach(t => {
        const stock = stockBySize[t] || 0;
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.textContent = t + (stock>0 ? ` (${stock})` : ' (0)');
        btn.style.cssText = 'padding:8px 12px;border-radius:999px;border:1px solid #111;background:#fff;color:#111;font-weight:800;cursor:pointer;';
        if (stock <= 0){
          btn.disabled = true;
          btn.style.opacity = '0.5';
          btn.style.cursor = 'not-allowed';
        } else {
          btn.addEventListener('click', () => {
            // deseleziona visivamente gli altri
            [...wrap.children].forEach(c => c.style.outline = 'none');
            btn.style.outline = '3px solid #0d47a1';
            selectedSize = t;
            // aggiorna limiti quantità per questa taglia
            updateQtyLimits();
          });
        }
        wrap.appendChild(btn);
      });

      document.getElementById('productModal').style.display = 'block';
    }catch(err){
      console.error(err);
      alert('Errore nel caricamento dettagli.');
    }
  }
</script>
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


    <%@ include file="footer.jspf" %>
    
  </div>
</body>
</html>
