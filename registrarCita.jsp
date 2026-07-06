<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="db/conexion.jsp" %>
<%@ include file="includes/utilidades.jsp" %>
<%-- Agenda una cita para el perfil profesional asociado al usuario autenticado. --%>
<%!
    // MariaDB espera segundos; el control HTML time normalmente envía solo HH:mm.
    private static String horaSql(String hora) {
        if (hora == null) return "";
        hora = hora.trim();
        return hora.length() == 5 ? hora + ":00" : hora;
    }
%>
<%
    request.setAttribute("rolPermitido", "PSICOLOGO");
%>
<%@ include file="includes/validarSesion.jsp" %>
<%
    String error = null, exito = null, errorPerfil = null;
    String pacienteSeleccionado = "", idServicio = "", fecha = "", hora = "", motivo = "", observaciones = "";
    Integer idPsicologo = null;
    List<String[]> pacientes = new ArrayList<String[]>();
    List<String[]> servicios = new ArrayList<String[]>();

    // La cita siempre pertenece al perfil derivado de la sesión, nunca a un id enviado por el formulario.
    try (Connection cn = obtenerConexion();
         PreparedStatement ps = cn.prepareStatement("SELECT id_psicologo FROM psicologo WHERE id_usuario = ? AND estado = 'ACTIVO'")) {
        ps.setInt(1, ((Number) session.getAttribute("id_usuario")).intValue());
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) idPsicologo = rs.getInt("id_psicologo");
            else errorPerfil = "No existe un perfil de psicólogo asociado a este usuario.";
        }
    } catch (SQLException ex) {
        getServletContext().log("Error al validar psicólogo.", ex);
        errorPerfil = "No fue posible validar el perfil del psicólogo.";
    }

    if (esPost(request) && errorPerfil == null) {
        pacienteSeleccionado = p(request, "pacienteSeleccionado");
        idServicio = p(request, "idServicio");
        fecha = p(request, "fecha");
        hora = p(request, "hora");
        motivo = p(request, "motivo");
        observaciones = p(request, "observaciones");

        try (Connection cn = obtenerConexion()) {
            // El selector codifica TIPO|ID porque los tres tipos de paciente pueden compartir números.
            String[] partes = pacienteSeleccionado.split("\\|", -1);
            String tipoPaciente = partes[0];
            int idPaciente = Integer.parseInt(partes[1]);
            int servicio = Integer.parseInt(idServicio);
            java.sql.Date fechaSQL = java.sql.Date.valueOf(fecha);
            Time horaSQL = Time.valueOf(horaSql(hora));

            if (!unoDe(tipoPaciente, "ESTUDIANTE", "DOCENTE", "ADMINISTRATIVO")) {
                throw new IllegalArgumentException();
            }

            // Esta comprobación ofrece un mensaje claro; la restricción UNIQUE sigue siendo la garantía final.
            String sqlDuplicado = "SELECT 1 FROM cita WHERE id_psicologo = ? AND fecha = ? AND hora = ? LIMIT 1";
            try (PreparedStatement ps = cn.prepareStatement(sqlDuplicado)) {
                ps.setInt(1, idPsicologo.intValue());
                ps.setDate(2, fechaSQL);
                ps.setTime(3, horaSQL);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) error = "Ya existe una cita para ese psicólogo, fecha y hora.";
                }
            }

            if (error == null) {
                String sql = "INSERT INTO cita "
                           + "(fecha, hora, id_servicio, id_estudiante, id_docente, id_admin, "
                           + "id_psicologo, motivo, observaciones, estado) "
                           + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = cn.prepareStatement(sql)) {
                    ps.setDate(1, fechaSQL);
                    ps.setTime(2, horaSQL);
                    ps.setInt(3, servicio);

                    // La cita es polimórfica: se limpia todo y se asigna exactamente una FK de paciente.
                    ps.setNull(4, Types.INTEGER);
                    ps.setNull(5, Types.INTEGER);
                    ps.setNull(6, Types.INTEGER);
                    if ("ESTUDIANTE".equals(tipoPaciente)) ps.setInt(4, idPaciente);
                    if ("DOCENTE".equals(tipoPaciente)) ps.setInt(5, idPaciente);
                    if ("ADMINISTRATIVO".equals(tipoPaciente)) ps.setInt(6, idPaciente);

                    ps.setInt(7, idPsicologo.intValue());
                    ps.setString(8, motivo);
                    ps.setString(9, observaciones);
                    ps.setString(10, "PENDIENTE");
                    ps.executeUpdate();
                }

                // Vaciar el formulario evita reenvíos accidentales con los mismos datos visibles.
                exito = "Cita registrada correctamente.";
                pacienteSeleccionado = idServicio = fecha = hora = motivo = observaciones = "";
            }
        } catch (Exception ex) {
            getServletContext().log("Error al registrar cita.", ex);
            error = error == null ? "Complete los datos de la cita correctamente." : error;
        }
    }

    if (errorPerfil == null) {
        // Los catálogos se cargan después del POST para reutilizar la misma vista en éxito o error.
        try (Connection cn = obtenerConexion()) {
            String sqlPacientes = "SELECT tipo_paciente, id_paciente, nombre_completo, cedula "
                                + "FROM vw_lista_pacientes WHERE estado = 'ACTIVO' ORDER BY nombre_completo";
            try (PreparedStatement ps = cn.prepareStatement(sqlPacientes);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    pacientes.add(new String[] {
                        rs.getString("tipo_paciente"),
                        rs.getString("id_paciente"),
                        rs.getString("nombre_completo"),
                        rs.getString("cedula")
                    });
                }
            }

            cargarOpciones(cn,
                "SELECT id_servicio, nombre_servicio FROM servicio WHERE estado = 'ACTIVO' ORDER BY nombre_servicio",
                servicios, "id_servicio", "nombre_servicio");
        } catch (SQLException ex) {
            getServletContext().log("Error al cargar datos de cita.", ex);
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PSIREG | Registrar cita</title>
    <link rel="stylesheet" href="css/layout.css">
    <link rel="stylesheet" href="css/formularios.css">
    <link rel="stylesheet" href="css/tablas.css">
</head>
<body>
    <jsp:include page="includes/header.jsp" />
    <jsp:include page="includes/nav.jsp" />

    <main class="container">
        <section class="card form-card">
            <header>
                <h1>Registrar cita</h1>
                <p>Agende una atención para un paciente institucional.</p>
            </header>

            <% if (errorPerfil != null) { %>
                <p class="message-error"><%= e(errorPerfil) %></p>
            <% } else { %>
                <% if (error != null) { %><p class="message-error"><%= e(error) %></p><% } %>
                <% if (exito != null) { %><p class="message-success"><%= e(exito) %></p><% } %>

                <p class="message-warning">La cita se asignará a su perfil profesional vinculado.</p>

                <form method="post" action="registrarCita.jsp">
                    <div class="form-group">
                        <label for="pacienteSeleccionado">Paciente</label>
                        <select class="input-pill" id="pacienteSeleccionado" name="pacienteSeleccionado" required>
                            <option value="">Seleccione</option>
                            <% for (String[] paciente : pacientes) {
                                String valor = paciente[0] + "|" + paciente[1];
                            %>
                                <option value="<%= e(valor) %>" <%= selected(pacienteSeleccionado, valor) %>>
                                    <%= e(paciente[2]) %> — <%= e(paciente[0]) %> — <%= e(paciente[3]) %>
                                </option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="idServicio">Servicio</label>
                        <select class="input-pill" id="idServicio" name="idServicio" required>
                            <option value="">Seleccione</option>
                            <% for (String[] servicio : servicios) { %>
                                <option value="<%= e(servicio[0]) %>" <%= selected(idServicio, servicio[0]) %>><%= e(servicio[1]) %></option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="fecha">Fecha</label>
                        <input class="input-pill" id="fecha" name="fecha" type="date" value="<%= e(fecha) %>" required>
                    </div>

                    <div class="form-group">
                        <label for="hora">Hora</label>
                        <input class="input-pill" id="hora" name="hora" type="time" value="<%= e(hora) %>" required>
                    </div>

                    <div class="form-group">
                        <label for="motivo">Motivo</label>
                        <input class="input-pill" id="motivo" name="motivo" maxlength="255" value="<%= e(motivo) %>">
                    </div>

                    <div class="form-group">
                        <label for="observaciones">Observaciones</label>
                        <textarea id="observaciones" name="observaciones"><%= e(observaciones) %></textarea>
                    </div>

                    <button class="btn-primary" type="submit">Agendar cita</button>
                </form>
            <% } %>
        </section>
    </main>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>
