<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Profilo • SoccerWear</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.5.2/css/all.min.css" />
  <style>
    :root{ --bg:#111; --panel:#0f0f14; --ring:#2c2c39; --ink:#f2f2f2; --muted:#bdbdc5; --focus:#7aa2ff; --ok:#4caf50; --bad:#ff6b6b; --radius:16px; }
    *{box-sizing:border-box}
    body{ margin:0; font-family:"Inter",system-ui,Segoe UI,Roboto,Arial,sans-serif; color:var(--ink); background:#111; }
    .page {
  		min-height: 100dvh;
  		padding: 28px 28px 40px;
  		background: linear-gradient(180deg, #1a1a1a, #0d0d0d);
  		overflow-x: hidden;
	}

    /* ===== PROFILO ===== */
    .wrap{display:grid;grid-template-columns:320px 1fr;gap:22px;margin-top:20px}
    .card{background:linear-gradient(180deg,#15151d,#0d0d13);border:1px solid var(--ring);border-radius:var(--radius);padding:20px}
    .side{display:grid;gap:16px;align-content:start}
    .avatar{width:140px;height:140px;border-radius:16px;object-fit:cover;border:1px solid var(--ring)}
    .u-name{font-size:22px;font-weight:800}
    .u-username{color:var(--muted);font-weight:700}
    .slink{display:flex;align-items:center;gap:10px;color:#fff;text-decoration:none;border:1px solid var(--ring);padding:10px 12px;border-radius:12px;background:#16161f}
    .slink:hover{filter:brightness(1.06)}
    .panel h2{margin:0 0 12px;font-size:18px}
    .grid{display:grid;grid-template-columns:1fr 1fr;gap:12px}
    .row{display:grid}
    label{font-size:13px;color:var(--muted);margin:4px 0 6px}
    .input{padding:12px;border-radius:12px;border:1px solid var(--ring);background:#0f0f12;color:#fff}
    .actions-form{display:flex;gap:10px;justify-content:flex-end;margin-top:12px}
    .btn{border:1px solid var(--ring);background:#1a1a21;color:#fff;font-weight:800;padding:10px 14px;border-radius:12px;cursor:pointer}
    .btn.primary{background:#fff;color:#111}
    #pwdPanel{display:none} /* nascosto di default */

    @media(max-width:980px){.wrap{grid-template-columns:1fr}.grid{grid-template-columns:1fr}}
    .alert {
  margin-top: 14px;
  padding: 12px 16px;
  border-radius: 10px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 10px;
  opacity: 0;
  transform: translateY(-6px);
  animation: fadeIn 0.4s forwards;
}

.alert.success {
  background: rgba(76, 175, 80, 0.15);
  border: 1px solid #4caf50;
  color: #4caf50;
}

.alert.error {
  background: rgba(255, 107, 107, 0.15);
  border: 1px solid #ff6b6b;
  color: #ff6b6b;
}

@keyframes fadeIn {
  to { opacity: 1; transform: translateY(0); }
}
    
  </style>
</head>
<body>
<% if (request.getAttribute("errore") != null) { %>
  <div style="color:red; font-weight:bold; margin-bottom:10px;">
    <%= request.getAttribute("errore") %>
  </div>
<% } %>
<% if (request.getAttribute("successo") != null) { %>
  <div style="color:lightgreen; font-weight:bold; margin-bottom:10px;">
    <%= request.getAttribute("successo") %>
  </div>
<% } %>

  <div class="page">
  
    <%@ include file="header.jspf" %>
    
    <h1 style="text-align:center;margin-bottom:20px;color:#FFFFFF"><i class="fa-solid fa-crown"></i> Profilo</h1>

    <!-- CONTENUTO PROFILO -->
    <section class="wrap">
      <!-- Sidebar -->
      <aside class="card side">
        <img src="<%=ctx%>/img/avatar.jpg" alt="Avatar" class="avatar">
        <div class="u-name"><%= u.getNome() %> <%= u.getCognome() %></div>
        <div class="u-username">@<%= u.getUsername() %></div>
        <a class="slink" href="<%=ctx%>/ordini"><i class="fa-solid fa-receipt"></i> I miei ordini</a>
        <a class="slink" href="<%=ctx%>/wishlist.jsp"><i class="fa-solid fa-heart"></i> Wishlist</a>
      </aside>

      <!-- Main -->
      <main class="main">
        <!-- Dati personali -->
        <section class="card panel">
          <h2><i class="fa-solid fa-id-card-clip"></i> Dati personali</h2>
          <form action="<%=ctx%>/profile/update" method="post">
            <div class="grid">
              <div class="row"><label>Nome</label><input class="input" name="nome" value="<%= u.getNome() %>"></div>
              <div class="row"><label>Cognome</label><input class="input" name="cognome" value="<%= u.getCognome() %>"></div>
              <div class="row"><label>Email</label><input class="input" type="email" name="email" value="<%= u.getEmail()!=null?u.getEmail():"" %>"></div>
              <div class="row"><label>Telefono</label><input class="input" name="telefono" value="<%= u.getTelefono()!=null?u.getTelefono():"" %>"></div>
              <div class="row"><label>Indirizzo</label><input class="input" name="indirizzo" value="<%= u.getIndirizzo()!=null?u.getIndirizzo():"" %>"></div>
              <div class="row"><label>Età</label><input class="input" type="number" name="eta" value="<%= u.getEta()!=null?u.getEta():"" %>"></div>
            </div>
            <div class="actions-form">
              <button type="reset" class="btn">Annulla</button>
              <button type="submit" class="btn primary" >Salva modifiche</button>
            </div>
          </form>
          <div style="margin-top:16px;text-align:right;">
            <button type="button" id="togglePwd" class="btn"><i class="fa-solid fa-key"></i> Cambia password</button>
          </div>
        </section>

        <!-- Cambio password (inizialmente nascosto) -->
        <section class="card panel" id="pwdPanel">
          <h2><i class="fa-solid fa-key"></i> Cambia password</h2>
          <form action="<%=ctx%>/profile/change-password" method="post">
            <div class="grid">
              <div class="row"><label>Password attuale</label><input class="input" type="password" name="oldPassword"></div>
              <div class="row"><label>Nuova password</label><input class="input" type="password" name="newPassword" placeholder="Min 8, Aa1@"></div>
              <div class="row"><label>Conferma nuova</label><input class="input" type="password" name="newPassword2"></div>
            </div>
            <div class="actions-form">
              <button type="reset" class="btn">Annulla</button>
              <button type="submit" class="btn primary">Aggiorna password</button>
            </div>
          </form>
          <!-- ✅ Messaggi di feedback -->
  <% if (request.getAttribute("errore") != null) { %>
  <div class="alert error">
    <i class="fa-solid fa-circle-xmark"></i>
    <%= request.getAttribute("errore") %>
  </div>
<% } %>
<% if (request.getAttribute("successo") != null) { %>
  <div class="alert success">
    <i class="fa-solid fa-circle-check"></i>
    <%= request.getAttribute("successo") %>
  </div>
<% } %>
   
        </section>
		<%@ include file="footer.jspf" %>
      </main>
    </section>
  </div>

  <script>
    document.getElementById("togglePwd").addEventListener("click",()=>{
      const panel=document.getElementById("pwdPanel");
      panel.style.display = panel.style.display==="none" || !panel.style.display ? "block":"none";
    });
    
  // Nasconde i messaggi dopo 4 secondi
  setTimeout(() => {
    document.querySelectorAll(".alert").forEach(el => {
      el.style.transition = "opacity .5s, transform .5s";
      el.style.opacity = "0";
      el.style.transform = "translateY(-6px)";
      setTimeout(() => el.remove(), 500); // rimuove dal DOM dopo fade
    });
  }, 4000);
</script>
</body>
</html>
