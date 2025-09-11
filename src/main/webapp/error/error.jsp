<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <title>Errore</title>
  <style>
    body{font-family:sans-serif;background:#111;color:#fff;text-align:center;padding:50px}
    h1{color:#aaa}
    a{color:#ffd700;font-weight:700;text-decoration:none}
  </style>
</head>
<body>
  <h1>Oops! Qualcosa è andato storto.</h1>
  <p><%= exception != null ? exception.getMessage() : "Errore imprevisto" %></p>
  <p><a href="<%= request.getContextPath() %>/home.jsp">Torna alla home</a></p>
</body>
</html>
