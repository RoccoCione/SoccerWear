<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctx = request.getContextPath();
  String id = request.getParameter("id");
%>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8">
  <title>Ordine confermato</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet">
  <style>
    body{margin:0;background:#111;color:#fff;font-family:"Inter",system-ui,Segoe UI,Roboto,Arial,sans-serif}
    .wrap{min-height:100vh;display:flex;align-items:center;justify-content:center;padding:28px}
    .card{max-width:600px;background:#fff;color:#111;border:1px solid #ddd;border-radius:16px;padding:24px;text-align:center}
    .btn{display:inline-block;margin-top:12px;padding:12px 16px;border-radius:12px;border:1px solid #2c2c39;background:#111;color:#fff;font-weight:800;text-decoration:none}
  </style>
</head>
<body>
  <div class="wrap">
    <div class="card">
      <h1>🎉 Ordine confermato!</h1>
      <p>Grazie per il tuo acquisto.</p>
      <% if (id != null) { %>
        <p>Numero ordine: <strong>#<%= id %></strong></p>
      <% } %>
      <a class="btn" href="<%=ctx%>/catalogo.jsp">Torna al catalogo</a>
    </div>
  </div>
</body>
</html>
