<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="db/conexion.jsp" %>
<%@ include file="includes/utilidades.jsp" %>
<%
    request.setAttribute("rolPermitido", "PSICOLOGO");
%>
<%@ include file="includes/validarSesion.jsp" %>
<%
    String error = null;
    Integer idPsicologo = null;
    List<Map<String, String>> expedientes = new ArrayList<Map<String, String>>();

    try (Connection cn = obtenerConexion()) {
        try (PreparedStatement ps = cn.prepareStatement("SELECT id_psicologo FROM psicologo WHERE id_usuario = ? AND estado = 'ACTIVO'")) {
            ps.setInt(1, ((Number) session.getAttribute("id_usuario")).intValue());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) idPsicologo = rs.getInt("id_psicologo");
                else error = "No existe un perfil de psicólogo asociado a este usuario.";
            }
        }

        if (error == null) {
            String sql = "SELECT id_paciente, tipo_paciente, paciente, cedula, correo_institucional, "
                       + "ultima_fecha_cita, ultimo_psicologo, estado_ultima_cita, total_citas "
                       + "FROM vw_expedientes "
                       + "WHERE EXISTS ("
                       + "    SELECT 1 FROM vw_expediente_paciente ep "
                       + "    WHERE ep.id_paciente = vw_expedientes.id_paciente "
                       + "    AND ep.tipo_paciente = vw_expedientes.tipo_paciente "
                       + "    AND ep.id_psicologo = ?"
                       + ") "
                       + "ORDER BY paciente";

            try (PreparedStatement ps = cn.prepareStatement(sql)) {
                ps.setInt(1, idPsicologo.intValue());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> fila = new HashMap<String, String>();
                        fila.put("id_paciente", rs.getString("id_paciente"));
                        fila.put("tipo_paciente", rs.getString("tipo_paciente"));
                        fila.put("paciente", rs.getString("paciente"));
                        fila.put("cedula", rs.getString("cedula"));
                        fila.put("correo_institucional", rs.getString("correo_institucional"));
                        fila.put("ultima_fecha_cita", rs.getString("ultima_fecha_cita"));
                        fila.put("ultimo_psicologo", rs.getString("ultimo_psicologo"));
                        fila.put("estado_ultima_cita", rs.getString("estado_ultima_cita"));
                        fila.put("total_citas", rs.getString("total_citas"));
                        expedientes.add(fila);
                    }
                }
            }
        }
    } catch (SQLException ex) {
        getServletContext().log("Error al consultar expedientes.", ex);
        error = "No fue posible cargar los expedientes.";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PSIREG | Expedientes</title>
    <link rel="stylesheet" href="css/layout.css">
    <link rel="stylesheet" href="css/formularios.css">
    <link rel="stylesheet" href="css/tablas.css">
</head>
<body>
    <jsp:include page="includes/header.jsp" />
    <jsp:include page="includes/nav.jsp" />

    <main class="container">
        <section>
            <header class="section-heading">
                <h1>Lista de expedientes</h1>
                <p>Expedientes vinculados al psicólogo autenticado.</p>
            </header>

            <% if (error != null) { %>
                <p class="message-error"><%= e(error) %></p>
            <% } else { %>
                <div class="table-wrapper">
                    <table class="table-clean">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Tipo</th>
                                <th>Paciente</th>
                                <th>Cédula</th>
                                <th>Correo</th>
                                <th>Última cita</th>
                                <th>Psicólogo</th>
                                <th>Estado</th>
                                <th>Total</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (expedientes.isEmpty()) { %>
                                <tr><td colspan="10">No hay expedientes asociados a su perfil.</td></tr>
                            <% } else { %>
                                <% for (Map<String, String> expediente : expedientes) { %>
                                    <tr>
                                        <td><%= e(expediente.get("id_paciente")) %></td>
                                        <td><%= e(expediente.get("tipo_paciente")) %></td>
                                        <td><%= e(expediente.get("paciente")) %></td>
                                        <td><%= e(expediente.get("cedula")) %></td>
                                        <td><%= e(expediente.get("correo_institucional")) %></td>
                                        <td><%= e(expediente.get("ultima_fecha_cita")) %></td>
                                        <td><%= e(expediente.get("ultimo_psicologo")) %></td>
                                        <td><%= e(expediente.get("estado_ultima_cita")) %></td>
                                        <td><%= e(expediente.get("total_citas")) %></td>
                                        <td>
                                            <a class="btn-secondary" href="detalleExpediente.jsp?id_paciente=<%= e(expediente.get("id_paciente")) %>&amp;tipo_paciente=<%= e(expediente.get("tipo_paciente")) %>">
                                                Ver expediente
                                            </a>
                                        </td>
                                    </tr>
                                <% } %>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </section>
    </main>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>
