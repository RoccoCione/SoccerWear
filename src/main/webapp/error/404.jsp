<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <title>Pagina non trovata</title>
  <style>
    body{font-family:sans-serif;background:#111;color:#fff;text-align:center;padding:50px}
    h1{color:#ffd700}
    a{color:#ffd700;font-weight:700;text-decoration:none}
  </style>
</head>
<body>
  <h1>404 - Pagina non trovata</h1>
  <p>La risorsa richiesta non esiste o è stata spostata.</p>
  <p><a href="<%= request.getContextPath() %>/home.jsp">Torna alla home</a></p>
</body>
</html>
