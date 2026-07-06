<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- Cierra la sesión actual y vuelve al login. --%>
<%
    session.invalidate();
    response.sendRedirect("login.jsp");
%>
