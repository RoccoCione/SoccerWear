<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <title>Accesso negato</title>
  <style>
    body {
      margin: 0;
      font-family: "Inter", system-ui, sans-serif;
      background: linear-gradient(180deg, #1a1a1a, #0d0d0d);
      color: #fff;
      text-align: center;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      overflow: hidden;
    }

    h1 {
      font-size: 3rem;
      color: #ff4d4d;
      margin-bottom: 10px;
      text-shadow: 0 0 8px rgba(255, 0, 0, .6);
      animation: pulse 1.8s infinite;
    }

    p {
      margin: 10px 0;
      font-size: 1.1rem;
      opacity: .9;
    }

    a {
      display: inline-block;
      margin-top: 20px;
      padding: 12px 20px;
      border-radius: 14px;
      font-weight: 800;
      color: #111;
      background: linear-gradient(180deg, #ffd700, #e6c200);
      text-decoration: none;
      box-shadow: 0 4px 10px rgba(0,0,0,.4);
      transition: transform .15s ease, box-shadow .15s ease;
    }
    a:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 14px rgba(0,0,0,.6);
    }

    /* Icona simpatica */
    .icon {
      font-size: 5rem;
      margin-bottom: 20px;
      color: #ff4d4d;
      animation: shake 1.2s infinite;
    }

    @keyframes pulse {
      0%, 100% { text-shadow: 0 0 8px rgba(255, 0, 0, .6); }
      50% { text-shadow: 0 0 18px rgba(255, 0, 0, 1); }
    }

    @keyframes shake {
      0%, 100% { transform: translateX(0); }
      25% { transform: translateX(-4px); }
      75% { transform: translateX(4px); }
    }
  </style>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.5.2/css/all.min.css" />
</head>
<body>
  <div class="icon"><i class="fa-solid fa-ban"></i></div>
  <h1>403 - Accesso negato</h1>
  <p>Non hai i permessi per visualizzare questa pagina.</p>
  <p><a href="<%= request.getContextPath() %>/home.jsp"><i class="fa-solid fa-house"></i> Torna alla home</a></p>
</body>
</html>
