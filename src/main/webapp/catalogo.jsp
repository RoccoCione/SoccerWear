<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.ProdottoBean, model.UtenteBean, DAO.ProdottoDAO" %>
<%
    String ctx = request.getContextPath();
    UtenteBean u = (UtenteBean) session.getAttribute("utente");

    List<ProdottoBean> prodotti = (List<ProdottoBean>) request.getAttribute("prodotti");
    if (prodotti == null) {
        prodotti = new ProdottoDAO().findAll();
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
    :root {
      --bg:#111; --panel:#fff; --ring:#ddd;
      --ink:#111; --muted:#555; --focus:#003366; --radius:16px;
    }
    *{box-sizing:border-box}
    body{ margin:0; font-family:"Inter",system-ui,Segoe UI,Roboto,Arial,sans-serif; color:var(--ink); background:#111; }
    .page {
  		min-height: 100vh;
  		padding: 28px 28px 40px;
  		background: linear-gradient(180deg, #1a1a1a, #0d0d0d);
  		overflow-x: hidden;
		}

    /* HEADER (uguale a home.jsp) */
    .topbar{display:grid;grid-template-columns:minmax(240px,1fr) auto minmax(360px,1.2fr);align-items:center;gap:18px 28px;padding:18px 14px 8px;color:#fff}
    .brand{display:flex;align-items:center;gap:14px}
    .logo{width:52px;height:52px}
    .brand-text{display:flex;flex-direction:column}
    .title{margin:0;font-size:clamp(22px,3.4vw,34px);font-weight:800}
    .subtitle{margin:.5px 0 0;color:#ccc;font-size:13.5px;font-weight:700}
    .mainnav{display:flex;gap:26px;justify-self:center}
    .navlink{color:#fff;text-decoration:none;font-weight:800;font-size:clamp(14px,1.8vw,20px);display:inline-flex;align-items:center;gap:8px;position:relative;padding:15px}
    .navlink::after{content:"";position:absolute;left:0;right:0;bottom:-4px;height:2px;background:currentColor;opacity:.6;transform:scaleX(0);transition:.2s}
    .navlink:hover::after{opacity:1;transform:scaleX(1)}
    .actions{display:grid;grid-template-columns:auto 1fr;align-items:center;gap:14px 18px;justify-self:end}
    .cart{position:relative;color:#fff;display:inline-flex;align-items:center;justify-content:center;padding:10px;border-radius:12px;border:1px solid var(--ring);background:rgba(255,255,255,.1);font-size:22px}
    .cart .badge{position:absolute;top:4px;right:4px;background:#e63946;color:#fff;font-size:12px;font-weight:700;border-radius:50%;padding:3px 6px;line-height:1}
    .greeting{text-align:right}
    .greeting .hello{font-size:clamp(18px,2.4vw,28px);font-weight:800}
    .greeting .again{color:#ccc;font-weight:800;font-size:13px;margin-top:2px}
    .search{grid-column:1/-1;display:flex;align-items:center;gap:10px;border:1px solid var(--ring);background:rgba(255,255,255,.05);border-radius:14px;padding:10px 12px;max-width:440px;justify-self:end}
    .search input{border:0;outline:none;background:transparent;color:#fff;font-size:16px;flex:1}
    .search input::placeholder{color:#aaa}
    .brand-link {display:flex;align-items:center;gap:14px;text-decoration:none;color:inherit}

    /* GRID CATALOGO */
    .catalogo{flex:1;padding:20px}
    .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(250px,1fr));gap:24px}
    .card{
      background:var(--panel);color:var(--ink);
      border:1px solid var(--ring);border-radius:var(--radius);
      overflow:hidden;display:flex;flex-direction:column;
      transition:transform .15s ease, filter .15s ease;
      box-shadow:0 4px 10px rgba(0,0,0,.1);
    }
    .card:hover{transform:translateY(-3px);filter:brightness(1.02)}
    .card img{width:100%;height:220px;object-fit:cover}
    .card-body{padding:14px;flex:1;display:flex;flex-direction:column;justify-content:space-between; align-items:center;}
    .name{font-weight:800;font-size:16px;margin-bottom:6px}
    .desc{font-size:13px;color:var(--muted);min-height:34px;margin:0 0 8px}
    .price{color:var(--focus);font-weight:800;font-size:15px;margin-bottom:10px;align-items:center}
    .btn{
      margin-top:8px;padding:10px;border-radius:12px;
      border:1px solid var(--ring);background:#fff;
      color:#111;font-weight:800;text-align:center;text-decoration:none;
      transition:.15s;cursor:pointer;display:block
    }
    .btn:hover{background:linear-gradient(180deg, #1a1a1a, #0d0d0d); color:#FFFFFF}

    /* FOOTER */
    footer {
  position: fixed;
  bottom: 0;
  left: 0;
  width: 100%;
  padding: 16px;
  background: #111; /* stesso colore del body per continuità */
  border-top: 1px solid rgba(255,255,255,.1);
  text-align: center;
  color: #999;
  font-size: 14px;
}
  </style>
</head>
<body>
  <div class="page">
    <!-- HEADER -->
    <header class="topbar">
      <div class="brand">
        <a href="<%=ctx%>/home.jsp" class="brand-link">
          <img src="<%=ctx%>/img/ball.png" alt="Logo SoccerWear" class="logo" />
          <div class="brand-text">
            <h1 class="title">SOCCERWEAR</h1>
            <p class="subtitle">Vesti anche tu sport!</p>
          </div>
        </a>
      </div>

      <nav class="mainnav">
        <a href="<%=ctx%>/catalogo.jsp" class="navlink"><i class="fa-solid fa-compass"></i>Esplora</a>
        <a href="#" class="navlink"><i class="fa-solid fa-fire"></i>Novità</a>
        <a href="#" class="navlink"><i class="fa-solid fa-circle-info"></i>Info</a>
        <a href="<%=ctx%>/profile.jsp" class="navlink"><i class="fa-solid fa-user"></i>Profilo</a>
        <a href="<%=ctx%>/logout" class="navlink"><i class="fa-solid fa-right-from-bracket"></i>Logout</a>
      </nav>

      <div class="actions">
        <a href="#" class="cart" aria-label="Carrello">
          <i class="fa-solid fa-cart-shopping"></i>
          <span class="badge"><%= session.getAttribute("cartCount")!=null? session.getAttribute("cartCount") : 0 %></span>
        </a>
        <div class="greeting">
          <div class="hello">
            Ciao, <span class="username"><%= (u!=null ? u.getNome() : "ospite") %></span>!
          </div>
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
      <h1 style="text-align:center;margin-bottom:20px;color:#FFFFFF">Catalogo prodotti</h1>
      <div class="grid">
        <% if (prodotti != null && !prodotti.isEmpty()) {
             for (ProdottoBean p : prodotti) { %>
          <div class="card">
            <% if (p.getFoto() != null) { %>
              <img src="<%=ctx%>/image?id=<%=p.getId()%>" alt="Immagine <%= p.getNome() %>">
            <% } else { %>
              <img src="<%=ctx%>/img/no-photo.png" alt="Nessuna immagine">
            <% } %>
            <div class="card-body">
              <div>
                <div class="name"><%= p.getNome() %></div>
              </div>
              <div>
                <div class="price"><%= String.format(java.util.Locale.ITALY, "%.2f", p.getCosto()) %> €</div>
                <a href="<%=ctx%>/product?id=<%= p.getId() %>" class="btn"><i class="fa-solid fa-eye"></i> Dettagli</a>
                <form action="<%=ctx%>/cart/add" method="post" style="margin-top:6px;">
                  <input type="hidden" name="id" value="<%=p.getId()%>">
                  <button type="submit" class="btn"><i class="fa-solid fa-cart-plus"></i> Aggiungi al carrello</button>
                </form>
              </div>
            </div>
          </div>
        <% } } else { %>
          <p style="text-align:center;width:100%;">Nessun prodotto disponibile.</p>
        <% } %>
      </div>
    </main>

    <!-- FOOTER -->
    <footer>© 2025 SoccerWear — Catalogo</footer>
  </div>
</body>
</html>
