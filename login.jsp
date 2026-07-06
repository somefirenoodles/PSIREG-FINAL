<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="db/conexion.jsp" %>
<%@ include file="includes/utilidades.jsp" %>
<%@ include file="includes/seguridadPassword.jsp" %>
<%-- Autentica cuentas activas y crea una sesión mínima; el perfil profesional se consulta por separado. --%>
<%
    String mensajeError = null;
    String credencial = p(request, "credencial");

    if (session.getAttribute("id_usuario") != null && !"acceso".equals(request.getParameter("error"))) {
        response.sendRedirect("ADMIN".equals(session.getAttribute("rol")) ? "listaCitas.jsp" : "registrarPaciente.jsp");
        return;
    }

    if ("acceso".equals(request.getParameter("error"))) {
        mensajeError = "No tiene permiso para acceder a esa página.";
    }

    if (esPost(request)) {
        String password = request.getParameter("password");

        if (vacio(credencial) || vacio(password)) {
            mensajeError = "Ingrese su usuario o correo y contraseña.";
        } else {
            String sql = "SELECT id_usuario, nombre, apellido, usuario, rol, password_hash "
                       + "FROM usuarios "
                       + "WHERE (usuario = ? OR correo = ?) AND estado = 'ACTIVO' LIMIT 1";

            try (Connection cn = obtenerConexion();
                 PreparedStatement ps = cn.prepareStatement(sql)) {
                ps.setString(1, credencial);
                ps.setString(2, credencial);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && verificarPassword(password, rs.getString("password_hash"))) {
                        // Evita conservar datos de una sesión anónima o autenticada anteriormente.
                        session.invalidate();

                        javax.servlet.http.HttpSession nuevaSesion = request.getSession(true);
                        nuevaSesion.setAttribute("id_usuario", rs.getInt("id_usuario"));
                        nuevaSesion.setAttribute("nombre", rs.getString("nombre"));
                        nuevaSesion.setAttribute("apellido", rs.getString("apellido"));
                        nuevaSesion.setAttribute("usuario", rs.getString("usuario"));
                        nuevaSesion.setAttribute("rol", rs.getString("rol"));

                        response.sendRedirect("ADMIN".equals(rs.getString("rol")) ? "listaCitas.jsp" : "registrarPaciente.jsp");
                        return;
                    }

                    mensajeError = "Credenciales inválidas o usuario inactivo.";
                }
            } catch (SQLException ex) {
                getServletContext().log("Error en login.", ex);
                mensajeError = "No fue posible procesar el inicio de sesión.";
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar sesión | PSIREG</title>
    <link rel="stylesheet" href="css/layout.css">
    <link rel="stylesheet" href="css/formularios.css">
    <link rel="stylesheet" href="css/tablas.css">
</head>
<body>
    <jsp:include page="includes/header.jsp" />
    <jsp:include page="includes/nav.jsp" />

    <main class="container">
        <section class="card form-card" aria-labelledby="titulo-login">
            <header>
                <h1 id="titulo-login">Acceso a PSIREG</h1>
                <p>Registro Psicológico Institucional</p>
            </header>

            <% if (mensajeError != null) { %>
                <p class="message-error" role="alert"><%= e(mensajeError) %></p>
            <% } %>

            <form method="post" action="login.jsp" autocomplete="on">
                <div class="form-group">
                    <label for="credencial">Usuario o correo</label>
                    <input class="input-pill" id="credencial" name="credencial" type="text"
                           value="<%= e(credencial) %>" autocomplete="username" required>
                </div>
                <div class="form-group">
                    <label for="password">Contraseña</label>
                    <input class="input-pill" id="password" name="password" type="password"
                           autocomplete="current-password" required>
                </div>
                <button class="btn-primary" type="submit">Ingresar</button>
            </form>
        </section>
    </main>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>
