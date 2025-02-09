package main.java.com.dsas.demo.security;

public interface EncryptionService {
    String encrypt(String data);
    String decrypt(String encryptedData);
}
