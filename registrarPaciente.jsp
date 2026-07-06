<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="db/conexion.jsp" %>
<%@ include file="includes/utilidades.jsp" %>
<%!
    private static void insertarTelefono(Connection cn, String tabla, String fk, String tablaTipo,
            int idPersona, String tipo, String telefono) throws SQLException {
        if (telefono == null || telefono.trim().isEmpty()) return;

        String sql = "INSERT INTO " + tabla + " (" + fk + ", id_tipo, telefono) "
                   + "SELECT ?, id_tipo, ? FROM " + tablaTipo + " WHERE nombre_tipo = ?";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, idPersona);
            ps.setString(2, telefono.trim());
            ps.setString(3, tipo);
            ps.executeUpdate();
        }
    }
%>
<%
    request.setAttribute("rolPermitido", "PSICOLOGO");
%>
<%@ include file="includes/validarSesion.jsp" %>
<%
    String error = null, exito = null;
    String tipo = "ESTUDIANTE", nombre = "", segundoNombre = "", apellidoPaterno = "", apellidoMaterno = "";
    String cedula = "", genero = "OTRO", correo = "", telefonoPersonal = "", telefonoResidencial = "";
    String casa = "", calle = "", corregimiento = "", estado = "ACTIVO", departamento = "";
    String idCarrera = "", idFacultad = "";
    List<String[]> carreras = new ArrayList<String[]>();
    List<String[]> facultades = new ArrayList<String[]>();

    if (esPost(request)) {
        tipo = p(request, "tipo");
        nombre = p(request, "nombre");
        segundoNombre = p(request, "segundoNombre");
        apellidoPaterno = p(request, "apellidoPaterno");
        apellidoMaterno = p(request, "apellidoMaterno");
        cedula = p(request, "cedula");
        genero = p(request, "genero");
        correo = p(request, "correo");
        telefonoPersonal = p(request, "telefonoPersonal");
        telefonoResidencial = p(request, "telefonoResidencial");
        casa = p(request, "casa");
        calle = p(request, "calle");
        corregimiento = p(request, "corregimiento");
        estado = p(request, "estado");
        departamento = p(request, "departamento");
        idCarrera = p(request, "idCarrera");
        idFacultad = p(request, "idFacultad");

        if (!unoDe(tipo, "ESTUDIANTE", "DOCENTE", "ADMINISTRATIVO")) {
            error = "El tipo de paciente seleccionado no es válido.";
        } else if (vacio(nombre) || vacio(apellidoPaterno) || vacio(apellidoMaterno)
                || vacio(cedula) || vacio(correo) || vacio(calle) || vacio(corregimiento)
                || vacio(telefonoPersonal)) {
            error = "Complete los campos obligatorios.";
        } else if (!correoValido(correo)) {
            error = "Ingrese un correo electrónico válido.";
        } else if (!unoDe(genero, "M", "F", "OTRO") || !unoDe(estado, "ACTIVO", "INACTIVO")) {
            error = "Género o estado no válido.";
        } else if ("ESTUDIANTE".equals(tipo) && vacio(idCarrera)) {
            error = "Debe seleccionar una carrera.";
        } else if ("DOCENTE".equals(tipo) && vacio(idFacultad)) {
            error = "Debe seleccionar una facultad.";
        } else if ("ADMINISTRATIVO".equals(tipo) && (vacio(casa) || vacio(departamento))) {
            error = "Para administrativos debe indicar casa y departamento.";
        }

        if (error == null) {
            try (Connection cn = obtenerConexion()) {
                String sqlDuplicado = "SELECT 1 FROM vw_lista_pacientes "
                                    + "WHERE cedula = ? OR correo_institucional = ? LIMIT 1";
                try (PreparedStatement ps = cn.prepareStatement(sqlDuplicado)) {
                    ps.setString(1, cedula);
                    ps.setString(2, correo);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) error = "La cédula o el correo institucional ya se encuentran registrados.";
                    }
                }

                if (error == null) {
                    cn.setAutoCommit(false);
                    try {
                        int idGenerado;

                        if ("ESTUDIANTE".equals(tipo)) {
                            String sql = "INSERT INTO estudiante "
                                       + "(primer_nombre, segundo_nombre, apellido_paterno, apellido_materno, cedula, genero, "
                                       + "correo_institucional, casa, calle, corregimiento, id_carrera, estado) "
                                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                            try (PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                                ps.setString(1, nombre);
                                setTextoOpcional(ps, 2, segundoNombre);
                                ps.setString(3, apellidoPaterno);
                                ps.setString(4, apellidoMaterno);
                                ps.setString(5, cedula);
                                ps.setString(6, genero);
                                ps.setString(7, correo);
                                setTextoOpcional(ps, 8, casa);
                                ps.setString(9, calle);
                                ps.setString(10, corregimiento);
                                ps.setInt(11, Integer.parseInt(idCarrera));
                                ps.setString(12, estado);
                                ps.executeUpdate();
                                try (ResultSet rs = ps.getGeneratedKeys()) {
                                    rs.next();
                                    idGenerado = rs.getInt(1);
                                }
                            }
                            insertarTelefono(cn, "tlf_estudiante", "id_estudiante", "tipo_tlf_estudiante", idGenerado, "Personal", telefonoPersonal);
                            insertarTelefono(cn, "tlf_estudiante", "id_estudiante", "tipo_tlf_estudiante", idGenerado, "Residencial", telefonoResidencial);
                        } else if ("DOCENTE".equals(tipo)) {
                            String sql = "INSERT INTO docente "
                                       + "(primer_nombre, segundo_nombre, apellido_paterno, apellido_materno, cedula, genero, "
                                       + "correo_institucional, telefono_personal, casa, calle, corregimiento, id_facultad, estado) "
                                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                            try (PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                                ps.setString(1, nombre);
                                setTextoOpcional(ps, 2, segundoNombre);
                                ps.setString(3, apellidoPaterno);
                                ps.setString(4, apellidoMaterno);
                                ps.setString(5, cedula);
                                ps.setString(6, genero);
                                ps.setString(7, correo);
                                ps.setString(8, telefonoPersonal);
                                setTextoOpcional(ps, 9, casa);
                                ps.setString(10, calle);
                                ps.setString(11, corregimiento);
                                ps.setInt(12, Integer.parseInt(idFacultad));
                                ps.setString(13, estado);
                                ps.executeUpdate();
                                try (ResultSet rs = ps.getGeneratedKeys()) {
                                    rs.next();
                                    idGenerado = rs.getInt(1);
                                }
                            }
                            insertarTelefono(cn, "tlf_docente", "id_docente", "tipo_tlf_docente", idGenerado, "Personal", telefonoPersonal);
                            insertarTelefono(cn, "tlf_docente", "id_docente", "tipo_tlf_docente", idGenerado, "Residencial", telefonoResidencial);
                        } else {
                            String sql = "INSERT INTO administrativo "
                                       + "(primer_nombre, segundo_nombre, apellido_paterno, apellido_materno, cedula, genero, "
                                       + "correo_institucional, telefono_personal, casa, calle, corregimiento, departamento, estado) "
                                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                            try (PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                                ps.setString(1, nombre);
                                setTextoOpcional(ps, 2, segundoNombre);
                                ps.setString(3, apellidoPaterno);
                                ps.setString(4, apellidoMaterno);
                                ps.setString(5, cedula);
                                ps.setString(6, genero);
                                ps.setString(7, correo);
                                ps.setString(8, telefonoPersonal);
                                ps.setString(9, casa);
                                ps.setString(10, calle);
                                ps.setString(11, corregimiento);
                                ps.setString(12, departamento);
                                ps.setString(13, estado);
                                ps.executeUpdate();
                                try (ResultSet rs = ps.getGeneratedKeys()) {
                                    rs.next();
                                    idGenerado = rs.getInt(1);
                                }
                            }
                            insertarTelefono(cn, "tlf_admin", "id_admin", "tipo_tlf_admin", idGenerado, "Personal", telefonoPersonal);
                            insertarTelefono(cn, "tlf_admin", "id_admin", "tipo_tlf_admin", idGenerado, "Residencial", telefonoResidencial);
                        }

                        cn.commit();
                        exito = "Paciente institucional registrado correctamente.";
                        tipo = "ESTUDIANTE";
                        nombre = segundoNombre = apellidoPaterno = apellidoMaterno = cedula = "";
                        genero = "OTRO";
                        correo = telefonoPersonal = telefonoResidencial = casa = calle = corregimiento = "";
                        estado = "ACTIVO";
                        departamento = idCarrera = idFacultad = "";
                    } catch (Exception ex) {
                        cn.rollback();
                        getServletContext().log("Error al insertar paciente.", ex);
                        error = "No fue posible registrar el paciente.";
                    } finally {
                        cn.setAutoCommit(true);
                    }
                }
            } catch (SQLException ex) {
                getServletContext().log("Error al registrar paciente.", ex);
                error = "No fue posible registrar el paciente.";
            }
        }
    }

    try (Connection cn = obtenerConexion()) {
        cargarOpciones(cn, "SELECT id_carrera, nombre_carrera FROM carrera ORDER BY nombre_carrera",
            carreras, "id_carrera", "nombre_carrera");
        cargarOpciones(cn, "SELECT id_facultad, nombre_facultad FROM facultad ORDER BY nombre_facultad",
            facultades, "id_facultad", "nombre_facultad");
    } catch (SQLException ex) {
        getServletContext().log("Error al cargar catálogos de pacientes.", ex);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PSIREG | Registrar paciente</title>
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
                <h1>Registrar paciente</h1>
                <p>Registro institucional por tipo de paciente.</p>
            </header>

            <% if (error != null) { %><p class="message-error"><%= e(error) %></p><% } %>
            <% if (exito != null) { %><p class="message-success"><%= e(exito) %></p><% } %>

            <form method="post" action="registrarPaciente.jsp">
                <div class="form-group">
                    <label for="tipo">Tipo</label>
                    <select class="input-pill" id="tipo" name="tipo" required>
                        <option value="ESTUDIANTE" <%= selected(tipo, "ESTUDIANTE") %>>Estudiante</option>
                        <option value="DOCENTE" <%= selected(tipo, "DOCENTE") %>>Docente</option>
                        <option value="ADMINISTRATIVO" <%= selected(tipo, "ADMINISTRATIVO") %>>Administrativo</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="nombre">Nombre</label>
                    <input class="input-pill" id="nombre" name="nombre" value="<%= e(nombre) %>" required>
                </div>

                <div class="form-group">
                    <label for="segundoNombre">Segundo nombre</label>
                    <input class="input-pill" id="segundoNombre" name="segundoNombre" value="<%= e(segundoNombre) %>">
                </div>

                <div class="form-group">
                    <label>Apellidos</label>
                    <input class="input-pill" name="apellidoPaterno" placeholder="Apellido paterno" value="<%= e(apellidoPaterno) %>" required>
                    <input class="input-pill" name="apellidoMaterno" placeholder="Apellido materno" value="<%= e(apellidoMaterno) %>" required>
                </div>

                <div class="form-group">
                    <label for="cedula">Cédula</label>
                    <input class="input-pill" id="cedula" name="cedula" value="<%= e(cedula) %>" required>
                </div>

                <div class="form-group">
                    <label for="genero">Género</label>
                    <select class="input-pill" id="genero" name="genero" required>
                        <option value="M" <%= selected(genero, "M") %>>M</option>
                        <option value="F" <%= selected(genero, "F") %>>F</option>
                        <option value="OTRO" <%= selected(genero, "OTRO") %>>OTRO</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="correo">Correo institucional</label>
                    <input class="input-pill" id="correo" type="email" name="correo" value="<%= e(correo) %>" required>
                </div>

                <div class="form-group">
                    <label for="telefonoPersonal">Teléfono personal</label>
                    <input class="input-pill" id="telefonoPersonal" name="telefonoPersonal" value="<%= e(telefonoPersonal) %>" required>
                </div>

                <div class="form-group">
                    <label for="telefonoResidencial">Teléfono residencial</label>
                    <input class="input-pill" id="telefonoResidencial" name="telefonoResidencial" value="<%= e(telefonoResidencial) %>">
                </div>

                <div class="form-group">
                    <label>Dirección</label>
                    <input class="input-pill" name="casa" placeholder="Casa" value="<%= e(casa) %>">
                    <input class="input-pill" name="calle" placeholder="Calle" value="<%= e(calle) %>" required>
                    <input class="input-pill" name="corregimiento" placeholder="Corregimiento" value="<%= e(corregimiento) %>" required>
                </div>

                <div class="form-group">
                    <label for="idCarrera">Carrera (estudiante)</label>
                    <select class="input-pill" id="idCarrera" name="idCarrera">
                        <option value="">Seleccione</option>
                        <% for (String[] carrera : carreras) { %>
                            <option value="<%= e(carrera[0]) %>" <%= selected(idCarrera, carrera[0]) %>><%= e(carrera[1]) %></option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="idFacultad">Facultad (docente)</label>
                    <select class="input-pill" id="idFacultad" name="idFacultad">
                        <option value="">Seleccione</option>
                        <% for (String[] facultad : facultades) { %>
                            <option value="<%= e(facultad[0]) %>" <%= selected(idFacultad, facultad[0]) %>><%= e(facultad[1]) %></option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="departamento">Departamento (administrativo)</label>
                    <input class="input-pill" id="departamento" name="departamento" value="<%= e(departamento) %>">
                </div>

                <div class="form-group">
                    <label for="estado">Estado</label>
                    <select class="input-pill" id="estado" name="estado" required>
                        <option value="ACTIVO" <%= selected(estado, "ACTIVO") %>>ACTIVO</option>
                        <option value="INACTIVO" <%= selected(estado, "INACTIVO") %>>INACTIVO</option>
                    </select>
                </div>

                <button class="btn-primary" type="submit">Registrar paciente</button>
            </form>
        </section>
    </main>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>
