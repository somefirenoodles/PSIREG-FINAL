<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="db/conexion.jsp" %>
<%@ include file="includes/utilidades.jsp" %>
<%-- Muestra datos y citas del paciente identificado por la pareja tipo/id del expediente. --%>
<%
    request.setAttribute("rolPermitido", "ADMIN,PSICOLOGO");
%>
<%@ include file="includes/validarSesion.jsp" %>
<%
    String error = null;
    String tipoPaciente = p(request, "tipo_paciente");
    String idPacienteTexto = p(request, "id_paciente");
    String rol = String.valueOf(session.getAttribute("rol"));
    Integer idPaciente = null;
    Integer idPsicologo = null;
    Map<String, String> paciente = null;
    List<Map<String, String>> citas = new ArrayList<Map<String, String>>();

    try {
        idPaciente = Integer.valueOf(idPacienteTexto);
        if (!unoDe(tipoPaciente, "ESTUDIANTE", "DOCENTE", "ADMINISTRATIVO")) {
            throw new IllegalArgumentException();
        }
    } catch (Exception ex) {
        error = "El expediente solicitado no es válido.";
    }

    try (Connection cn = obtenerConexion()) {
        if (error == null && "PSICOLOGO".equals(rol)) {
            try (PreparedStatement ps = cn.prepareStatement("SELECT id_psicologo FROM psicologo WHERE id_usuario = ? AND estado = 'ACTIVO'")) {
                ps.setInt(1, ((Number) session.getAttribute("id_usuario")).intValue());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) idPsicologo = rs.getInt("id_psicologo");
                    else error = "No existe un perfil de psicólogo asociado a este usuario.";
                }
            }

            if (error == null) {
                String sqlAcceso = "SELECT 1 FROM vw_expediente_paciente "
                                 + "WHERE id_paciente = ? AND tipo_paciente = ? AND id_psicologo = ? LIMIT 1";
                try (PreparedStatement ps = cn.prepareStatement(sqlAcceso)) {
                    ps.setInt(1, idPaciente.intValue());
                    ps.setString(2, tipoPaciente);
                    ps.setInt(3, idPsicologo.intValue());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) error = "No está autorizado para consultar este expediente.";
                    }
                }
            }
        }

        if (error == null) {
            String sqlPaciente = "SELECT nombre_completo, cedula, correo_institucional, estado "
                               + "FROM vw_lista_pacientes WHERE id_paciente = ? AND tipo_paciente = ?";
            try (PreparedStatement ps = cn.prepareStatement(sqlPaciente)) {
                ps.setInt(1, idPaciente.intValue());
                ps.setString(2, tipoPaciente);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        paciente = new HashMap<String, String>();
                        paciente.put("nombre_completo", rs.getString("nombre_completo"));
                        paciente.put("cedula", rs.getString("cedula"));
                        paciente.put("correo_institucional", rs.getString("correo_institucional"));
                        paciente.put("estado", rs.getString("estado"));
                    } else {
                        error = "No se encontró el paciente solicitado.";
                    }
                }
            }
        }

        if (error == null && paciente != null) {
            String sqlCitas = "SELECT id_cita, fecha, hora, nombre_servicio, psicologo, motivo, observaciones, estado_cita "
                            + "FROM vw_expediente_paciente "
                            + "WHERE id_paciente = ? AND tipo_paciente = ? ";
            if (idPsicologo != null) sqlCitas += "AND id_psicologo = ? ";
            sqlCitas += "ORDER BY fecha DESC, hora DESC, id_cita DESC";

            try (PreparedStatement ps = cn.prepareStatement(sqlCitas)) {
                ps.setInt(1, idPaciente.intValue());
                ps.setString(2, tipoPaciente);
                if (idPsicologo != null) ps.setInt(3, idPsicologo.intValue());

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> fila = new HashMap<String, String>();
                        fila.put("id_cita", rs.getString("id_cita"));
                        fila.put("fecha", rs.getString("fecha"));
                        fila.put("hora", rs.getString("hora"));
                        fila.put("nombre_servicio", rs.getString("nombre_servicio"));
                        fila.put("psicologo", rs.getString("psicologo"));
                        fila.put("motivo", rs.getString("motivo"));
                        fila.put("observaciones", rs.getString("observaciones"));
                        fila.put("estado_cita", rs.getString("estado_cita"));
                        citas.add(fila);
                    }
                }
            }
        }
    } catch (SQLException ex) {
        getServletContext().log("Error al consultar expediente.", ex);
        error = "No fue posible consultar el expediente.";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PSIREG | Detalle de expediente</title>
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
                <h1>Detalle de expediente</h1>
                <p>Consulta protegida por id y tipo de paciente.</p>
            </header>

            <% if (error != null) { %>
                <p class="message-error"><%= e(error) %></p>
            <% } else { %>
                <section class="card">
                    <h2>Datos del paciente</h2>
                    <p><strong>Nombre:</strong> <%= e(paciente.get("nombre_completo")) %></p>
                    <p><strong>Cédula:</strong> <%= e(paciente.get("cedula")) %></p>
                    <p><strong>Correo:</strong> <%= e(paciente.get("correo_institucional")) %></p>
                    <p><strong>Tipo:</strong> <%= e(tipoPaciente) %></p>
                    <p><strong>Estado:</strong> <%= e(paciente.get("estado")) %></p>
                </section>

                <section class="resources-section">
                    <h2>Historial de citas</h2>
                    <% if (citas.isEmpty()) { %>
                        <p class="message-warning">No hay citas registradas para este expediente.</p>
                    <% } else { %>
                        <div class="table-wrapper">
                            <table class="table-clean">
                                <thead>
                                    <tr>
                                        <th>ID cita</th>
                                        <th>Fecha</th>
                                        <th>Hora</th>
                                        <th>Servicio</th>
                                        <th>Psicólogo</th>
                                        <th>Motivo</th>
                                        <th>Observaciones</th>
                                        <th>Estado</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Map<String, String> fila : citas) { %>
                                        <tr>
                                            <td><%= e(fila.get("id_cita")) %></td>
                                            <td><%= e(fila.get("fecha")) %></td>
                                            <td><%= e(fila.get("hora")) %></td>
                                            <td><%= e(fila.get("nombre_servicio")) %></td>
                                            <td><%= e(fila.get("psicologo")) %></td>
                                            <td><%= e(fila.get("motivo")) %></td>
                                            <td><%= e(fila.get("observaciones")) %></td>
                                            <td><%= e(fila.get("estado_cita")) %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                </section>
            <% } %>
        </section>
    </main>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>
