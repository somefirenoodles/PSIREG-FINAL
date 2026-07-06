<%--
    Include para páginas privadas.
    Uso:
        request.setAttribute("rolPermitido", "ADMIN");
        request.setAttribute("rolPermitido", "ADMIN,PSICOLOGO");
--%>
<%
    String rolPermitido = (String) request.getAttribute("rolPermitido");
    String rolSesion = (String) session.getAttribute("rol");

    if (session.getAttribute("id_usuario") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    if (!vacio(rolPermitido)) {
        boolean autorizado = false;
        for (String rol : rolPermitido.split(",")) {
            if (rol.trim().equals(rolSesion)) {
                autorizado = true;
                break;
            }
        }

        if (!autorizado) {
            response.sendRedirect("login.jsp?error=acceso");
            return;
        }
    }
%>
