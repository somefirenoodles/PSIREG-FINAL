<%@ page import="java.sql.*,java.util.*,java.util.regex.Pattern" %>
<%--
    Utilidades mínimas para mantener legibles las páginas JSP.
    Aquí solo vive lógica repetida: parámetros, escape HTML, selects y campos opcionales.
--%>
<%!
    private static final Pattern EMAIL_SIMPLE = Pattern.compile("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");

    private static String e(String valor) {
        if (valor == null) return "";
        return valor.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    private static String escaparHtml(String valor) {
        return e(valor);
    }

    private static String p(javax.servlet.http.HttpServletRequest request, String nombre) {
        String valor = request.getParameter(nombre);
        return valor == null ? "" : valor.trim();
    }

    private static String trim(String valor) {
        return valor == null ? "" : valor.trim();
    }

    private static boolean esPost(javax.servlet.http.HttpServletRequest request) {
        return "POST".equalsIgnoreCase(request.getMethod());
    }

    private static boolean vacio(String valor) {
        return valor == null || valor.trim().isEmpty();
    }

    private static boolean correoValido(String correo) {
        return correo != null && EMAIL_SIMPLE.matcher(correo).matches();
    }

    private static boolean unoDe(String valor, String... opciones) {
        for (String opcion : opciones) {
            if (opcion.equals(valor)) return true;
        }
        return false;
    }

    private static String selected(String actual, String esperado) {
        return esperado.equals(actual) ? "selected" : "";
    }

    private static void setTextoOpcional(PreparedStatement ps, int posicion, String valor) throws SQLException {
        if (vacio(valor)) ps.setNull(posicion, Types.VARCHAR);
        else ps.setString(posicion, valor.trim());
    }

    private static String badge(String estado) {
        return vacio(estado) ? "badge" : "badge badge-" + estado.toLowerCase();
    }

    private static void cargarOpciones(
            Connection cn, String sql, List<String[]> destino, String id, String texto) throws SQLException {
        try (PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                destino.add(new String[] { rs.getString(id), rs.getString(texto) });
            }
        }
    }
%>
