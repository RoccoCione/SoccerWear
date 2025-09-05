<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,model.ProdottoBean,model.UtenteBean,DAO.ProdottoDAO" %>
<%
    List<ProdottoBean> prodotti = new ProdottoDAO().findAll();
    if (prodotti == null) prodotti = java.util.Collections.emptyList();
%>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8" />
  <title>Admin • Catalogo</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.5.2/css/all.min.css" />
  <style>
    body{margin:0;background:#111;color:#f2f2f2;font-family:Inter,system-ui,sans-serif}
    .page{min-height:100vh;padding:28px 28px 40px;background:linear-gradient(180deg,#1a1a1a,#0d0d0d);overflow-x:hidden}
    .card{background:#1a1a1f;border:1px solid #2c2c39;border-radius:16px;padding:20px;margin-bottom:20px}
    table{width:100%;border-collapse:collapse;margin-top:12px}
    th,td{padding:10px;border-bottom:1px solid rgba(255,255,255,.1);text-align:left}
    th{color:#ffd700}
    td.descrizione {
 	max-width: 250px;     /* fissa la larghezza della colonna */
  	white-space: nowrap;  /* tutto su una riga */
  	overflow: hidden;     /* nasconde l’eccesso */
  	text-overflow: ellipsis; /* mette i puntini ... */
	}
    .btn{padding:8px 14px;border-radius:10px;border:none;font-weight:700;cursor:pointer}
    .btn.primary{background:#ffd700;color:#111}
    .btn.danger{background:#ff4d4d;color:#fff}
    .form-grid{display:grid;grid-template-columns:repeat(3,minmax(220px,1fr));gap:12px}
    label{font-size:13px;color:#cfcfd4;margin-bottom:4px;display:block}
    input,select,textarea{width:100%;padding:10px;border-radius:10px;border:1px solid #2c2c39;background:#0f0f12;color:#fff}
    textarea{resize:vertical;min-height:80px}

    .modal{display:none;position:fixed;z-index:1000;left:0;top:0;width:100%;height:100%;background:rgba(0,0,0,0.6);overflow-y:auto}
    .modal-content{background:#1a1a1f;color:#fff;margin:2% auto;padding:20px;border:1px solid #2c2c39;border-radius:16px;width:90%;max-width:600px;max-height:90vh;overflow-y:auto;box-shadow:0 8px 20px rgba(0,0,0,0.5)}
    .close{color:#aaa;float:right;font-size:28px;font-weight:bold;cursor:pointer}
    .close:hover{color:#fff}
    .modal-content label{display:block;margin-top:10px;font-size:13px;color:#cfcfd4}
    .modal-content input,.modal-content select,.modal-content textarea{width:100%;padding:10px;border-radius:10px;border:1px solid #2c2c39;background:#0f0f12;color:#fff;margin-bottom:8px}
    .modal-content textarea{resize:vertical;min-height:80px}
  </style>
</head>
<body>
  <div class="page">

    <!-- Messaggi (opzionali dal servlet) -->
    <% if (request.getAttribute("errore") != null) { %>
      <div style="color:#ff6b6b;font-weight:700;margin-bottom:10px;"><%= request.getAttribute("errore") %></div>
    <% } %>
    <% if (request.getAttribute("successo") != null) { %>
      <div style="color:#4caf50;font-weight:700;margin-bottom:10px;"><%= request.getAttribute("successo") %></div>
    <% } %>

    <%@ include file="header.jspf" %>

    <h1><i class="fa-solid fa-crown"></i> Gestione Catalogo</h1>

    <!-- LISTA PRODOTTI -->
    <section class="card">
      <h2><i class="fa-solid fa-list"></i> Prodotti</h2>
      <table>
        <thead>
          <tr>
            <th>ID</th><th>Nome</th><th>Descrizione</th><th>Categoria</th>
            <th>Taglia</th><th>Numero Maglia</th><th>Disponibili</th>
            <th>Prezzo</th><th>IVA</th><th>Azioni</th>
          </tr>
        </thead>
        <tbody>
        <% if (prodotti.isEmpty()) { %>
          <tr><td colspan="10">Nessun prodotto presente.</td></tr>
        <% } else {
             for (ProdottoBean p : prodotti) { %>
          <tr>
            <td><%= p.getId() %></td>
            <td><%= p.getNome() %></td>
            <td class="descrizione" title="<%= p.getDescrizione() != null ? p.getDescrizione() : "-" %>">
  			<%= p.getDescrizione() != null ? p.getDescrizione() : "-" %>
			</td>
            <td><%= p.getCategoria() %></td>
            <td><%= p.getTaglia() %></td>
            <td><%= p.getNumeroMaglia() != null ? p.getNumeroMaglia() : "-" %></td>
            <td><%= p.getUnitaDisponibili() != null ? p.getUnitaDisponibili() : "-" %></td>
            <td><%= String.format(java.util.Locale.US, "%.2f", p.getCosto()) %> €</td>
            <td><%= String.format(java.util.Locale.US, "%.2f", p.getIva()) %>%</td>
            <td>
              <!-- Solo bottone Modifica (niente submit) -->
              <button type="button" class="btn primary btn-edit"
                data-id="<%= p.getId() %>"
                data-nome="<%= java.net.URLEncoder.encode(p.getNome(), "UTF-8") %>"
                data-desc="<%= p.getDescrizione() != null ? java.net.URLEncoder.encode(p.getDescrizione(), "UTF-8") : "" %>"
                data-cat="<%= p.getCategoria() %>"
                data-taglia="<%= p.getTaglia() %>"
                data-numero="<%= p.getNumeroMaglia() != null ? p.getNumeroMaglia() : "" %>"
                data-unita="<%= p.getUnitaDisponibili() != null ? p.getUnitaDisponibili() : "" %>"
                data-costo="<%= String.format(java.util.Locale.US, "%.2f", p.getCosto()) %>"
                data-iva="<%= String.format(java.util.Locale.US, "%.2f", p.getIva()) %>">
                <i class="fa-solid fa-pen"></i>
              </button>

              <!-- Elimina -->
              <form action="<%= ctx %>/admin/delete-prodotto" method="post" style="display:inline" onsubmit="return confirm('Eliminare il prodotto?');">
                <input type="hidden" name="id" value="<%= p.getId() %>">
                <button class="btn danger" type="submit"><i class="fa-solid fa-trash"></i></button>
              </form>
            </td>
          </tr>
        <% } } %>
        </tbody>
      </table>
    </section>

    <!-- FORM INSERIMENTO -->
    <section class="card">
      <h2><i class="fa-solid fa-plus"></i> Aggiungi nuovo prodotto</h2>
      <form action="<%= ctx %>/admin/add-prodotto" method="post" enctype="multipart/form-data">
        <div class="form-grid">
          <div><label>Nome</label><input type="text" name="nome" required></div>
          <div><label>Descrizione</label><textarea name="descrizione"></textarea></div>
          <div><label>Numero Maglia</label><input type="number" name="numero_maglia"></div>

          <div><label>Categoria</label>
            <select name="categoria" required>
              <option value="SerieA">Serie A</option>
              <option value="PremierLeague">Premier League</option>
              <option value="LaLiga">La Liga</option>
              <option value="Vintage">Vintage</option>
            </select>
          </div>

          <div><label>Taglia</label>
            <select name="taglia" required>
              <option value="S">S</option><option value="M">M</option>
              <option value="L">L</option><option value="XL">XL</option>
            </select>
          </div>

          <div><label>Disponibili</label><input type="number" name="unita_disponibili" min="0"></div>
          <div><label>Prezzo €</label><input type="number" step="0.01" name="costo" required></div>
          <div><label>IVA %</label><input type="number" step="0.01" name="iva" required></div>
          <div><label>Foto</label><input type="file" name="foto" accept="image/*"></div>
        </div>

        <div style="margin-top:14px;text-align:right">
          <button class="btn primary" type="submit">Aggiungi prodotto</button>
        </div>
      </form>
    </section>

    <!-- MODAL EDIT -->
    <div id="editModal" class="modal">
      <div class="modal-content">
        <span class="close" onclick="closeEditModal()">&times;</span>
        <h2><i class="fa-solid fa-pen"></i> Modifica prodotto</h2>

        <form id="editForm" action="<%= ctx %>/admin/edit-prodotto" method="post" enctype="multipart/form-data">
          <input type="hidden" name="id" id="editId">

          <label>Nome</label>
          <input type="text" name="nome" id="editNome" required>

          <label>Descrizione</label>
          <textarea name="descrizione" id="editDescrizione"></textarea>

          <label>Categoria</label>
          <select name="categoria" id="editCategoria" required>
            <option value="SerieA">SerieA</option>
            <option value="PremierLeague">PremierLeague</option>
            <option value="LaLiga">LaLiga</option>
            <option value="Vintage">Vintage</option>
          </select>

          <label>Taglia</label>
          <select name="taglia" id="editTaglia" required>
            <option value="S">S</option>
            <option value="M">M</option>
            <option value="L">L</option>
            <option value="XL">XL</option>
          </select>

          <label>Numero Maglia</label>
          <input type="number" name="numero_maglia" id="editNumeroMaglia">

          <label>Disponibili</label>
          <input type="number" name="unita_disponibili" id="editUnita">

          <label>Prezzo €</label>
          <input type="number" step="0.01" name="costo" id="editCosto" required>

          <label>IVA %</label>
          <input type="number" step="0.01" name="iva" id="editIva" required>

          <label>Foto (solo se vuoi sostituirla)</label>
          <input type="file" name="foto" accept="image/*">

          <div style="margin-top:14px;text-align:right">
            <button type="button" class="btn" onclick="closeEditModal()">Annulla</button>
            <button type="submit" class="btn primary">Salva modifiche</button>
          </div>
        </form>
      </div>
    </div>

    <script>
      function closeEditModal(){
        document.getElementById("editModal").style.display = "none";
      }

      // Decodifica compatibile con URLEncoder (converte + in spazio prima di decodeURIComponent)
      function decodeFromURLEncoder(s) {
        return decodeURIComponent((s || '').replace(/\+/g, '%20'));
      }

      // Delegation: intercetta click su qualunque .btn-edit
      document.addEventListener('click', function(e){
        const btn = e.target.closest('.btn-edit');
        if (!btn) return;

        const d = btn.dataset;
        const nome = decodeFromURLEncoder(d.nome);
        const desc = decodeFromURLEncoder(d.desc);

        // Popola i campi
        document.getElementById('editId').value            = d.id || '';
        document.getElementById('editNome').value          = nome;
        document.getElementById('editDescrizione').value   = desc;
        document.getElementById('editCategoria').value     = d.cat || 'SerieA';
        document.getElementById('editTaglia').value        = d.taglia || 'M';
        document.getElementById('editNumeroMaglia').value  = d.numero || '';
        document.getElementById('editUnita').value         = d.unita || '';
        document.getElementById('editCosto').value         = d.costo || '';
        document.getElementById('editIva').value           = d.iva || '';

        // Mostra la modale
        document.getElementById('editModal').style.display = 'block';
      });

      // Chiusura cliccando fuori
      window.addEventListener('click', function(e){
        if (e.target === document.getElementById('editModal')) closeEditModal();
      });
    </script>

    <%@ include file="footer.jspf" %>
  </div>
</body>
</html>
