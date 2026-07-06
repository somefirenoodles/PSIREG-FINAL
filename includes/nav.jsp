<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- Navegación principal. Las opciones privadas son solo una ayuda visual; la sesión se valida en cada página privada. --%>
<%
    Object idUsuarioSesion = session.getAttribute("id_usuario");
    String rolSesion = (String) session.getAttribute("rol");
    String nombreSesion = (String) session.getAttribute("nombre");
    String apellidoSesion = (String) session.getAttribute("apellido");
    // El nombre se construye desde la sesión y se escapa justo antes de imprimirlo.
    String nombreVisible = "";
    if (nombreSesion != null) {
        nombreVisible = nombreSesion;
    }
    if (apellidoSesion != null) {
        nombreVisible = nombreVisible + " " + apellidoSesion;
    }
    nombreVisible = nombreVisible.trim();
    String nombreRol = "PSICÓLOGO";
    if ("ADMIN".equals(rolSesion)) {
        nombreRol = "ADMIN";
    }
    nombreVisible = nombreVisible.replace("&", "&amp;").replace("<", "&lt;")
            .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
%>
<nav class="primary-nav" aria-label="Navegación principal">
    <div class="primary-nav__inner">
        <ul class="nav-links">
            <li><a href="index.jsp">Inicio</a></li>
            <li><a href="sobreNosotros.jsp">Sobre Nosotros</a></li>
            <% if (idUsuarioSesion == null) { %>
                <li><a href="login.jsp">Login</a></li>
            <% } else if ("ADMIN".equals(rolSesion)) { %>
                <li><a href="registroUser.jsp?rol=ADMIN">Registrar administrador</a></li>
                <li><a href="registroUser.jsp?rol=PSICOLOGO">Registrar psicólogo</a></li>
                <li><a href="listaCitas.jsp">Lista de citas</a></li>
                <li><a href="citasPorPsicologo.jsp">Citas por psicólogo</a></li>
            <% } else if ("PSICOLOGO".equals(rolSesion)) { %>
                <li><a href="registrarPaciente.jsp">Registrar paciente</a></li>
                <li><a href="registrarCita.jsp">Registrar cita</a></li>
                <li><a href="listaExpedientes.jsp">Lista de expedientes</a></li>
                <li><a href="citasPorPsicologo.jsp">Citas por psicólogo</a></li>
            <% } %>
        </ul>

        <% if (idUsuarioSesion != null) { %>
            <div class="session-summary">
                <span><%= nombreVisible %></span>
                <span class="badge"><%= nombreRol %></span>
                <a class="btn-secondary" href="logout.jsp">Cerrar sesión</a>
            </div>
        <% } else { %>
            <a class="btn-primary" href="login.jsp">Iniciar sesión</a>
        <% } %>
    </div>
</nav>
