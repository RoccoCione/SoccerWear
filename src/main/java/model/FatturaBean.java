package model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class FatturaBean {
    private int id;
    private int ordineId;
    private Timestamp dataEmissione;
    private BigDecimal totaleSpesa;
    private BigDecimal totaleIva;

    public int getId() { return id; }
    public void setId(int id){ this.id = id; }

    public int getOrdineId(){ return ordineId; }
    public void setOrdineId(int ordineId){ this.ordineId = ordineId; }

    public Timestamp getDataEmissione(){ return dataEmissione; }
    public void setDataEmissione(Timestamp dataEmissione){ this.dataEmissione = dataEmissione; }

    public BigDecimal getTotaleSpesa(){ return totaleSpesa; }
    public void setTotaleSpesa(BigDecimal totaleSpesa){ this.totaleSpesa = totaleSpesa; }

    public BigDecimal getTotaleIva(){ return totaleIva; }
    public void setTotaleIva(BigDecimal totaleIva){ this.totaleIva = totaleIva; }
}
