package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class OrdineBean {
    private int id;
    private int utenteId;
    private Integer spedizioneId; // può essere NULL
    private Timestamp dataOrdine;
    private BigDecimal totaleSpesa;
    private BigDecimal totaleIva;
    private String stato;

    // Getters e Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUtenteId() { return utenteId; }
    public void setUtenteId(int utenteId) { this.utenteId = utenteId; }

    public Integer getSpedizioneId() { return spedizioneId; }
    public void setSpedizioneId(Integer spedizioneId) { this.spedizioneId = spedizioneId; }

    public Timestamp getDataOrdine() { return dataOrdine; }
    public void setDataOrdine(Timestamp dataOrdine) { this.dataOrdine = dataOrdine; }

    public BigDecimal getTotaleSpesa() { return totaleSpesa; }
    public void setTotaleSpesa(BigDecimal totaleSpesa) { this.totaleSpesa = totaleSpesa; }

    public BigDecimal getTotaleIva() { return totaleIva; }
    public void setTotaleIva(BigDecimal totaleIva) { this.totaleIva = totaleIva; }

    public String getStato() { return stato; }
    public void setStato(String stato) { this.stato = stato; }

    // Metodo comodo per avere il lordo
    public BigDecimal getTotaleLordo() {
        BigDecimal netto = totaleSpesa != null ? totaleSpesa : BigDecimal.ZERO;
        BigDecimal iva = totaleIva != null ? totaleIva : BigDecimal.ZERO;
        return netto.add(iva);
    }
}
