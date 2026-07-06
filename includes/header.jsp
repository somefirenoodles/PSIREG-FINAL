<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- Banner institucional compartido; se inserta dentro del body de cada página. --%>
<header class="site-header">
    <div class="site-header__inner">
        <a class="brand" href="index.jsp" aria-label="PSIREG, ir al inicio">
            <img class="brand__logo" src="img/logo-psireg.svg" alt="Logo de PSIREG">
            <span class="brand__copy">
                <strong>PSIREG</strong>
                <span>Registro Psicológico Institucional</span>
            </span>
        </a>

        <%-- Enlaces de búsqueda y redes sociales del banner superior. --%>
        <div class="header-utilities" aria-label="Enlaces institucionales">
            <a class="icon-link" href="https://www.google.com" target="_blank" rel="noopener noreferrer" aria-label="Buscar en Google">
                <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="6"></circle><path d="m16 16 4 4"></path></svg>
            </a>
            <a class="social-link" href="https://www.facebook.com" target="_blank" rel="noopener noreferrer" aria-label="Facebook">f</a>
            <a class="social-link" href="https://www.linkedin.com" target="_blank" rel="noopener noreferrer" aria-label="LinkedIn">in</a>
        </div>
    </div>
</header>
