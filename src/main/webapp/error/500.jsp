<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <title>Errore interno</title>
  <style>
    body{font-family:sans-serif;background:#111;color:#fff;text-align:center;padding:50px}
    h1{color:#e63946}
    pre{background:#222;padding:10px;border-radius:6px;max-width:80%;margin:20px auto;overflow:auto}
    a{color:#ffd700;font-weight:700;text-decoration:none}
  </style>
</head>
<body>
  <h1>500 - Errore interno</h1>
  <p>Si è verificato un errore durante l'elaborazione della richiesta.</p>
  <%-- mostra stacktrace solo in debug (rimuovi in produzione) --%>
  <pre><%= exception != null ? exception.getMessage() : "Errore sconosciuto" %></pre>
  <p><a href="<%= request.getContextPath() %>/home.jsp">Torna alla home</a></p>
</body>
</html>
