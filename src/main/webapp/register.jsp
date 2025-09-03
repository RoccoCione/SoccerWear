<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String errore = (String) request.getAttribute("errore");
%>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Registrati</title>
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
    .hint{font-size:12px;color:var(--muted);margin-top:4px;}
    .field-msg{font-size:13px;margin-top:4px;font-weight:600;}
    .ok{color:#4caf50;}
    .bad{color:#ff6b6b;}
    @media(max-width:520px){.card{padding:26px 22px 18px;}.btn{width:100%;}.ball{width:min(760px,120vw);}}
  </style>
</head>
<body>
  <main class="scene">
    <div class="backdrop" aria-hidden="true">
      <img src="img/ball.png" alt="Pallone" class="ball" />
    </div>

    <section class="card" id="register-card">
      <h1 class="title">REGISTRATI</h1>

      <% if (errore != null) { %>
        <p class="error"><%= errore %></p>
      <% } %>

      <form class="form" action="register" method="post" id="register-form" novalidate>
        <label class="label" for="nome">nome</label>
        <input class="input" type="text" id="nome" name="nome" placeholder="Mario" required />

        <label class="label" for="cognome">cognome</label>
        <input class="input" type="text" id="cognome" name="cognome" placeholder="Rossi" required />

        <label class="label" for="username">username</label>
        <input class="input" type="text" id="username" name="username" placeholder="mario.rossi" required />
        <div id="username-msg" class="field-msg"></div>

        <label class="label" for="email">email</label>
        <input class="input" type="email" id="email" name="email" placeholder="mario.rossi@email.com" required />
        <div class="hint">Usa un'email valida. Verrà controllata in tempo reale.</div>
        <div id="email-msg" class="field-msg"></div>

        <label class="label" for="password">password</label>
        <input class="input" type="password" id="password" name="password" placeholder="Almeno 8 caratteri (Aa1@)" required />
        <div id="pwd-msg" class="hint"></div>

        <button class="btn" type="submit" id="register-btn">Registrati</button>
      </form>

      <p class="meta">
        Hai già un account?
        <a class="link" href="login.jsp">Accedi</a>
      </p>
    </section>
  </main>

  <script>
  document.addEventListener("DOMContentLoaded", () => {
    document.getElementById("register-card").classList.add("fade-in");

    const form = document.getElementById("register-form");
    const email = document.getElementById("email");
    const emailMsg = document.getElementById("email-msg");
    const username = document.getElementById("username");
    const userMsg = document.getElementById("username-msg");
    const pwd = document.getElementById("password");
    const pwdMsg = document.getElementById("pwd-msg");

    // Context path dell'app (es. /WearSoccer)
    const baseUrl = "<%= request.getContextPath() %>";

    // Regex password (come lato server)
    const pwdRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;

    // Debounce helper
    const debounce = (fn, delay = 350) => (...args) => {
      clearTimeout(fn._t);
      fn._t = setTimeout(() => fn(...args), delay);
    };

    // Check password live
    function validatePwd() {
      if (!pwd.value) { pwdMsg.textContent = ""; return true; }
      if (pwdRegex.test(pwd.value)) {
        pwdMsg.textContent = "Password valida ✔";
        pwdMsg.className = "hint ok";
        return true;
      } else {
        pwdMsg.textContent = "Richiesti: minimo 8 caratteri, maiuscola, minuscola, numero e simbolo (@$!%*?&)";
        pwdMsg.className = "hint bad";
        return false;
      }
    }

    // AJAX: verifica email
    const checkEmail = debounce(async () => {
      const v = email.value.trim();
      emailMsg.textContent = "";
      emailMsg.className = "field-msg";
      if (!v) return;

      try {
        const res = await fetch(baseUrl + "/api/check-email?email=" + encodeURIComponent(v), {
          headers: { "Accept": "application/json" }
        });
        const data = await res.json(); // { exists: true/false }
        if (data.exists) {
          emailMsg.textContent = "Email già registrata";
          emailMsg.className = "field-msg bad";
        } else {
          emailMsg.textContent = "Email disponibile";
          emailMsg.className = "field-msg ok";
        }
      } catch (e) {
        emailMsg.textContent = "Impossibile verificare l'email al momento";
        emailMsg.className = "field-msg bad";
      }
    }, 400);

    // AJAX: verifica username
    const checkUsername = debounce(async () => {
      const v = username.value.trim();
      userMsg.textContent = "";
      userMsg.className = "field-msg";
      if (!v) return;

      try {
        const res = await fetch(baseUrl + "/api/check-username?username=" + encodeURIComponent(v), {
          headers: { "Accept": "application/json" }
        });
        const data = await res.json(); // { exists: true/false }
        if (data.exists) {
          userMsg.textContent = "Username non disponibile";
          userMsg.className = "field-msg bad";
        } else {
          userMsg.textContent = "Username disponibile";
          userMsg.className = "field-msg ok";
        }
      } catch (e) {
        userMsg.textContent = "Impossibile verificare lo username";
        userMsg.className = "field-msg bad";
      }
    }, 400);

    email.addEventListener("input", checkEmail);
    username.addEventListener("input", checkUsername);
    pwd.addEventListener("input", validatePwd);

    // Validazione finale prima dell'invio
    form.addEventListener("submit", (e) => {
      const okPwd = validatePwd();
      const badEmail = emailMsg.classList.contains("bad");
      const badUser = userMsg.classList.contains("bad");
      if (!okPwd || badEmail || badUser) {
        e.preventDefault();
        if (!okPwd) pwd.focus();
        else if (badEmail) email.focus();
        else if (badUser) username.focus();
      }
    });
  });
</script>

</body>
</html>
