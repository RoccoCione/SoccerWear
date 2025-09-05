package model;

import java.util.ArrayList;
import java.util.List;

public class Cart {
    private final List<CartItem> items = new ArrayList<>();

    public List<CartItem> getItems() { return items; }

    public void addOrMerge(CartItem incoming) {
        for (CartItem it : items) {
            if (it.sameKey(incoming)) {
                it.setQuantita(it.getQuantita() + incoming.getQuantita());
                return;
            }
        }
        items.add(incoming);
    }

    public void updateQuantity(int index, int quantity) {
        if (index < 0 || index >= items.size()) return;
        if (quantity <= 0) { items.remove(index); }
        else { items.get(index).setQuantita(quantity); }
    }

    public void remove(int index) {
        if (index < 0 || index >= items.size()) return;
        items.remove(index);
    }

    public void clear() { items.clear(); }

    public int getItemCount() {
        int count = 0;
        for (CartItem it : items) count += it.getQuantita();
        return count;
    }

    public double getSubtotaleNetto() {
        double sum = 0.0;
        for (CartItem it : items) sum += it.getTotaleRigaNetto();
        return sum;
    }

    public double getTotaleIva() {
        double sum = 0.0;
        for (CartItem it : items) sum += it.getTotaleRigaIva();
        return sum;
    }

    public double getTotaleLordo() {
        return getSubtotaleNetto() + getTotaleIva();
    }

    public boolean isEmpty() { return items.isEmpty(); }
    
    public void mergeItem(CartItem newItem) {
        for (CartItem curr : items) {
            boolean same =
                curr.getProductId() == newItem.getProductId() &&
                safeEq(curr.getTaglia(), newItem.getTaglia()) &&
                safeEq(curr.getNomeRetro(), newItem.getNomeRetro()) &&
                safeEq(curr.getNumeroRetro(), newItem.getNumeroRetro());
            if (same) {
                curr.setQuantita(curr.getQuantita() + newItem.getQuantita());
                return;
            }
        }
        items.add(newItem);
    }
    private boolean safeEq(String a, String b) {
        return (a == null) ? (b == null || b.isBlank()) : a.equals(b);
    }
}
