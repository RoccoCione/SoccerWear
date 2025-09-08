package model;

import java.sql.Date;

public class SpedizioneBean {
    private int id;
    private String indirizzo;
    private String cap;
    private String numeroCivico;
    private String citta;
    private Date data;

    // Getters e Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getIndirizzo() { return indirizzo; }
    public void setIndirizzo(String indirizzo) { this.indirizzo = indirizzo; }

    public String getCap() { return cap; }
    public void setCap(String cap) { this.cap = cap; }

    public String getNumeroCivico() { return numeroCivico; }
    public void setNumeroCivico(String numeroCivico) { this.numeroCivico = numeroCivico; }

    public String getCitta() { return citta; }
    public void setCitta(String citta) { this.citta = citta; }

    public Date getData() { return data; }
    public void setData(Date data) { this.data = data; }

    // Metodo utile: formato unico dell'indirizzo
    public String getIndirizzoCompleto() {
        return indirizzo + " " + numeroCivico + ", " + cap + " " + citta;
    }
}
