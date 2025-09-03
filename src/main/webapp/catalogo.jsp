<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.ProdottoBean" %>
<%
    List<ProdottoBean> prodotti = (List<ProdottoBean>) request.getAttribute("prodotti");
    model.UtenteBean u = (model.UtenteBean) session.getAttribute("utente");
    String ctx = request.getContextPath();
%>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <title>Catalogo • SoccerWear</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.5.2/css/all.min.css" />
  <style>
    :root{ --bg:#111; --panel:#0f0f14; --ring:#2c2c39; --ink:#f2f2f2; --muted:#bdbdc5; --focus:#7aa2ff; --radius:16px; }
    *{box-sizing:border-box}
    body{margin:0;background:var(--bg);color:var(--ink);font-family:"Inter",system-ui,Segoe UI,Roboto,Arial,sans-serif}
    .page{min-height:100dvh;padding:28px;display:flex;flex-direction:column}

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

	.brand-link:hover .title {
  	color: #7aa2ff; /* esempio: cambio colore titolo al passaggio */
	}
    

    /* GRID CATALOGO */
    .catalogo{flex:1;padding:20px}
    .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:20px}
    .card{background:var(--panel);border:1px solid var(--ring);border-radius:var(--radius);overflow:hidden;display:flex;flex-direction:column;transition:transform .15s ease, filter .15s ease}
    .card:hover{transform:translateY(-3px);filter:brightness(1.05)}
    .card img{width:100%;height:220px;object-fit:cover}
    .card-body{padding:14px;flex:1;display:flex;flex-direction:column;justify-content:space-between}
    .name{font-weight:800;font-size:16px;margin-bottom:6px}
    .price{color:var(--focus);font-weight:700;font-size:15px}
    .btn{margin-top:10px;padding:10px;border-radius:12px;border:1px solid var(--ring);background:#fff;color:#111;font-weight:800;text-align:center;text-decoration:none;transition:.15s}
    .btn:hover{filter:brightness(1.05)}

    /* FOOTER */
    footer{margin-top:28px;padding-top:16px;border-top:1px solid rgba(255,255,255,.1);text-align:center;color:var(--muted);font-size:14px}
  </style>
</head>
<body>
  <div class="page">
    <!-- HEADER -->
    <header class="topbar">
      <div class="brand">
  		<a href="home.jsp" class="brand-link">
    	<img src="img/ball.png" alt="Logo SoccerWear" class="logo" />
    	<div class="brand-text">
      	<h1 class="title">SOCCERWEAR</h1>
      	<p class="subtitle">Vesti anche tu sport!</p>
    	</div>
  		</a>
	</div>

      <nav class="mainnav" aria-label="Principale">
        <a href="catalogo.jsp" class="navlink"><i class="fa-solid fa-compass"></i>Esplora</a>
        <a href="#" class="navlink"><i class="fa-solid fa-fire"></i>Novità</a>
        <a href="#" class="navlink"><i class="fa-solid fa-circle-info"></i>Info</a>
        <a href="profile.jsp" class="navlink"><i class="fa-solid fa-user"></i>Profilo</a>
        <a href="${pageContext.request.contextPath}/logout" class="navlink"><i class="fa-solid fa-right-from-bracket"></i>Logout</a>
      </nav>

      <div class="actions">
        <!-- ✅ Icona FA con badge -->
        <a href="#" class="cart" aria-label="Carrello">
          <i class="fa-solid fa-cart-shopping"></i>
          <!-- esempio: sostituisci con la size del tuo carrello in sessione -->
          <span class="badge">3</span>
        </a>

        <div class="greeting">
          <div class="hello">Ciao, <span class="username"><%= ((model.UtenteBean)session.getAttribute("utente")).getNome() %></span>!</div>
          <div class="again">Bello rivederti!</div>
        </div>

        <form class="search" role="search" action="#" method="get">
          <span class="icon" aria-hidden="true"><i class="fa-solid fa-magnifying-glass"></i></span>
          <input name="q" type="search" placeholder="Cerca" aria-label="Cerca prodotti" />
        </form>
      </div>
    </header>

    <!-- CATALOGO -->
    <main class="catalogo">
      <h1 style="text-align:center;margin-bottom:20px;">Catalogo prodotti</h1>
      <div class="grid">
        <%
          if (prodotti != null) {
            for (ProdottoBean p : prodotti) {
        %>
          <div class="card">
            <% if (p.getFoto() != null) { %>
              <img src="data:image/jpeg;base64,<%= java.util.Base64.getEncoder().encodeToString(p.getFoto()) %>" alt="Immagine <%= p.getNome() %>">
            <% } else { %>
              <img src="<%=ctx%>/img/no-photo.png" alt="Nessuna immagine">
            <% } %>
            <div class="card-body">
              <div class="name"><%= p.getNome() %></div>
              <div class="price"><%= p.getCosto() %> €</div>
              <a href="<%=ctx%>/product?id=<%= p.getCodice() %>" class="btn">Dettagli</a>
            </div>
          </div>
        <%
            }
          } else {
        %>
          <p style="text-align:center;width:100%;">Nessun prodotto disponibile.</p>
        <%
          }
        %>
      </div>
    </main>

    <!-- FOOTER -->
    <footer>© 2025 SoccerWear — Catalogo</footer>
  </div>
</body>
</html>
