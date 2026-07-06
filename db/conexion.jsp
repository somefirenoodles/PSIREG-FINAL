<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%-- Punto único de conexión JDBC; las páginas no deben repetir credenciales ni cargar el driver. --%>
<%!
    // Precedencia: propiedad -D de Java, variable de entorno y, por último, valor local de desarrollo.
    private static String configuracion(
            String propiedadJava, String variableEntorno, String valorLocal) {
        String valor = System.getProperty(propiedadJava);
        if (valor == null || valor.trim().isEmpty()) {
            valor = System.getenv(variableEntorno);
        }
        return (valor == null || valor.trim().isEmpty()) ? valorLocal : valor;
    }

    private static final String DB_URL = configuracion(
        "psireg.db.url",
        "PSIREG_DB_URL",
        "jdbc:mysql://127.0.0.1:3307/psireg_db"
            + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true");
    private static final String DB_USER =
        configuracion("psireg.db.user", "PSIREG_DB_USER", "root");
    private static final String DB_PASSWORD =
        configuracion("psireg.db.password", "PSIREG_DB_PASSWORD", "");

    public static Connection obtenerConexion() throws SQLException {
        try {
            // El driver se distribuye en WEB-INF/lib y queda aislado para esta aplicación web.
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("No se encontró el driver JDBC de MySQL.", e);
        }
    }
%>
