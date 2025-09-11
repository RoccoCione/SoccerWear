<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <title>Accesso negato</title>
  <style>
    body{font-family:sans-serif;background:#111;color:#fff;text-align:center;padding:50px}
    h1{color:#ff4d4d}
    a{color:#ffd700;font-weight:700;text-decoration:none}
  </style>
</head>
<body>
  <h1>403 - Accesso negato</h1>
  <p>Non hai i permessi per visualizzare questa pagina.</p>
  <p><a href="<%= request.getContextPath() %>/home.jsp">Torna alla home</a></p>
</body>
</html>
