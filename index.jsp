<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PSIREG | Inicio</title>
    <link rel="stylesheet" href="css/layout.css">
    <link rel="stylesheet" href="css/formularios.css">
    <link rel="stylesheet" href="css/tablas.css">
</head>
<body>
    <jsp:include page="includes/header.jsp" />
    <jsp:include page="includes/nav.jsp" />

    <main class="container">
        <%-- Presentación pública del sistema. --%>
        <section class="hero-section" aria-labelledby="titulo-principal">
            <h1 id="titulo-principal">PSIREG — Registro Psicológico Institucional</h1>
            <p class="hero-section__lead">Gestión de pacientes, psicólogos, citas y expedientes en un entorno institucional organizado.</p>
            <a class="btn-primary" href="login.jsp">Iniciar sesión</a>
        </section>

        <section class="resources-section" aria-labelledby="titulo-recursos">
            <header class="section-heading">
                <h2 id="titulo-recursos">Recursos de bienestar</h2>
                <p>Lecturas y material audiovisual para promover una conversación informada sobre salud mental.</p>
            </header>

            <div class="resource-grid">
                <%-- HTML: Reemplazar este enlace por la fuente final validada por el equipo si fuera necesario. --%>
                <article class="card resource-card">
                    <p class="resource-type">Artículo</p>
                    <h3>Salud mental: fortalecer nuestra respuesta</h3>
                    <p>Panorama general de la salud mental y de la importancia de los servicios de apoyo accesibles.</p>
                    <a class="text-link" href="https://www.who.int/news-room/fact-sheets/detail/mental-health-strengthening-our-response" target="_blank" rel="noopener noreferrer">Consultar fuente</a>
                </article>

                <%-- HTML: Reemplazar este enlace por la fuente final validada por el equipo si fuera necesario. --%>
                <article class="card resource-card">
                    <p class="resource-type">Artículo</p>
                    <h3>La salud mental en el trabajo</h3>
                    <p>Información de referencia sobre entornos laborales saludables y el bienestar de las personas.</p>
                    <a class="text-link" href="https://www.who.int/news-room/fact-sheets/detail/mental-health-at-work" target="_blank" rel="noopener noreferrer">Consultar fuente</a>
                </article>

                <%-- HTML: Reemplazar este enlace por el video final validado por el equipo. --%>
                <article class="card resource-card">
                    <p class="resource-type">Video</p>
                    <h3>Material audiovisual sobre bienestar</h3>
                    <p>Acceso a una búsqueda de videos públicos sobre bienestar y salud mental para uso informativo.</p>
                    <a class="text-link" href="https://www.youtube.com/results?search_query=bienestar+y+salud+mental" target="_blank" rel="noopener noreferrer">Ver videos</a>
                </article>
            </div>
        </section>
    </main>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>
