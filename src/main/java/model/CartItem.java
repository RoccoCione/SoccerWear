package model;

public class CartItem {
    private int productId;
    private String nome;
    private double prezzo;  // prezzo unitario ivato o non ivato? => qui usiamo il listino (netto) e separiamo l’iva nel totale del carrello
    private double iva;     // percentuale (es. 22.00)
    private String taglia;  // S/M/L/XL
    private int quantita;
    private String nomeRetro;    // personalizzazione (opzionale)
    private String numeroRetro;  // personalizzazione (opzionale)

    public CartItem() {}

    public CartItem(int productId, String nome, double prezzo, double iva, String taglia, int quantita,
                    String nomeRetro, String numeroRetro) {
        this.productId = productId;
        this.nome = nome;
        this.prezzo = prezzo;
        this.iva = iva;
        this.taglia = taglia;
        this.quantita = quantita;
        this.nomeRetro = nomeRetro;
        this.numeroRetro = numeroRetro;
    }

    // Chiave logica per merge: stesso prodotto + stessa taglia + stessa personalizzazione
    public boolean sameKey(CartItem other) {
        if (other == null) return false;
        if (this.productId != other.productId) return false;
        if (this.taglia == null ? other.taglia != null : !this.taglia.equals(other.taglia)) return false;
        if (this.nomeRetro == null ? other.nomeRetro != null : !this.nomeRetro.equals(other.nomeRetro)) return false;
        if (this.numeroRetro == null ? other.numeroRetro != null : !this.numeroRetro.equals(other.numeroRetro)) return false;
        return true;
    }

    public double getTotaleRigaNetto() {
        return prezzo * quantita;
    }
    public double getTotaleRigaIva() {
        return getTotaleRigaNetto() * (iva / 100.0);
    }
    public double getTotaleRigaLordo() {
        return getTotaleRigaNetto() + getTotaleRigaIva();
    }

    // Getters/Setters
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public String getNome() { return nome; }
    public void setNome(String nome) { this.nome = nome; }
    public double getPrezzo() { return prezzo; }
    public void setPrezzo(double prezzo) { this.prezzo = prezzo; }
    public double getIva() { return iva; }
    public void setIva(double iva) { this.iva = iva; }
    public String getTaglia() { return taglia; }
    public void setTaglia(String taglia) { this.taglia = taglia; }
    public int getQuantita() { return quantita; }
    public void setQuantita(int quantita) { this.quantita = quantita; }
    public String getNomeRetro() { return nomeRetro; }
    public void setNomeRetro(String nomeRetro) { this.nomeRetro = nomeRetro; }
    public String getNumeroRetro() { return numeroRetro; }
    public void setNumeroRetro(String numeroRetro) { this.numeroRetro = numeroRetro; }
}
