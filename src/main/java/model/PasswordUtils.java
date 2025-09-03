package model;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.SecureRandom;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

/**
 * Utility class per gestire l'hashing e la verifica delle password
 * usando l'algoritmo PBKDF2 con HMAC-SHA256.
 *
 * - Non memorizza mai password in chiaro.
 * - Genera automaticamente un salt casuale.
 * - Permette di verificare la password senza mai doverla decifrare.
 */
public final class PasswordUtils {

    // Algoritmo scelto per PBKDF2
    private static final String ALGO = "PBKDF2WithHmacSHA256";
    // Numero di iterazioni (più alto = più sicuro, ma più costoso)
    private static final int ITERATIONS = 100_000;
    // Lunghezza del salt in byte (16 = 128 bit)
    private static final int SALT_LEN = 16;
    // Lunghezza della chiave derivata (256 bit)
    private static final int KEY_LEN = 256;

    // Costruttore privato: questa è una utility class, non istanziabile
    private PasswordUtils() {}

    /**
     * Crea un hash sicuro a partire dalla password in chiaro.
     * Formato restituito:
     *   pbkdf2_sha256$ITERAZIONI$SALT_BASE64$HASH_BASE64
     */
    public static String hash(String passwordPlain) {
        if (passwordPlain == null) throw new IllegalArgumentException("password nulla");

        // Genera un salt casuale
        byte[] salt = new byte[SALT_LEN];
        new SecureRandom().nextBytes(salt);

        // Deriva la chiave (hash) con PBKDF2
        byte[] hash = pbkdf2(passwordPlain.toCharArray(), salt, ITERATIONS, KEY_LEN);

        // Codifica salt e hash in Base64 per salvarli in DB come stringa
        String saltB64 = Base64.getEncoder().encodeToString(salt);
        String hashB64 = Base64.getEncoder().encodeToString(hash);

        // Restituisce una stringa che contiene tutte le info necessarie
        return String.format("pbkdf2_sha256$%d$%s$%s", ITERATIONS, saltB64, hashB64);
    }

    /**
     * Verifica se la password in chiaro corrisponde all'hash salvato.
     *
     * @param passwordPlain password inserita dall'utente
     * @param stored valore salvato nel DB
     * @return true se la password è corretta, false altrimenti
     */
    public static boolean verify(String passwordPlain, String stored) {
        if (passwordPlain == null || stored == null) return false;

        // Supporto legacy: se stored non ha il formato PBKDF2,
        // fa un confronto in chiaro (sconsigliato, utile solo per migrazione)
        if (!stored.startsWith("pbkdf2_sha256$")) {
            return passwordPlain.equals(stored);
        }

        // Divide la stringa salvata in: [algo, iterazioni, salt, hash]
        String[] parts = stored.split("\\$");
        if (parts.length != 4) return false;

        int iters = Integer.parseInt(parts[1]);
        byte[] salt = Base64.getDecoder().decode(parts[2]);
        byte[] expected = Base64.getDecoder().decode(parts[3]);

        // Rigenera l'hash a partire dalla password inserita
        byte[] test = pbkdf2(passwordPlain.toCharArray(), salt, iters, expected.length * 8);

        // Confronta in modo "constant time" per evitare timing attacks
        return slowEquals(expected, test);
    }

    /**
     * Funzione di supporto per generare l'hash PBKDF2.
     */
    private static byte[] pbkdf2(char[] password, byte[] salt, int iterations, int keyLenBits) {
        try {
            PBEKeySpec spec = new PBEKeySpec(password, salt, iterations, keyLenBits);
            SecretKeyFactory skf = SecretKeyFactory.getInstance(ALGO);
            return skf.generateSecret(spec).getEncoded();
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new IllegalStateException("Errore PBKDF2", e);
        }
    }

    /**
     * Confronto sicuro tra due array di byte.
     * Evita che il tempo di esecuzione vari a seconda
     * del primo byte diverso trovato (mitigazione timing attacks).
     */
    private static boolean slowEquals(byte[] a, byte[] b) {
        if (a == null || b == null || a.length != b.length) return false;
        int diff = 0;
        for (int i = 0; i < a.length; i++) diff |= a[i] ^ b[i];
        return diff == 0;
    }
}
