<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- Invalidar la sesión completa elimina identidad y rol antes de volver al login. --%>
<%
    session.invalidate();
    response.sendRedirect("login.jsp");
%>
