<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="db/conexion.jsp" %>
<%@ include file="includes/utilidades.jsp" %>
<%-- Consulta compartida: ADMIN elige profesional; PSICOLOGO queda limitado a su propio perfil. --%>
<%
    request.setAttribute("rolPermitido", "ADMIN,PSICOLOGO");
%>
<%@ include file="includes/validarSesion.jsp" %>
<%
    // El mismo endpoint adapta su alcance al rol, pero conserva una sola plantilla de resultados.
    String rol = String.valueOf(session.getAttribute("rol"));
    String error = null;
    String idPsicologoParametro = p(request, "id_psicologo");
    Integer idPsicologoConsulta = null;
    List<Map<String, String>> citas = new ArrayList<Map<String, String>>();
    List<String[]> psicologos = new ArrayList<String[]>();

    try (Connection cn = obtenerConexion()) {
        if ("PSICOLOGO".equals(rol)) {
            // Para profesionales, el perfil se obtiene de la cuenta autenticada y no de parámetros manipulables.
            try (PreparedStatement ps = cn.prepareStatement("SELECT id_psicologo FROM psicologo WHERE id_usuario = ? AND estado = 'ACTIVO'")) {
                ps.setInt(1, ((Number) session.getAttribute("id_usuario")).intValue());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) idPsicologoConsulta = rs.getInt("id_psicologo");
                    else error = "No existe un perfil de psicólogo asociado a este usuario.";
                }
            }
        } else {
            // Solo ADMIN llega a esta rama y puede escoger entre perfiles activos.
            idPsicologoConsulta = vacio(idPsicologoParametro) ? null : Integer.valueOf(idPsicologoParametro);
            cargarOpciones(cn,
                "SELECT id_psicologo, nombre_completo FROM vw_lista_psicologos WHERE estado = 'ACTIVO' ORDER BY nombre_completo",
                psicologos, "id_psicologo", "nombre_completo");
        }

        if (error == null) {
            // La vista ya unifica paciente y servicio para evitar lógica por subtipo en esta página.
            String sql = "SELECT id_cita, fecha, hora, nombre_servicio, id_psicologo, psicologo, "
                       + "id_paciente, tipo_paciente, nombre_completo AS paciente, cedula, motivo, observaciones, estado_cita "
                       + "FROM vw_expediente_paciente "
                       + "WHERE (? IS NULL OR id_psicologo = ?) "
                       + "ORDER BY fecha DESC, hora DESC, id_cita DESC";
            try (PreparedStatement ps = cn.prepareStatement(sql)) {
                if (idPsicologoConsulta == null) {
                    ps.setNull(1, Types.INTEGER);
                    ps.setNull(2, Types.INTEGER);
                } else {
                    ps.setInt(1, idPsicologoConsulta.intValue());
                    ps.setInt(2, idPsicologoConsulta.intValue());
                }

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> fila = new HashMap<String, String>();
                        fila.put("id_cita", rs.getString("id_cita"));
                        fila.put("fecha", rs.getString("fecha"));
                        fila.put("hora", rs.getString("hora"));
                        fila.put("nombre_servicio", rs.getString("nombre_servicio"));
                        fila.put("id_paciente", rs.getString("id_paciente"));
                        fila.put("tipo_paciente", rs.getString("tipo_paciente"));
                        fila.put("paciente", rs.getString("paciente"));
                        fila.put("cedula", rs.getString("cedula"));
                        fila.put("psicologo", rs.getString("psicologo"));
                        fila.put("motivo", rs.getString("motivo"));
                        fila.put("observaciones", rs.getString("observaciones"));
                        fila.put("estado_cita", rs.getString("estado_cita"));
                        citas.add(fila);
                    }
                }
            }
        }
    } catch (Exception ex) {
        getServletContext().log("Error al consultar citas por psicólogo.", ex);
        error = "No fue posible consultar las citas.";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PSIREG | Citas por psicólogo</title>
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
                <h1>Citas por psicólogo</h1>
                <p>El psicólogo solo ve las citas de su perfil profesional vinculado.</p>
            </header>

            <%-- El selector se oculta al psicólogo porque su alcance ya fue fijado en el servidor. --%>
            <% if ("ADMIN".equals(rol)) { %>
                <form class="card" method="get" action="citasPorPsicologo.jsp">
                    <div class="form-group">
                        <label for="id_psicologo">Psicólogo</label>
                        <select class="input-pill" id="id_psicologo" name="id_psicologo">
                            <option value="" <%= selected(idPsicologoParametro, "") %>>Todos los psicólogos</option>
                            <% for (String[] psicologo : psicologos) { %>
                                <option value="<%= e(psicologo[0]) %>" <%= selected(idPsicologoParametro, psicologo[0]) %>><%= e(psicologo[1]) %></option>
                            <% } %>
                        </select>
                    </div>
                    <button class="btn-primary" type="submit">Consultar</button>
                </form>
            <% } %>

            <% if (error != null) { %>
                <p class="message-error"><%= e(error) %></p>
            <% } else if (citas.isEmpty()) { %>
                <p class="message-warning">No hay citas registradas para el criterio seleccionado.</p>
            <% } else { %>
                <div class="table-wrapper">
                    <table class="table-clean">
                        <thead>
                            <tr>
                                <th>Paciente</th>
                                <th>Tipo</th>
                                <th>Fecha</th>
                                <th>Hora</th>
                                <th>Servicio</th>
                                <th>Motivo</th>
                                <th>Observaciones</th>
                                <th>Estado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, String> cita : citas) { %>
                                <tr>
                                    <td>
                                        <a href="detalleExpediente.jsp?id_paciente=<%= e(cita.get("id_paciente")) %>&amp;tipo_paciente=<%= e(cita.get("tipo_paciente")) %>">
                                            <%= e(cita.get("paciente")) %>
                                        </a>
                                    </td>
                                    <td><%= e(cita.get("tipo_paciente")) %></td>
                                    <td><%= e(cita.get("fecha")) %></td>
                                    <td><%= e(cita.get("hora")) %></td>
                                    <td><%= e(cita.get("nombre_servicio")) %></td>
                                    <td><%= e(cita.get("motivo")) %></td>
                                    <td><%= e(cita.get("observaciones")) %></td>
                                    <td><span class="<%= badge(cita.get("estado_cita")) %>"><%= e(cita.get("estado_cita")) %></span></td>
                                </tr>
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
