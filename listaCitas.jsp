<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="db/conexion.jsp" %>
<%@ include file="includes/utilidades.jsp" %>
<%
    request.setAttribute("rolPermitido", "ADMIN");
%>
<%@ include file="includes/validarSesion.jsp" %>
<%
    String error = null;
    String estado = p(request, "estado");
    String fecha = p(request, "fecha");
    String idPsicologo = p(request, "idPsicologo");
    List<Map<String, String>> citas = new ArrayList<Map<String, String>>();
    List<String[]> psicologos = new ArrayList<String[]>();

    try (Connection cn = obtenerConexion()) {
        String sql = "SELECT id_cita, fecha, hora, nombre_servicio, id_psicologo, psicologo, "
                   + "id_paciente, tipo_paciente, nombre_completo AS paciente, cedula, motivo, observaciones, estado_cita "
                   + "FROM vw_expediente_paciente "
                   + "WHERE (? IS NULL OR estado_cita = ?) "
                   + "AND (? IS NULL OR fecha = ?) "
                   + "AND (? IS NULL OR id_psicologo = ?) "
                   + "ORDER BY fecha DESC, hora DESC, id_cita DESC";

        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            if (vacio(estado)) { ps.setNull(1, Types.VARCHAR); ps.setNull(2, Types.VARCHAR); }
            else { ps.setString(1, estado); ps.setString(2, estado); }

            if (vacio(fecha)) { ps.setNull(3, Types.DATE); ps.setNull(4, Types.DATE); }
            else {
                java.sql.Date f = java.sql.Date.valueOf(fecha);
                ps.setDate(3, f);
                ps.setDate(4, f);
            }

            if (vacio(idPsicologo)) { ps.setNull(5, Types.INTEGER); ps.setNull(6, Types.INTEGER); }
            else {
                int id = Integer.parseInt(idPsicologo);
                ps.setInt(5, id);
                ps.setInt(6, id);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> fila = new HashMap<String, String>();
                    fila.put("id_cita", rs.getString("id_cita"));
                    fila.put("fecha", rs.getString("fecha"));
                    fila.put("hora", rs.getString("hora"));
                    fila.put("nombre_servicio", rs.getString("nombre_servicio"));
                    fila.put("id_psicologo", rs.getString("id_psicologo"));
                    fila.put("psicologo", rs.getString("psicologo"));
                    fila.put("id_paciente", rs.getString("id_paciente"));
                    fila.put("tipo_paciente", rs.getString("tipo_paciente"));
                    fila.put("paciente", rs.getString("paciente"));
                    fila.put("cedula", rs.getString("cedula"));
                    fila.put("motivo", rs.getString("motivo"));
                    fila.put("observaciones", rs.getString("observaciones"));
                    fila.put("estado_cita", rs.getString("estado_cita"));
                    citas.add(fila);
                }
            }
        }

        cargarOpciones(cn,
            "SELECT id_psicologo, nombre_completo FROM vw_lista_psicologos WHERE estado = 'ACTIVO' ORDER BY nombre_completo",
            psicologos, "id_psicologo", "nombre_completo");
    } catch (Exception ex) {
        getServletContext().log("Error al consultar lista general de citas.", ex);
        error = "No fue posible consultar las citas.";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PSIREG | Lista de citas</title>
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
                <h1>Lista general de citas</h1>
                <p>Consulta administrativa de atenciones registradas.</p>
            </header>

            <form class="card" method="get" action="listaCitas.jsp">
                <div class="form-group">
                    <label for="estado">Estado</label>
                    <select class="input-pill" id="estado" name="estado">
                        <option value="" <%= selected(estado, "") %>>Todos los estados</option>
                        <option value="PENDIENTE" <%= selected(estado, "PENDIENTE") %>>PENDIENTE</option>
                        <option value="ATENDIDA" <%= selected(estado, "ATENDIDA") %>>ATENDIDA</option>
                        <option value="CANCELADA" <%= selected(estado, "CANCELADA") %>>CANCELADA</option>
                        <option value="REPROGRAMADA" <%= selected(estado, "REPROGRAMADA") %>>REPROGRAMADA</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="fecha">Fecha</label>
                    <input class="input-pill" id="fecha" type="date" name="fecha" value="<%= e(fecha) %>">
                </div>
                <div class="form-group">
                    <label for="idPsicologo">Psicólogo</label>
                    <select class="input-pill" id="idPsicologo" name="idPsicologo">
                        <option value="" <%= selected(idPsicologo, "") %>>Todos los psicólogos</option>
                        <% for (String[] psicologo : psicologos) { %>
                            <option value="<%= e(psicologo[0]) %>" <%= selected(idPsicologo, psicologo[0]) %>><%= e(psicologo[1]) %></option>
                        <% } %>
                    </select>
                </div>
                <button class="btn-primary" type="submit">Filtrar</button>
            </form>

            <% if (error != null) { %><p class="message-error"><%= e(error) %></p><% } %>

            <div class="table-wrapper">
                <table class="table-clean">
                    <thead>
                        <tr>
                            <th>ID cita</th>
                            <th>Paciente</th>
                            <th>Cédula</th>
                            <th>Psicólogo</th>
                            <th>Fecha</th>
                            <th>Hora</th>
                            <th>Motivo</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (citas.isEmpty()) { %>
                            <tr><td colspan="8">No hay citas para los filtros seleccionados.</td></tr>
                        <% } else { %>
                            <% for (Map<String, String> cita : citas) { %>
                                <tr>
                                    <td><%= e(cita.get("id_cita")) %></td>
                                    <td>
                                        <a href="detalleExpediente.jsp?id_paciente=<%= e(cita.get("id_paciente")) %>&amp;tipo_paciente=<%= e(cita.get("tipo_paciente")) %>">
                                            <%= e(cita.get("paciente")) %>
                                        </a>
                                    </td>
                                    <td><%= e(cita.get("cedula")) %></td>
                                    <td><%= e(cita.get("psicologo")) %></td>
                                    <td><%= e(cita.get("fecha")) %></td>
                                    <td><%= e(cita.get("hora")) %></td>
                                    <td><%= e(cita.get("motivo")) %></td>
                                    <td><span class="<%= badge(cita.get("estado_cita")) %>"><%= e(cita.get("estado_cita")) %></span></td>
                                </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>
    </main>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>
