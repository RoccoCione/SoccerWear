package model;

import java.math.BigDecimal;

public class RigaOrdineBean {
    private int id;
    private int ordineId;
    private Integer productId; // può essere NULL se il prodotto viene cancellato
    private String nomeProdotto;
    private String taglia; // ENUM('S','M','L','XL')
    private BigDecimal prezzoUnitario;
    private BigDecimal iva; // percentuale es. 22.00
    private int quantita;
    private BigDecimal totaleRiga;

    // Getters e Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getOrdineId() { return ordineId; }
    public void setOrdineId(int ordineId) { this.ordineId = ordineId; }

    public Integer getProductId() { return productId; }
    public void setProductId(Integer productId) { this.productId = productId; }

    public String getNomeProdotto() { return nomeProdotto; }
    public void setNomeProdotto(String nomeProdotto) { this.nomeProdotto = nomeProdotto; }

    public String getTaglia() { return taglia; }
    public void setTaglia(String taglia) { this.taglia = taglia; }

    public BigDecimal getPrezzoUnitario() { return prezzoUnitario; }
    public void setPrezzoUnitario(BigDecimal prezzoUnitario) { this.prezzoUnitario = prezzoUnitario; }

    public BigDecimal getIva() { return iva; }
    public void setIva(BigDecimal iva) { this.iva = iva; }

    public int getQuantita() { return quantita; }
    public void setQuantita(int quantita) { this.quantita = quantita; }

    public BigDecimal getTotaleRiga() { return totaleRiga; }
    public void setTotaleRiga(BigDecimal totaleRiga) { this.totaleRiga = totaleRiga; }
}
