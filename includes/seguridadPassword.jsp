<%@ page import="java.security.*,javax.crypto.*,javax.crypto.spec.*,java.util.Base64" %>
<%--
    Hash de contraseña con PBKDF2.
    Formato guardado: PBKDF2$iteraciones$saltBase64$hashBase64
--%>
<%!
    private static final String PBKDF2_ALGORITHM = "PBKDF2WithHmacSHA256";
    private static final int PBKDF2_ITERATIONS = 120000;
    private static final int PBKDF2_KEY_LENGTH = 256;

    private static String generarHashPassword(String password) throws GeneralSecurityException {
        // Un salt nuevo por cuenta evita que contraseñas iguales produzcan valores almacenados iguales.
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);

        PBEKeySpec spec = new PBEKeySpec(
            password.toCharArray(), salt, PBKDF2_ITERATIONS, PBKDF2_KEY_LENGTH
        );

        byte[] hash = SecretKeyFactory.getInstance(PBKDF2_ALGORITHM)
            .generateSecret(spec)
            .getEncoded();
        spec.clearPassword();

        return "PBKDF2$" + PBKDF2_ITERATIONS + "$"
             + Base64.getEncoder().encodeToString(salt) + "$"
             + Base64.getEncoder().encodeToString(hash);
    }

    private static boolean verificarPassword(String password, String passwordHash) {
        if (password == null || passwordHash == null) return false;

        try {
            String[] partes = passwordHash.split("\\$", -1);
            if (partes.length != 4 || !"PBKDF2".equals(partes[0])) return false;

            int iteraciones = Integer.parseInt(partes[1]);
            byte[] salt = Base64.getDecoder().decode(partes[2]);
            byte[] hashEsperado = Base64.getDecoder().decode(partes[3]);

            PBEKeySpec spec = new PBEKeySpec(
                password.toCharArray(), salt, iteraciones, hashEsperado.length * 8
            );

            byte[] hashCalculado = SecretKeyFactory.getInstance(PBKDF2_ALGORITHM)
                .generateSecret(spec)
                .getEncoded();
            spec.clearPassword();

            // La comparación constante reduce filtraciones por diferencias de tiempo.
            return MessageDigest.isEqual(hashEsperado, hashCalculado);
        } catch (Exception ex) {
            // Un hash antiguo, incompleto o manipulado se trata siempre como credencial inválida.
            return false;
        }
    }
%>
