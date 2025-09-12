package model;

public class ProdottoBean {

    private int id;                     // PK
    private String nome;                // nome prodotto
    private String descrizione;         // descrizione o squadra
    private String tipo;       
    private double costo;               // prezzo listino attuale
    private double iva;                 // percentuale IVA
    private String taglia;              // ENUM('S','M','L','XL')
    private String categoria;           // ENUM('SerieA','PremierLeague','LaLiga','Vintage')
    private Integer unitaDisponibili;   // quantità stock
    private byte[] foto;                // immagine come BLOB
    private boolean attivo;             // 1 = attivo, 0 = disattivo

    // --- Getter e Setter ---

    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }
    public void setNome(String nome) {
        this.nome = nome;
    }

    public String getDescrizione() {
        return descrizione;
    }
    public void setDescrizione(String descrizione) {
        this.descrizione = descrizione;
    }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public double getCosto() {
        return costo;
    }
    public void setCosto(double costo) {
        this.costo = costo;
    }

    public double getIva() {
        return iva;
    }
    public void setIva(double iva) {
        this.iva = iva;
    }

    public String getTaglia() {
        return taglia;
    }
    public void setTaglia(String taglia) {
        this.taglia = taglia;
    }

    public String getCategoria() {
        return categoria;
    }
    public void setCategoria(String categoria) {
        this.categoria = categoria;
    }

    public Integer getUnitaDisponibili() {
        return unitaDisponibili;
    }
    public void setUnitaDisponibili(Integer unitaDisponibili) {
        this.unitaDisponibili = unitaDisponibili;
    }

    public byte[] getFoto() {
        return foto;
    }
    public void setFoto(byte[] foto) {
        this.foto = foto;
    }

    public boolean isAttivo() {
        return attivo;
    }
    public void setAttivo(boolean attivo) {
        this.attivo = attivo;
    }
}
