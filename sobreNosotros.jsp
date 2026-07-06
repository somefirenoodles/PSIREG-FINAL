<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PSIREG | Sobre Nosotros</title>
    <link rel="stylesheet" href="css/layout.css">
    <link rel="stylesheet" href="css/formularios.css">
    <link rel="stylesheet" href="css/tablas.css">
</head>
<body>
    <jsp:include page="includes/header.jsp" />
    <jsp:include page="includes/nav.jsp" />

    <main class="container">
        <%-- Información editable del equipo responsable del proyecto. --%>
        <section class="about-section" aria-labelledby="titulo-nosotros">
            <header class="section-heading">
                <h1 id="titulo-nosotros">Sobre Nosotros</h1>
                <p>Equipo académico responsable del desarrollo de PSIREG.</p>
            </header>

            <!-- Cada tarjeta usa una fotografía individual reemplazable por el equipo. -->
            <div class="team-grid" aria-label="Integrantes del equipo">
                <article class="card member-card">
                    <img class="member-photo" src="img/integrante1.jpg" alt="Fotografía del integrante 1">
                    <h2>Gabriel González</h2>
                    <dl>
                        <dt>Cédula</dt><dd>8-1023-761</dd>
                        <dt>Carrera</dt><dd>Licenciatura en Ing. de Software</dd>
                        <dt>Experiencia</dt><dd>Experiencia en artes visuales y creative coding con (Touchdesigner, Photoshop y After Effects), he trabajado en proyectos de Análisis de Datos usando NumPy, Excel y Pandas para crear modelos de predicción o NLP en campos como sociología, entretenimiento y logística.</dd>
                    </dl>
                </article>

                <article class="card member-card">
                    <img class="member-photo" src="img/integrante2.jpeg" alt="Fotografía del integrante 2">
                    <h2>Jenifer Albornoz</h2>
                    <dl>
                        <dt>Cédula</dt><dd>E-8-220963</dd>
                        <dt>Carrera</dt><dd>Licenciatura en Ing. de Software</dd>
                        <dt>Experiencia</dt><dd>Experiencia en desarrollo de software y diseño web, con conocimientos en Java, JSP, HTML, CSS y bases de datos SQL.</dd>
                    </dl>
                </article>
            </div>
        </section>
    </main>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>
