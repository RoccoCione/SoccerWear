<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,model.ProdottoBean,model.UtenteBean,DAO.ProdottoDAO" %>
<%
    UtenteBean u = (UtenteBean) session.getAttribute("utente");
    if (u == null || !"ADMIN".equalsIgnoreCase(u.getRuolo())) {
        response.sendRedirect(request.getContextPath() + "/home.jsp"); return;
    }
    String ctx = request.getContextPath();
    List<ProdottoBean> prodotti = new ProdottoDAO().findAll();
%>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8" />
  <title>Admin • Catalogo</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.5.2/css/all.min.css" />
  <style>
    body{margin:0;background:#111;color:#f2f2f2;font-family:Inter,system-ui,sans-serif}
     .page {
  		min-height: 100vh;
  		padding: 28px 28px 40px;
  		background: linear-gradient(180deg, #1a1a1a, #0d0d0d);
  		overflow-x: hidden;
		}
    .card{background:#1a1a1f;border:1px solid #2c2c39;border-radius:16px;padding:20px;margin-bottom:20px}
    table{width:100%;border-collapse:collapse;margin-top:12px}
    th,td{padding:10px;border-bottom:1px solid rgba(255,255,255,.1);text-align:left}
    th{color:#ffd700}
    .btn{padding:8px 14px;border-radius:10px;border:none;font-weight:700;cursor:pointer}
    .btn.primary{background:#ffd700;color:#111}
    .btn.danger{background:#ff4d4d;color:#fff}
    .form-grid{display:grid;grid-template-columns:repeat(3,minmax(220px,1fr));gap:12px}
    label{font-size:13px;color:#cfcfd4;margin-bottom:4px;display:block}
    input,select,textarea{width:100%;padding:10px;border-radius:10px;border:1px solid #2c2c39;background:#0f0f12;color:#fff}
    textarea{resize:vertical;min-height:80px}
    footer{margin-top:24px;padding-top:16px;border-top:1px solid rgba(255,255,255,.1);text-align:center;color:#999;font-size:14px}
     /* HEADER (come home.jsp) */
    .topbar{display:grid;grid-template-columns:minmax(240px,1fr) auto minmax(360px,1.2fr);align-items:center;gap:18px 28px;padding:18px 14px 8px;}
    .brand{display:flex;align-items:center;gap:14px}
    .logo{width:52px;height:52px}
    .brand-text{display:flex;flex-direction:column}
    .title{margin:0;font-size:clamp(22px,3.4vw,34px);font-weight:800}
    .subtitle{margin:.5px 0 0;color:var(--muted);font-size:13.5px;font-weight:700}
    .mainnav{display:flex;gap:26px;justify-self:center}
    .navlink{color:#fff;text-decoration:none;font-weight:800;font-size:clamp(14px,1.8vw,20px);display:inline-flex;align-items:center;gap:8px;position:relative;padding:15px}
    .navlink::after{content:"";position:absolute;left:0;right:0;bottom:-4px;height:2px;background:currentColor;opacity:.6;transform:scaleX(0);transition:.2s}
    .navlink:hover::after{opacity:1;transform:scaleX(1)}
    .actions{display:grid;grid-template-columns:auto 1fr;align-items:center;gap:14px 18px;justify-self:end}
    .cart{position:relative;color:#fff;display:inline-flex;align-items:center;justify-content:center;padding:10px;border-radius:12px;border:1px solid var(--ring);background:rgba(255,255,255,.03);font-size:22px}
    .cart .badge{position:absolute;top:4px;right:4px;background:#e63946;color:#fff;font-size:12px;font-weight:700;border-radius:50%;padding:3px 6px;line-height:1}
    .greeting{text-align:right}
    .greeting .hello{font-size:clamp(18px,2.4vw,28px);font-weight:800}
    .greeting .again{color:#dcdce3;font-weight:800;font-size:13px;margin-top:2px}
    .search{grid-column:1/-1;display:flex;align-items:center;gap:10px;border:1px solid var(--ring);background:rgba(255,255,255,.05);border-radius:14px;padding:10px 12px;max-width:440px;justify-self:end}
    .search input{border:0;outline:none;background:transparent;color:var(--ink);font-size:16px;flex:1}
    .search input::placeholder{color:#c7c7ce}
    .brand-link {
  	display: flex;
  	align-items: center;
  	gap: 14px;
  	text-decoration: none;
  	color: inherit; /* mantiene il colore del testo */
	}
	.modal {
  display: none;
  position: fixed;
  z-index: 1000;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.6);

  /* per permettere lo scroll se il contenuto è alto */
  overflow-y: auto;
}

.modal-content {
  background: #1a1a1f;
  color: #fff;
  margin: 2% auto;           /* centrata verticalmente e orizzontalmente */
  padding: 20px;
  border: 1px solid #2c2c39;
  border-radius: 16px;
  width: 90%;
  max-width: 600px;          /* un po’ più larga */
  max-height: 90vh;          /* non oltre la viewport */
  overflow-y: auto;          /* scroll interno se il form è troppo lungo */
  box-shadow: 0 8px 20px rgba(0,0,0,0.5);
}

.close {
  color: #aaa;
  float: right;
  font-size: 28px;
  font-weight: bold;
  cursor: pointer;
}
.close:hover { color: #fff; }

.modal-content label {
  display: block;
  margin-top: 10px;
  font-size: 13px;
  color: #cfcfd4;
}

.modal-content input,
.modal-content select,
.modal-content textarea {
  width: 100%;
  padding: 10px;
  border-radius: 10px;
  border: 1px solid #2c2c39;
  background: #0f0f12;
  color: #fff;
  margin-bottom: 8px;
}

.modal-content textarea {
  resize: vertical;
  min-height: 80px;
}

	
  </style>
</head>
<body>
  <div class="page">

    <!-- Messaggi -->
    <% if (request.getAttribute("errore") != null) { %>
      <div style="color:#ff6b6b;font-weight:700;margin-bottom:10px;"><%= request.getAttribute("errore") %></div>
    <% } %>
    <% if (request.getAttribute("successo") != null) { %>
      <div style="color:#4caf50;font-weight:700;margin-bottom:10px;"><%= request.getAttribute("successo") %></div>
    <% } %>
    
    <!-- HEADER -->
    <header class="topbar">
      <div class="brand">
  		<a href="<%= request.getContextPath() %>/home.jsp" class="brand-link">
    	<img src="img/ball.png" alt="Logo SoccerWear" class="logo" />
    	<div class="brand-text">
      	<h1 class="title">SOCCERWEAR</h1>
      	<p class="subtitle">Vesti anche tu sport!</p>
    	</div>
  		</a>
	</div>
	<%
    	model.UtenteBean utente = (model.UtenteBean) session.getAttribute("utente");
    	boolean isAdmin = (utente != null && "admin".equalsIgnoreCase(utente.getRuolo()));
		%>
      <nav class="mainnav">
        <% if (isAdmin) { %>
    	<a href="<%= request.getContextPath() %>/admincatalogo.jsp" class="navlink">
      	<i class="fa-solid fa-cog"></i> Gestione Catalogo
    	</a>
  		<% } else { %>
    	<a href="<%= request.getContextPath() %>/catalogo.jsp" class="navlink">
      	<i class="fa-solid fa-compass"></i> Esplora
    	</a>
  		<% } %>
        <a href="#" class="navlink"><i class="fa-solid fa-fire"></i>Novità</a>
        <a href="#" class="navlink"><i class="fa-solid fa-circle-info"></i>Info</a>
        <a href="profile.jsp" class="navlink"><i class="fa-solid fa-user"></i>Profilo</a>
        <a href="<%=ctx%>/logout" class="navlink"><i class="fa-solid fa-right-from-bracket"></i>Logout</a>
      </nav>
      <div class="actions">
        <a href="#" class="cart"><i class="fa-solid fa-cart-shopping"></i><span class="badge">3</span></a>
        <div class="greeting">
          <div class="hello">Ciao, <%= u.getNome() %>!</div>
          <div class="again">Bello rivederti!</div>
        </div>
        <form class="search" role="search"><input name="q" type="search" placeholder="Cerca prodotti"/></form>
      </div>
    </header>
    
	<h1><i class="fa-solid fa-crown"></i> Gestione Catalogo</h1>
	
    <!-- LISTA PRODOTTI -->
    <section class="card">
      <h2><i class="fa-solid fa-list"></i> Prodotti</h2>
      <table>
        <thead>
          <tr>
            <th>ID</th><th>Nome</th><th>Descrizione</th><th>Categoria</th>
            <th>Taglia</th><th>Numero Maglia</th><th>Disponibili</th>
            <th>Prezzo</th><th>IVA</th><th>Azioni</th>
          </tr>
        </thead>
        <tbody>
        <% if (prodotti.isEmpty()) { %>
          <tr><td colspan="10">Nessun prodotto presente.</td></tr>
        <% } else {
             for (ProdottoBean p : prodotti) { %>
          <tr>
            <td><%=p.getId()%></td>
            <td><%=p.getNome()%></td>
            <td><%=p.getDescrizione()!=null?p.getDescrizione():"-"%></td>
            <td><%=p.getCategoria()%></td>
            <td><%=p.getTaglia()%></td>
            <td><%=p.getNumeroMaglia()!=null?p.getNumeroMaglia():"-"%></td>
            <td><%=p.getUnitaDisponibili()!=null?p.getUnitaDisponibili():"-"%></td>
            <td><%=String.format("%.2f", p.getCosto())%> €</td>
            <td><%=String.format("%.2f", p.getIva())%>%</td>
            <td>
              <form action="<%=ctx%>/admin/edit-prodotto" method="get" style="display:inline">
                <input type="hidden" name="id" value="<%=p.getId()%>">
                <!-- Bottone modifica (dentro la tabella) -->
			<button type="button" class="btn primary btn-edit"
  data-id="<%=p.getId()%>"
  data-nome="<%=java.net.URLEncoder.encode(p.getNome(), "UTF-8")%>"
  data-desc="<%=p.getDescrizione()!=null?java.net.URLEncoder.encode(p.getDescrizione(), "UTF-8"):""%>"
  data-cat="<%=p.getCategoria()%>"
  data-taglia="<%=p.getTaglia()%>"
  data-numero="<%=p.getNumeroMaglia()!=null?p.getNumeroMaglia():""%>"
  data-unita="<%=p.getUnitaDisponibili()!=null?p.getUnitaDisponibili():""%>"
  data-costo="<%=String.format(java.util.Locale.US, "%.2f", p.getCosto())%>"
  data-iva="<%=String.format(java.util.Locale.US, "%.2f", p.getIva())%>">
  <i class="fa-solid fa-pen"></i>
</button>


              </form>
              <form action="<%=ctx%>/admin/delete-prodotto" method="post" style="display:inline" onsubmit="return confirm('Eliminare il prodotto?');">
                <input type="hidden" name="id" value="<%=p.getId()%>">
                <button class="btn danger" type="submit"><i class="fa-solid fa-trash"></i></button>
              </form>
            </td>
          </tr>
        <% } } %>
        </tbody>
      </table>
    </section>

    <!-- FORM INSERIMENTO -->
    <section class="card">
      <h2><i class="fa-solid fa-plus"></i> Aggiungi nuovo prodotto</h2>
      <form action="<%=ctx%>/admin/add-prodotto" method="post" enctype="multipart/form-data">
        <div class="form-grid">
          <div><label>Nome</label><input type="text" name="nome" required></div>
          <div><label>Descrizione</label><textarea name="descrizione"></textarea></div>
          <div><label>Numero Maglia</label><input type="number" name="numero_maglia"></div>

          <div><label>Categoria</label>
            <select name="categoria" required>
              <option value="SerieA">Serie A</option>
              <option value="PremierLeague">Premier League</option>
              <option value="LaLiga">La Liga</option>
              <option value="Vintage">Vintage</option>
            </select>
          </div>

          <div><label>Taglia</label>
            <select name="taglia" required>
              <option value="S">S</option><option value="M">M</option>
              <option value="L">L</option><option value="XL">XL</option>
            </select>
          </div>

          <div><label>Disponibili</label><input type="number" name="unita_disponibili" min="0"></div>
          <div><label>Prezzo €</label><input type="number" step="0.01" name="costo" required></div>
          <div><label>IVA %</label><input type="number" step="0.01" name="iva" required></div>
          <div><label>Foto</label><input type="file" name="foto" accept="image/*"></div>
        </div>

        <div style="margin-top:14px;text-align:right">
          <button class="btn primary" type="submit">Aggiungi prodotto</button>
        </div>
      </form>
    </section>
    
    <!-- MODAL EDIT -->
<div id="editModal" class="modal">
  <div class="modal-content">
    <span class="close" onclick="closeEditModal()">&times;</span>
    <h2><i class="fa-solid fa-pen"></i> Modifica prodotto</h2>

    <form id="editForm" action="<%=ctx%>/admin/edit-prodotto" method="post" enctype="multipart/form-data">
  <input type="hidden" name="id" id="editId">

  <label>Nome</label>
  <input type="text" name="nome" id="editNome" required>

  <label>Descrizione</label>
  <textarea name="descrizione" id="editDescrizione"></textarea>

  <label>Categoria</label>
  <select name="categoria" id="editCategoria" required>
    <option value="SerieA">SerieA</option>
    <option value="PremierLeague">PremierLeague</option>
    <option value="LaLiga">LaLiga</option>
    <option value="Vintage">Vintage</option>
  </select>

  <label>Taglia</label>
  <select name="taglia" id="editTaglia" required>
    <option value="S">S</option>
    <option value="M">M</option>
    <option value="L">L</option>
    <option value="XL">XL</option>
  </select>

  <label>Numero Maglia</label>
  <input type="number" name="numero_maglia" id="editNumeroMaglia">

  <label>Disponibili</label>
  <input type="number" name="unita_disponibili" id="editUnita">

  <label>Prezzo €</label>
  <input type="number" step="0.01" name="costo" id="editCosto" required>

  <label>IVA %</label>
  <input type="number" step="0.01" name="iva" id="editIva" required>

  <label>Foto (solo se vuoi sostituirla)</label>
  <input type="file" name="foto" accept="image/*">

  <div style="margin-top:14px;text-align:right">
    <button type="button" class="btn" onclick="closeEditModal()">Annulla</button>
    <button type="submit" class="btn primary">Salva modifiche</button>
  </div>
</form>
  </div>
</div>
    <script>
function closeEditModal(){
  document.getElementById("editModal").style.display = "none";
}

// Delegation: intercetta click su qualunque .btn-edit
document.addEventListener('click', function(e){
  const btn = e.target.closest('.btn-edit');
  if (!btn) return;

  const d = btn.dataset;
  // decodifica i testi url-encoded
  const nome = decodeURIComponent(d.nome || '');
  const desc = decodeURIComponent(d.desc || '');

  // popola i campi
  document.getElementById('editId').value            = d.id || '';
  document.getElementById('editNome').value          = nome;
  document.getElementById('editDescrizione').value   = desc;
  document.getElementById('editCategoria').value     = d.cat || 'SerieA';
  document.getElementById('editTaglia').value        = d.taglia || 'M';
  document.getElementById('editNumeroMaglia').value  = d.numero || '';
  document.getElementById('editUnita').value         = d.unita || '';
  document.getElementById('editCosto').value         = d.costo || '';
  document.getElementById('editIva').value           = d.iva || '';

  // mostra la modale
  document.getElementById('editModal').style.display = 'block';
});

// chiusura cliccando fuori
window.addEventListener('click', function(e){
  if (e.target === document.getElementById('editModal')) closeEditModal();
});
</script>
    

    <footer>© 2025 SoccerWear — Admin</footer>
  </div>
</body>
</html>
