<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>SOCCERWEAR • Home</title>

  <!-- Font & Icons -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
  <!-- ✅ CDN Font Awesome senza integrity (evita mismatch) -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.5.2/css/all.min.css" />

  <style>
    :root{ --bg-1:#0a002a; --bg-2:#180642; --ink:#f2f2f2; --muted:#cfcfd4; --accent:#ffffff; --ring:#2c2c39; --soft:#0e0e15; --radius:16px; }
    *{box-sizing:border-box}
    html,body{height:100%}
    body{ margin:0; font-family:"Inter",system-ui,Segoe UI,Roboto,Arial,sans-serif; color:var(--ink); background:#111; }
    .page {
  min-height: 100dvh;
  padding: 28px 28px 40px;
  background: linear-gradient(180deg, #1a1a1a, #0d0d0d);
  overflow-x: hidden;
}


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

    /* HERO */
    .hero{ margin-top:26px; min-height:60vh; border-radius:18px;
      background: radial-gradient(90% 90% at 10% 10%, rgba(255,255,255,.03) 0%, transparent 60%),
                  radial-gradient(120% 120% at 90% 40%, rgba(0,0,0,.35) 0%, transparent 55%);
      border:1px solid rgba(255,255,255,.07); box-shadow: inset 0 0 0 1px rgba(255,255,255,.03); }

    /* RESPONSIVE */
    @media (max-width: 980px){
      .topbar{grid-template-columns: 1fr; gap:16px}
      .actions{justify-self:start}
      .greeting{text-align:left}
      .search{justify-self:start; max-width:100%}
    }
    @media (max-width: 520px){
      .page{margin:10px;padding:18px}
      .logo{width:44px;height:44px}
      .mainnav{gap:18px}
      .hero{min-height:52vh}
    }
    
    /* SHOWCASE / SLIDER */
	.showcase{
  /* prima avevi min-height:56vh */
  height: clamp(600px, 60vh, 720px);  /* altezza reattiva e stabile */
  position: relative;
  margin-top: 26px;
  border-radius: 18px;
  overflow: hidden;
  border: 1px solid rgba(255,255,255,.07);
  box-shadow: inset 0 0 0 1px rgba(255,255,255,.03);
  background: #0e0e1a;
}
	/* i figli riempiono al 100% l’altezza della showcase */
.slider,
.slide{
  height: 100%;
}

/* slide a pieno schermo + transizioni */
.slide{
  position: absolute; inset: 0;
  display: grid; place-items: center;
  opacity: 0; transform: translateX(6%);
  transition: opacity .6s ease, transform .6s ease;
  padding: 28px;
}
	.slide.is-active{ opacity:1; transform:translateX(0); }
	.slide-inner{
	  max-width:min(920px, 90%);
	  text-align:center;
	  background:rgba(0,0,0,.25);
	  border:1px solid rgba(255,255,255,.08);
	  border-radius:16px;
	  padding:28px 24px;
	  backdrop-filter: blur(6px);
	}
	.slide-title{
	  margin:0 0 10px;
	  font-size:clamp(26px,4.2vw,42px);
	  font-weight:900;
	  letter-spacing:.02em;
	}
	.slide-text{
	  margin:0 auto 16px;
	  color:#e7e7ee;
	  font-size:clamp(14px,2vw,18px);
	  line-height:1.55;
	  max-width:70ch;
	}
	.cta{
 	 display:inline-block;
	  margin-top:4px;
	  padding:12px 18px;
	  font-weight:800;
	  color:#111;
	  background:#fff;
	  border-radius:12px;
	  text-decoration:none;
	  transition:transform .06s ease, filter .15s ease;
	}
	.cta:hover{ filter:brightness(1.05); }
	.cta:active{ transform:translateY(1px); }

	/* Temi di sfondo per slide con immagini */
.bg-seriea{
  background:
    linear-gradient(rgba(0,0,0,.55), rgba(0,0,0,.55)),
    url("img/serieA.jpg") center/cover no-repeat;
}
.bg-top5{
  background:
    linear-gradient(rgba(0,0,0,.55), rgba(0,0,0,.55)),
    url("img/top5.png") center/cover no-repeat;
}
.bg-nazionali{
  background:
    linear-gradient(rgba(0,0,0,.55), rgba(0,0,0,.55)),
    url("img/nazionali.png") center/cover no-repeat;
}
.bg-vintage{
  background:
    linear-gradient(rgba(0,0,0,.55), rgba(0,0,0,.55)),
    url("img/vintage.jpg") center/cover no-repeat;
}


/* Dots & arrows */
.controls{ position:absolute; inset:0; pointer-events:none; }
.nav{
  pointer-events:auto;
  position:absolute; top:50%; transform:translateY(-50%);
  width:44px; height:44px; border-radius:50%;
  border:1px solid rgba(255,255,255,.2);
  background:rgba(0,0,0,.35);
  color:#fff; display:grid; place-items:center;
  transition:filter .15s ease, transform .06s ease;
}
.nav:hover{ filter:brightness(1.1); }
.nav:active{ transform:translateY(-50%) scale(.98); }
.prev{ left:14px; }
.next{ right:14px; }

.dots{
  position:absolute; left:50%; bottom:14px; transform:translateX(-50%);
  display:flex; gap:10px; z-index:2;
}
.dot{
  width:10px; height:10px; border-radius:50%;
  border:1px solid rgba(255,255,255,.7);
  background:transparent;
  cursor:pointer;
  transition:background .2s ease, transform .06s ease;
}
.dot.is-active{ background:#fff; transform:scale(1.05); }

/* Accessibilità: se l’utente preferisce meno animazioni */
@media (prefers-reduced-motion: reduce){
  .slide{ transition:none; }
  .nav{ transition:none; }
  .cta{ transition:none; }
}
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
footer .links {
  margin-top: 8px;
  display: flex;
  justify-content: center;
  gap: 18px;
  flex-wrap: wrap;
}

footer .links a {
  color: var(--ink);
  text-decoration: none;
  font-weight: 600;
  font-size: 14px;
  transition: color .2s ease;
}

footer .links a:hover {
  color: #fff;
}
    
  </style>
</head>
<body>
  <div class="page">
    <!-- HEADER -->
    <header class="topbar">
      <div class="brand">
        <img src="img/ball.png" alt="" class="logo" />
        <div class="brand-text">
          <h1 class="title">SOCCERWEAR</h1>
          <p class="subtitle">Vesti anche tu sport!</p>
        </div>
      </div>

	<%
    	model.UtenteBean utente = (model.UtenteBean) session.getAttribute("utente");
    	boolean isAdmin = (utente != null && "admin".equalsIgnoreCase(utente.getRuolo()));
	%>
      <nav class="mainnav" aria-label="Principale">
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

    <!-- SHOWCASE / SLIDER -->
<section class="showcase" aria-label="Preview prodotti">
  <div class="slider" id="slider" data-index="0">
    <!-- Slide 1 -->
    <article class="slide is-active bg-seriea" role="group" aria-roledescription="slide" aria-label="1 di 4">
      <div class="slide-inner">
        <h2 class="slide-title">Serie A 24/25</h2>
        <p class="slide-text">
          Le nuove maglie 24/25 della Serie A: dettagli premium, fit moderno, personalizzazione nome/numero ufficiale.
        </p>
        <a class="cta" href="catalogo.jsp?league=SerieA">Scopri le squadre</a>
      </div>
    </article>

    <!-- Slide 2 -->
    <article class="slide bg-top5" role="group" aria-roledescription="slide" aria-label="2 di 4">
      <div class="slide-inner">
        <h2 class="slide-title">Top 5 Campionati 24/25</h2>
        <p class="slide-text">
          Premier League, LaLiga, Bundesliga, Serie A, Ligue 1: i kit 24/25 più attesi, tutti in un posto.
        </p>
        <a class="cta" href="catalogo.jsp?league=Top5">Vai al catalogo</a>
      </div>
    </article>

    <!-- Slide 3 -->
    <article class="slide bg-nazionali" role="group" aria-roledescription="slide" aria-label="3 di 4">
      <div class="slide-inner">
        <h2 class="slide-title">Top 20 Nazionali 24/25</h2>
        <p class="slide-text">
          Le maglie delle nazionali più iconiche: tessuti tecnici e patch ufficiali, pronte per la tua collezione.
        </p>
        <a class="cta" href="catalogo.jsp?type=Nazionale">Scopri le nazionali</a>
      </div>
    </article>

    <!-- Slide 4 -->
    <article class="slide bg-vintage" role="group" aria-roledescription="slide" aria-label="4 di 4">
      <div class="slide-inner">
        <h2 class="slide-title">Vintage Selezione</h2>
        <p class="slide-text">
          Le maglie storiche più richieste: edizioni rare e reissue ufficiali. Stile senza tempo.
        </p>
        <a class="cta" href="catalogo.jsp?tag=Vintage">Vedi i best seller</a>
      </div>
    </article>
  </div>

  <!-- Controls -->
  <div class="controls">
    <button class="nav prev" type="button" aria-label="Slide precedente">
      <i class="fa-solid fa-chevron-left"></i>
    </button>
    <button class="nav next" type="button" aria-label="Slide successiva">
      <i class="fa-solid fa-chevron-right"></i>
    </button>
  </div>

  <!-- Dots -->
  <div class="dots" role="tablist" aria-label="Selettori slide">
    <button class="dot is-active" type="button" role="tab" aria-selected="true" aria-controls="slide-1" aria-label="Vai alla slide 1"></button>
    <button class="dot" type="button" role="tab" aria-selected="false" aria-controls="slide-2" aria-label="Vai alla slide 2"></button>
    <button class="dot" type="button" role="tab" aria-selected="false" aria-controls="slide-3" aria-label="Vai alla slide 3"></button>
    <button class="dot" type="button" role="tab" aria-selected="false" aria-controls="slide-4" aria-label="Vai alla slide 4"></button>
  </div>
</section>

<footer>
  <div>© 2025 SoccerWear. Tutti i diritti riservati.</div>
  <div class="links">
    <a href="#">Privacy</a>
    <a href="#">Termini</a>
    <a href="#">Contatti</a>
  </div>
</footer>
  </div>
  <script>
  (function(){
    const slider = document.getElementById('slider');
    const slides = Array.from(slider.querySelectorAll('.slide'));
    const dots = Array.from(document.querySelectorAll('.dot'));
    const prevBtn = document.querySelector('.prev');
    const nextBtn = document.querySelector('.next');

    let index = 0;
    let timer = null;
    const INTERVAL = 5000;
    const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    function goTo(i){
      slides[index].classList.remove('is-active');
      dots[index].classList.remove('is-active');
      index = (i + slides.length) % slides.length;
      slides[index].classList.add('is-active');
      dots[index].classList.add('is-active');
      slider.setAttribute('data-index', index);
    }
    function next(){ goTo(index + 1); }
    function prev(){ goTo(index - 1); }

    function start(){
      if (prefersReduced) return;
      stop();
      timer = setInterval(next, INTERVAL);
    }
    function stop(){
      if (timer){ clearInterval(timer); timer = null; }
    }

    // Init
    goTo(0);
    start();

    // Controls
    nextBtn.addEventListener('click', () => { next(); start(); });
    prevBtn.addEventListener('click', () => { prev(); start(); });
    dots.forEach((d, i) => d.addEventListener('click', () => { goTo(i); start(); }));

    // Pause on hover
    const showcase = document.querySelector('.showcase');
    showcase.addEventListener('mouseenter', stop);
    showcase.addEventListener('mouseleave', start);

    // Visibility pause (quando cambi tab)
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) stop(); else start();
    });

    // Keyboard
    document.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowRight') { next(); start(); }
      if (e.key === 'ArrowLeft')  { prev(); start(); }
    });

    // Touch / Swipe
    let touchStartX = 0, touching = false;
    showcase.addEventListener('touchstart', (e) => {
      touching = true; touchStartX = e.touches[0].clientX; stop();
    }, {passive:true});
    showcase.addEventListener('touchmove', (e) => {
      // potresti animare il trascinamento qui se vuoi
    }, {passive:true});
    showcase.addEventListener('touchend', (e) => {
      if (!touching) return;
      const dx = e.changedTouches[0].clientX - touchStartX;
      if (Math.abs(dx) > 40) { (dx < 0 ? next() : prev()); }
      touching = false; start();
    });
  })();
</script>
  
  
</body>
</html>
