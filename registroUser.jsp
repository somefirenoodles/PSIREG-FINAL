<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*,java.security.*" %>
<%@ include file="db/conexion.jsp" %>
<%@ include file="includes/utilidades.jsp" %>
<%@ include file="includes/seguridadPassword.jsp" %>
<%-- Registra credenciales de acceso; un psicólogo requiere además su perfil profesional. --%>
<%
    request.setAttribute("rolPermitido", "ADMIN");
%>
<%@ include file="includes/validarSesion.jsp" %>
<%
    String exito = null, error = null;
    String nombre = "", apellido = "", usuario = "", correo = "";
    String rol = "PSICOLOGO", estado = "ACTIVO";

    if (esPost(request)) {
        // Se conserva el texto del formulario, excepto las contraseñas, para corregir errores sin reescribir todo.
        nombre = p(request, "nombre");
        apellido = p(request, "apellido");
        usuario = p(request, "usuario");
        correo = p(request, "correo");
        rol = p(request, "rol");
        estado = p(request, "estado");
        String password = request.getParameter("password");
        String confirmar = request.getParameter("confirmarPassword");

        // El rol se valida contra una lista cerrada; no se confía en el valor del select.
        if (vacio(nombre) || vacio(apellido) || vacio(usuario) || vacio(correo) || vacio(password)) {
            error = "Complete todos los campos obligatorios.";
        } else if (!correoValido(correo)) {
            error = "Ingrese un correo electrónico válido.";
        } else if (password.length() < 8 || !password.equals(confirmar)) {
            error = "La contraseña no cumple los requisitos o no coincide.";
        } else if (!unoDe(rol, "ADMIN", "PSICOLOGO") || !unoDe(estado, "ACTIVO", "INACTIVO")) {
            error = "Rol o estado no válido.";
        } else {
            // La consulta anticipa las restricciones UNIQUE para devolver un mensaje entendible.
            String sqlExiste = "SELECT 1 FROM usuarios WHERE usuario = ? OR correo = ? LIMIT 1";
            String sqlInsertar = "INSERT INTO usuarios "
                               + "(nombre, apellido, usuario, correo, password_hash, rol, estado) "
                               + "VALUES (?, ?, ?, ?, ?, ?, ?)";

            try (Connection cn = obtenerConexion();
                 PreparedStatement existe = cn.prepareStatement(sqlExiste)) {
                existe.setString(1, usuario);
                existe.setString(2, correo);

                try (ResultSet rs = existe.executeQuery()) {
                    if (rs.next()) {
                        error = "El usuario o correo ya se encuentra registrado.";
                    }
                }

                if (error == null) {
                    try (PreparedStatement ps = cn.prepareStatement(sqlInsertar)) {
                        ps.setString(1, nombre);
                        ps.setString(2, apellido);
                        ps.setString(3, usuario);
                        ps.setString(4, correo);
                        // Solo el hash PBKDF2 llega a la base; confirmarPassword nunca se persiste.
                        ps.setString(5, generarHashPassword(password));
                        ps.setString(6, rol);
                        ps.setString(7, estado);
                        ps.executeUpdate();

                        // El perfil profesional, si aplica, se crea desde registrarPsicologo.jsp.
                        exito = "Usuario registrado correctamente.";
                        nombre = apellido = usuario = correo = "";
                        rol = "PSICOLOGO";
                        estado = "ACTIVO";
                    }
                }
            } catch (Exception ex) {
                getServletContext().log("Error al registrar usuario.", ex);
                error = "No fue posible registrar el usuario.";
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registrar usuario | PSIREG</title>
    <link rel="stylesheet" href="css/layout.css">
    <link rel="stylesheet" href="css/formularios.css">
    <link rel="stylesheet" href="css/tablas.css">
</head>
<body>
    <jsp:include page="includes/header.jsp" />
    <jsp:include page="includes/nav.jsp" />

    <main class="container">
        <section class="card form-card" aria-labelledby="titulo-registro">
            <header>
                <h1 id="titulo-registro">Registrar usuario del sistema</h1>
                <p>La creación de perfiles profesionales se realiza posteriormente.</p>
            </header>

            <% if (exito != null) { %><p class="message-success" role="status"><%= e(exito) %></p><% } %>
            <% if (error != null) { %><p class="message-error" role="alert"><%= e(error) %></p><% } %>

            <form method="post" action="registroUser.jsp" autocomplete="off">
                <div class="form-group">
                    <label for="nombre">Nombre</label>
                    <input class="input-pill" id="nombre" name="nombre" type="text" maxlength="80" value="<%= e(nombre) %>" required>
                </div>
                <div class="form-group">
                    <label for="apellido">Apellido</label>
                    <input class="input-pill" id="apellido" name="apellido" type="text" maxlength="80" value="<%= e(apellido) %>" required>
                </div>
                <div class="form-group">
                    <label for="usuario">Usuario</label>
                    <input class="input-pill" id="usuario" name="usuario" type="text" maxlength="50" value="<%= e(usuario) %>" required>
                </div>
                <div class="form-group">
                    <label for="correo">Correo institucional</label>
                    <input class="input-pill" id="correo" name="correo" type="email" maxlength="120" value="<%= e(correo) %>" required>
                </div>
                <div class="form-group">
                    <label for="password">Contraseña</label>
                    <input class="input-pill" id="password" name="password" type="password" minlength="8" autocomplete="new-password" required>
                </div>
                <div class="form-group">
                    <label for="confirmarPassword">Confirmar contraseña</label>
                    <input class="input-pill" id="confirmarPassword" name="confirmarPassword" type="password" minlength="8" autocomplete="new-password" required>
                </div>
                <div class="form-group">
                    <label for="rol">Rol</label>
                    <select class="input-pill" id="rol" name="rol" required>
                        <option value="ADMIN" <%= selected(rol, "ADMIN") %>>ADMIN</option>
                        <option value="PSICOLOGO" <%= selected(rol, "PSICOLOGO") %>>PSICOLOGO</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="estado">Estado</label>
                    <select class="input-pill" id="estado" name="estado" required>
                        <option value="ACTIVO" <%= selected(estado, "ACTIVO") %>>ACTIVO</option>
                        <option value="INACTIVO" <%= selected(estado, "INACTIVO") %>>INACTIVO</option>
                    </select>
                </div>
                <button class="btn-primary" type="submit">Registrar usuario</button>
                <a class="btn-secondary" href="listaCitas.jsp">Cancelar</a>
            </form>
        </section>
    </main>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>
