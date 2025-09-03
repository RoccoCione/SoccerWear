package model;

import java.math.BigDecimal;

public class ProdottoBean {
    private int codice;
    private String nome;
    private Integer numeroMaglia;
    private BigDecimal costo;
    private BigDecimal iva;
    private String taglia;
    private String categoria;
    private String squadra;
    private byte[] foto; // se gestisci le immagini come BLOB

    // --- Getter e Setter ---
    public int getCodice() {
        return codice;
    }
    public void setCodice(int codice) {
        this.codice = codice;
    }

    public String getNome() {
        return nome;
    }
    public void setNome(String nome) {
        this.nome = nome;
    }

    public Integer getNumeroMaglia() {
        return numeroMaglia;
    }
    public void setNumeroMaglia(Integer numeroMaglia) {
        this.numeroMaglia = numeroMaglia;
    }

    public BigDecimal getCosto() {
        return costo;
    }
    public void setCosto(BigDecimal costo) {
        this.costo = costo;
    }

    public BigDecimal getIva() {
        return iva;
    }
    public void setIva(BigDecimal iva) {
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

    public String getSquadra() {
        return squadra;
    }
    public void setSquadra(String squadra) {
        this.squadra = squadra;
    }

    public byte[] getFoto() {
        return foto;
    }
    public void setFoto(byte[] foto) {
        this.foto = foto;
    }
}
