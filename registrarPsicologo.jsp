<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*,java.util.*" %>
<%@ include file="db/conexion.jsp" %>
<%@ include file="includes/utilidades.jsp" %>
<%-- Crea el perfil institucional y lo vincula con una cuenta de rol PSICOLOGO. --%>
<%
    request.setAttribute("rolPermitido", "ADMIN");
%>
<%@ include file="includes/validarSesion.jsp" %>
<%
    String error = null, exito = null;
    String idUsuario = "", primerNombre = "", segundoNombre = "", apellidoPaterno = "", apellidoMaterno = "";
    String cedula = "", genero = "OTRO", correo = "", telefono = "", casa = "", calle = "", corregimiento = "";
    String idCargo = "", estado = "ACTIVO";
    List<String[]> usuarios = new ArrayList<String[]>();
    List<String[]> cargos = new ArrayList<String[]>();

    if (esPost(request)) {
        // La cuenta y el perfil son entidades distintas: aquí se validan antes de enlazarlas.
        idUsuario = p(request, "idUsuario");
        primerNombre = p(request, "primerNombre");
        segundoNombre = p(request, "segundoNombre");
        apellidoPaterno = p(request, "apellidoPaterno");
        apellidoMaterno = p(request, "apellidoMaterno");
        cedula = p(request, "cedula");
        genero = p(request, "genero");
        correo = p(request, "correo");
        telefono = p(request, "telefono");
        casa = p(request, "casa");
        calle = p(request, "calle");
        corregimiento = p(request, "corregimiento");
        idCargo = p(request, "idCargo");
        estado = p(request, "estado");

        // Primero se validan reglas baratas para no abrir conexiones ante entradas incompletas.
        if (vacio(primerNombre) || vacio(apellidoPaterno) || vacio(apellidoMaterno)
                || vacio(cedula) || vacio(correo) || vacio(telefono)
                || vacio(calle) || vacio(corregimiento) || vacio(idCargo)) {
            error = "Complete los datos requeridos.";
        } else if (!correoValido(correo)) {
            error = "Ingrese un correo electrónico válido.";
        } else if (!unoDe(genero, "M", "F", "OTRO") || !unoDe(estado, "ACTIVO", "INACTIVO")) {
            error = "Género o estado no válido.";
        } else {
            try (Connection cn = obtenerConexion()) {
                Integer usuarioAsociado = vacio(idUsuario) ? null : Integer.valueOf(idUsuario);
                int cargo = Integer.parseInt(idCargo);

                // Cédula y correo representan identidad profesional y deben ser únicos.
                String sqlDuplicado = "SELECT 1 FROM psicologo WHERE cedula = ? OR correo_institucional = ? LIMIT 1";
                try (PreparedStatement ps = cn.prepareStatement(sqlDuplicado)) {
                    ps.setString(1, cedula);
                    ps.setString(2, correo);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) error = "La cédula o el correo institucional ya están registrados.";
                    }
                }

                if (error == null && usuarioAsociado != null) {
                    // Solo se enlazan cuentas activas de psicólogo que aún no tengan perfil.
                    String sqlUsuario = "SELECT 1 FROM usuarios u "
                                      + "LEFT JOIN psicologo p ON p.id_usuario = u.id_usuario "
                                      + "WHERE u.id_usuario = ? AND u.rol = 'PSICOLOGO' "
                                      + "AND u.estado = 'ACTIVO' AND p.id_psicologo IS NULL";
                    try (PreparedStatement ps = cn.prepareStatement(sqlUsuario)) {
                        ps.setInt(1, usuarioAsociado.intValue());
                        try (ResultSet rs = ps.executeQuery()) {
                            if (!rs.next()) error = "El usuario asociado no está disponible para vincularse.";
                        }
                    }
                }

                if (error == null) {
                    String sql = "INSERT INTO psicologo "
                               + "(id_usuario, primer_nombre, segundo_nombre, apellido_paterno, apellido_materno, "
                               + "cedula, genero, correo_institucional, telefono, casa, calle, corregimiento, id_cargo, estado) "
                               + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = cn.prepareStatement(sql)) {
                        // Atención: el formulario admite vacío, pero el esquema actual declara id_usuario NOT NULL.
                        if (usuarioAsociado == null) ps.setNull(1, Types.INTEGER);
                        else ps.setInt(1, usuarioAsociado.intValue());
                        ps.setString(2, primerNombre);
                        setTextoOpcional(ps, 3, segundoNombre);
                        ps.setString(4, apellidoPaterno);
                        ps.setString(5, apellidoMaterno);
                        ps.setString(6, cedula);
                        ps.setString(7, genero);
                        ps.setString(8, correo);
                        ps.setString(9, telefono);
                        setTextoOpcional(ps, 10, casa);
                        ps.setString(11, calle);
                        ps.setString(12, corregimiento);
                        ps.setInt(13, cargo);
                        ps.setString(14, estado);
                        ps.executeUpdate();
                    }

                    // Restablecer valores evita que un segundo alta herede datos del perfil anterior.
                    exito = "Psicólogo registrado correctamente.";
                    idUsuario = primerNombre = segundoNombre = apellidoPaterno = apellidoMaterno = "";
                    cedula = correo = telefono = casa = calle = corregimiento = idCargo = "";
                    genero = "OTRO";
                    estado = "ACTIVO";
                }
            } catch (Exception ex) {
                getServletContext().log("Error al registrar psicólogo.", ex);
                error = "No fue posible registrar el psicólogo.";
            }
        }
    }

    try (Connection cn = obtenerConexion()) {
        // El LEFT JOIN excluye cuentas ya vinculadas y previene asociaciones dobles desde la interfaz.
        cargarOpciones(cn,
            "SELECT u.id_usuario, CONCAT(u.nombre, ' ', u.apellido, ' (', u.usuario, ')') AS nombre_usuario "
          + "FROM usuarios u LEFT JOIN psicologo p ON p.id_usuario = u.id_usuario "
          + "WHERE u.rol = 'PSICOLOGO' AND u.estado = 'ACTIVO' AND p.id_psicologo IS NULL "
          + "ORDER BY u.nombre, u.apellido",
            usuarios, "id_usuario", "nombre_usuario");

        cargarOpciones(cn, "SELECT id_cargo, nombre_cargo FROM cargo ORDER BY nombre_cargo",
            cargos, "id_cargo", "nombre_cargo");
    } catch (SQLException ex) {
        getServletContext().log("Error al cargar catálogos de psicólogo.", ex);
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PSIREG | Registrar psicólogo</title>
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
                <h1>Registrar psicólogo</h1>
                <p>Creación de perfiles profesionales institucionales.</p>
            </header>

            <% if (error != null) { %><p class="message-error"><%= e(error) %></p><% } %>
            <% if (exito != null) { %><p class="message-success"><%= e(exito) %></p><% } %>

            <form method="post" action="registrarPsicologo.jsp">
                <div class="form-group">
                    <label for="idUsuario">Usuario asociado (opcional)</label>
                    <select class="input-pill" id="idUsuario" name="idUsuario">
                        <option value="" <%= selected(idUsuario, "") %>>Sin usuario asociado</option>
                        <% for (String[] usuario : usuarios) { %>
                            <option value="<%= e(usuario[0]) %>" <%= selected(idUsuario, usuario[0]) %>><%= e(usuario[1]) %></option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label>Nombres</label>
                    <input class="input-pill" name="primerNombre" placeholder="Primer nombre" value="<%= e(primerNombre) %>" required>
                    <input class="input-pill" name="segundoNombre" placeholder="Segundo nombre" value="<%= e(segundoNombre) %>">
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
                    <input class="input-pill" id="correo" name="correo" type="email" value="<%= e(correo) %>" required>
                </div>

                <div class="form-group">
                    <label for="telefono">Teléfono</label>
                    <input class="input-pill" id="telefono" name="telefono" value="<%= e(telefono) %>" required>
                </div>

                <div class="form-group">
                    <label>Dirección</label>
                    <input class="input-pill" name="casa" placeholder="Casa" value="<%= e(casa) %>">
                    <input class="input-pill" name="calle" placeholder="Calle" value="<%= e(calle) %>" required>
                    <input class="input-pill" name="corregimiento" placeholder="Corregimiento" value="<%= e(corregimiento) %>" required>
                </div>

                <div class="form-group">
                    <label for="idCargo">Cargo</label>
                    <select class="input-pill" id="idCargo" name="idCargo" required>
                        <option value="">Seleccione</option>
                        <% for (String[] cargo : cargos) { %>
                            <option value="<%= e(cargo[0]) %>" <%= selected(idCargo, cargo[0]) %>><%= e(cargo[1]) %></option>
                        <% } %>
                    </select>
                </div>

                <div class="form-group">
                    <label for="estado">Estado</label>
                    <select class="input-pill" id="estado" name="estado" required>
                        <option value="ACTIVO" <%= selected(estado, "ACTIVO") %>>ACTIVO</option>
                        <option value="INACTIVO" <%= selected(estado, "INACTIVO") %>>INACTIVO</option>
                    </select>
                </div>

                <button class="btn-primary" type="submit">Registrar psicólogo</button>
            </form>
        </section>
    </main>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>
