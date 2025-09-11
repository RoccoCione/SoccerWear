<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String errore = (String) request.getAttribute("errore");
%>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Login</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">

  <style>
    :root{--bg-1:#0b0031;--bg-2:#16004b;--card-1:#161616;--card-2:#0e0e0e;--ring:#2b2b2b;--text:#eaeaea;--muted:#bdbdbd;--accent:#ffffff;--btn-top:#242424;--btn-btm:#1a1a1a;--focus:#7aa2ff;--radius:16px;--shadow:0 20px 60px rgba(0,0,0,.45),0 2px 10px rgba(0,0,0,.4);--inner:inset 0 1px 0 rgba(255,255,255,.04),inset 0 0 0 1px rgba(255,255,255,.04);}
    *{box-sizing:border-box;}html,body{height:100%;margin:0;}
    body{font-family:"Inter",sans-serif;color:var(--text);background:radial-gradient(80% 80% at 50% 50%,var(--bg-2),var(--bg-1));overflow:hidden;}
    .scene{position:relative;display:grid;place-items:center;min-height:100dvh;padding:32px;}
    .backdrop{position:absolute;inset:0;display:grid;place-items:center;pointer-events:none;background:radial-gradient(55% 55% at 50% 45%,transparent 0 60%,rgba(0,0,0,.35) 100%);}
    .ball{width:min(880px,95vw);max-width:1000px;filter:drop-shadow(0 40px 80px rgba(0,0,0,.45));opacity:.95;transform:translateY(-6px);}
    .card{position:relative;width:100%;max-width:520px;padding:32px 32px 22px;border-radius:var(--radius);background:linear-gradient(180deg,var(--card-1),var(--card-2));border:1px solid var(--ring);box-shadow:var(--shadow);backdrop-filter:blur(2px);opacity:0;transform:translateY(40px);transition:opacity 0.6s ease,transform 0.6s ease;}
    .card.fade-in{opacity:1;transform:translateY(0);}
    .title{margin:8px 0 22px;text-align:center;font-weight:800;letter-spacing:.06em;font-size:clamp(26px,4vw,36px);}
    .form{display:grid;gap:14px;}
    .label{font-size:14px;color:var(--muted);margin-top:4px;}
    .input{width:100%;padding:14px;border-radius:12px;border:1px solid var(--ring);background:#0f0f10;color:var(--text);outline:none;box-shadow:var(--inner);transition:border-color .15s ease,box-shadow .15s ease;}
    .input::placeholder{color:#808080;}
    .input:focus{border-color:var(--focus);box-shadow:0 0 0 3px color-mix(in srgb,var(--focus) 30%,transparent);}
    .btn{margin-top:12px;width:max(160px,42%);justify-self:center;padding:12px 18px;font-weight:700;font-size:20px;border:1px solid #2a2a2a;border-radius:12px;color:var(--accent);background:linear-gradient(180deg,var(--btn-top),var(--btn-btm));box-shadow:0 10px 24px rgba(0,0,0,.35),var(--inner);cursor:pointer;transition:transform .06s ease,box-shadow .2s ease,filter .2s ease;}
    .btn:hover{filter:brightness(1.06);} .btn:active{transform:translateY(1px) scale(.995);}
    .btn:focus-visible{outline:none;box-shadow:0 0 0 3px color-mix(in srgb,var(--focus) 35%,transparent);}
    .meta{margin:16px 0 0;text-align:center;color:var(--muted);font-size:14px;}
    .link{margin-left:6px;color:#ffffff;font-weight:600;text-decoration:none;position:relative;}
    .link::after{content:"";position:absolute;left:0;right:0;bottom:-2px;height:1px;background:currentColor;opacity:.6;transition:opacity .2s ease;}
    .link:hover::after{opacity:1;}
    .error{color:#ff6b6b;text-align:center;font-weight:600;margin-bottom:12px;}
    .password-wrapper{position:relative;display:flex;align-items:center;}
    .toggle-btn{position:absolute;right:12px;background:none;border:none;color:var(--muted);cursor:pointer;font-size:14px;}
    @media(max-width:520px){.card{padding:26px 22px 18px;}.btn{width:100%;}.ball{width:min(760px,120vw);}}
  </style>
</head>
<body>
<%
  String flashOk = (String) session.getAttribute("flashOk");
  if (flashOk != null) session.removeAttribute("flashOk");
%>
<%@ include file="toast.jspf" %>
<% if (flashOk != null) { %>
<script>
  window.addEventListener('DOMContentLoaded', function(){
    toast(<%= "\"" + flashOk.replace("\\","\\\\").replace("\"","\\\"") + "\"" %>, {
      variant: 'success',
      title: 'Registrazione completata',
      timeout: 4200
    });
  });
</script>
<% } %>


  <main class="scene">
    <div class="backdrop" aria-hidden="true">
      <img src="img/ball.png" alt="Pallone" class="ball" />
    </div>

    <section class="card" id="login-card">
      <h1 class="title">LOGIN</h1>

      <% if (errore != null) { %>
        <p class="error"><%= errore %></p>
      <% } %>

      <form class="form" action="login" method="post" id="login-form" novalidate>
        <label class="label" for="username">username</label>
        <input class="input" type="text" id="username" name="username" placeholder="mario.rossi" required />

        <label class="label" for="password">password</label>
        <div class="password-wrapper">
          <input class="input" type="password" id="password" name="password" placeholder="••••••••" required />
          <button type="button" id="togglePwd" class="toggle-btn">Mostra</button>
        </div>

        <button class="btn" type="submit">Accedi</button>
      </form>

      <p class="meta">
        Non hai un account?
        <a class="link" href="register.jsp">Registrati</a>
      </p>
    </section>
  </main>

  <script>
    document.addEventListener("DOMContentLoaded", () => {
      document.getElementById("login-card").classList.add("fade-in");

      const toggleBtn = document.getElementById("togglePwd");
      const pwd = document.getElementById("password");

      toggleBtn.addEventListener("click", () => {
        if (pwd.type === "password") {
          pwd.type = "text";
          toggleBtn.textContent = "Nascondi";
        } else {
          pwd.type = "password";
          toggleBtn.textContent = "Mostra";
        }
      });
    });
  </script>
</body>
</html>
