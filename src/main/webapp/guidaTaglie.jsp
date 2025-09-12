<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="it">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Guida alle Taglie • SoccerWear</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@6.5.2/css/all.min.css" />
  <style>
    :root{
      --bg:#111; --panel:#fff; --ring:#ddd; --ink:#111; --muted:#666; --accent:#003366; --radius:16px;
    }
    *{box-sizing:border-box}
    body{margin:0;background:#111;color:#fff;font-family:Inter,system-ui,Segoe UI,Roboto,Arial,sans-serif}
    .page{min-height:100vh;padding:28px;background:linear-gradient(180deg,#1a1a1a,#0d0d0d)}
    .container{max-width:1100px;margin:0 auto;display:grid;gap:18px}
    h1{margin:6px 0 10px;text-align:center;font-weight:900}
    p.lead{margin:0 auto 8px;max-width:70ch;text-align:center;color:#d7d7de}

    .card{background:#fff;color:#111;border:1px solid #ddd;border-radius:16px;padding:18px}
    .card h2{margin:0 0 10px;font-size:20px}
    .muted{color:#666}

    /* Switch unità */
    .unit-switch{display:flex;gap:8px;justify-content:flex-end;align-items:center}
    .seg{display:inline-flex;border:1px solid #ddd;border-radius:12px;overflow:hidden}
    .seg button{
      background:#fff;border:0;padding:8px 12px;cursor:pointer;font-weight:800;color:#111
    }
    .seg button.active{background:#111;color:#fff}

    /* Tabelle */
    table{width:100%;border-collapse:collapse;margin-top:10px}
    th,td{padding:10px;border-bottom:1px solid #eee;text-align:left}
    th{color:#003366;font-weight:900}
    .badge{display:inline-block;padding:4px 8px;border-radius:999px;border:1px solid #ddd;background:#f5f7ff;color:#003366;font-weight:800}

    /* Grid sezioni */
    .grid2{display:grid;grid-template-columns:1fr 1fr;gap:18px}
    .grid3{display:grid;grid-template-columns:repeat(3,1fr);gap:18px}
    @media (max-width: 900px){ .grid3{grid-template-columns:1fr 1fr} }
    @media (max-width: 640px){ .grid2,.grid3{grid-template-columns:1fr} }

    /* How-to cards */
    .how{display:flex;gap:12px}
    .how .ico{flex:0 0 44px;height:44px;border-radius:12px;display:grid;place-items:center;background:#f2f5ff;border:1px solid #e3e9ff;color:#003366;font-size:18px}
    .how h3{margin:2px 0 4px;font-size:16px}
    .how p{margin:0;color:#555}

    /* Avvisi */
    .note{background:#fff7e6;border:1px solid #ffd89b;color:#8a4b00;border-radius:12px;padding:10px 12px}
  </style>
</head>
<body>
<div class="page">
  <%@ include file="header.jspf" %>

  <div class="container">
    <header>
      <h1><i class="fa-solid fa-ruler-combined"></i> Guida alle Taglie</h1>
      <p class="lead">
        Scegli la taglia giusta per le tue maglie da calcio. Puoi passare da <strong>cm</strong> a <strong>inch</strong> con un click.
      </p>
    </header>

    <!-- TABELLE TAGLIE -->
    <section class="card">
      <div style="display:flex;align-items:center;gap:10px;justify-content:space-between;flex-wrap:wrap">
        <h2><span class="badge">Uomo / Unisex</span></h2>
        <div class="unit-switch">
          <span class="muted">Unità:</span>
          <div class="seg">
            <button type="button" class="unit-btn active" data-unit="cm">cm</button>
            <button type="button" class="unit-btn" data-unit="in">inch</button>
          </div>
        </div>
      </div>
      <p class="muted" style="margin:4px 0 8px">Misure del capo (non del corpo). Se sei tra due taglie, valuta la più comoda per te.</p>

      <div class="grid2">
        <!-- Replica -->
        <div>
          <h3 style="margin:0 0 6px">Maglia <strong>Replica</strong> (vestibilità regular)</h3>
          <table data-table="replica">
            <thead>
              <tr><th>Taglia</th><th>Torace</th><th>Spalle</th><th>Lunghezza</th></tr>
            </thead>
            <tbody>
              <tr><td>S</td><td data-cm="96">96</td><td data-cm="42">42</td><td data-cm="70">70</td></tr>
              <tr><td>M</td><td data-cm="102">102</td><td data-cm="44">44</td><td data-cm="72">72</td></tr>
              <tr><td>L</td><td data-cm="108">108</td><td data-cm="46">46</td><td data-cm="74">74</td></tr>
              <tr><td>XL</td><td data-cm="114">114</td><td data-cm="48">48</td><td data-cm="76">76</td></tr>
            </tbody>
          </table>
        </div>

        <!-- Authentic -->
        <div>
          <h3 style="margin:0 0 6px">Maglia <strong>Authentic</strong> (vestibilità slim)</h3>
          <table data-table="auth">
            <thead>
              <tr><th>Taglia</th><th>Torace</th><th>Spalle</th><th>Lunghezza</th></tr>
            </thead>
            <tbody>
              <tr><td>S</td><td data-cm="92">92</td><td data-cm="41">41</td><td data-cm="69">69</td></tr>
              <tr><td>M</td><td data-cm="98">98</td><td data-cm="43">43</td><td data-cm="71">71</td></tr>
              <tr><td>L</td><td data-cm="104">104</td><td data-cm="45">45</td><td data-cm="73">73</td></tr>
              <tr><td>XL</td><td data-cm="110">110</td><td data-cm="47">47</td><td data-cm="75">75</td></tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="note" style="margin-top:12px">
        <strong>Consiglio:</strong> le versioni <em>Authentic</em> sono più aderenti: se preferisci vestibilità comoda, considera una taglia in più.
      </div>
    </section>

    <!-- KIDS -->
    <section class="card">
      <h2><span class="badge">Junior / Kids</span></h2>
      <table data-table="kids">
        <thead>
          <tr><th>Taglia</th><th>Altezza bimbo</th><th>Torace</th><th>Lunghezza</th></tr>
        </thead>
        <tbody>
          <tr><td>6-7 anni</td><td data-cm="116-122">116–122</td><td data-cm="62">62</td><td data-cm="49">49</td></tr>
          <tr><td>8-9 anni</td><td data-cm="128-134">128–134</td><td data-cm="68">68</td><td data-cm="54">54</td></tr>
          <tr><td>10-11 anni</td><td data-cm="140-146">140–146</td><td data-cm="76">76</td><td data-cm="59">59</td></tr>
          <tr><td>12-13 anni</td><td data-cm="152-158">152–158</td><td data-cm="84">84</td><td data-cm="64">64</td></tr>
        </tbody>
      </table>
    </section>

    <!-- COME MISURARE -->
    <section class="card">
      <h2>Come misurare correttamente</h2>
      <div class="grid3">
        <div class="how">
          <div class="ico"><i class="fa-solid fa-arrows-left-right-to-line"></i></div>
          <div>
            <h3>Torace</h3>
            <p>Avvolgi il metro orizzontalmente nel punto più ampio del petto, mantenendo il metro parallelo al suolo.</p>
          </div>
        </div>
        <div class="how">
          <div class="ico"><i class="fa-solid fa-person"></i></div>
          <div>
            <h3>Spalle</h3>
            <p>Misura da cucitura a cucitura dietro, sulla linea delle spalle.</p>
          </div>
        </div>
        <div class="how">
          <div class="ico"><i class="fa-solid fa-ruler-vertical"></i></div>
          <div>
            <h3>Lunghezza</h3>
            <p>Dal punto più alto della spalla (vicino al collo) fino al fondo della maglia.</p>
          </div>
        </div>
      </div>
      <p class="muted" style="margin-top:10px">
        Le misure possono variare di ±1–2 cm a seconda del produttore. Se sei tra due taglie, scegli in base alla vestibilità preferita.
      </p>
    </section>

    <!-- FAQ -->
    <section class="card">
      <h2>FAQ veloci</h2>
      <details>
        <summary><strong>È meglio una taglia in più per indossarla sopra ad altri strati?</strong></summary>
        <p class="muted">Sì, se prevedi di indossare la maglia sopra felpe o intimo termico, considera una taglia in più.</p>
      </details>
      <details>
        <summary><strong>Le misure sono del corpo o del capo?</strong></summary>
        <p class="muted">Sono misure del capo. Confrontale con una tua maglia che ti sta bene per una scelta più precisa.</p>
      </details>
    </section>

    <%@ include file="footer.jspf" %>
  </div>
</div>

<script>
(function(){
  var unit = 'cm'; // default
  var btns = document.querySelectorAll('.unit-btn');

  function cmToIn(n){ return (n / 2.54); }
  function fmt(n){ return Math.round(n * 10) / 10; }

  function applyUnit(){
    var allTables = document.querySelectorAll('table[data-table]');
    allTables.forEach(function(tbl){
      tbl.querySelectorAll('td[data-cm]').forEach(function(td){
        var raw = td.getAttribute('data-cm'); // può essere "116-122" oppure "96"
        if (!raw) return;

        if (raw.indexOf('-') > -1){
          // Range tipo 116-122
          var parts = raw.split('-').map(function(x){ return parseFloat(x); });
          if (parts.length === 2 && parts.every(function(x){ return !isNaN(x); })){
            if (unit === 'cm'){
              td.textContent = parts[0] + '–' + parts[1];
            } else {
              td.textContent = fmt(cmToIn(parts[0])) + '–' + fmt(cmToIn(parts[1]));
            }
            td.textContent += unit === 'cm' ? ' cm' : ' in';
          }
        } else {
          // Singolo valore
          var v = parseFloat(raw);
          if (!isNaN(v)){
            td.textContent = (unit === 'cm' ? v : fmt(cmToIn(v))) + ' ' + unit;
          }
        }
      });
    });

    // toggle buttons
    btns.forEach(function(b){
      b.classList.toggle('active', b.getAttribute('data-unit') === unit);
    });
  }

  btns.forEach(function(b){
    b.addEventListener('click', function(){
      unit = b.getAttribute('data-unit') || 'cm';
      applyUnit();
    });
  });

  // init
  applyUnit();
})();
</script>
</body>
</html>
