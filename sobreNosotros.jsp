<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%-- Página pública y editorial; sus datos no provienen de la base de datos. --%>
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
                    <h2>Integrante 1</h2>
                    <dl>
                        <dt>Cédula</dt><dd>Completar cédula</dd>
                        <dt>Carrera</dt><dd>Completar carrera</dd>
                        <dt>Experiencia</dt><dd>Completar el resumen de experiencia como desarrollador.</dd>
                    </dl>
                </article>

                <article class="card member-card">
                    <img class="member-photo" src="img/integrante2.jpg" alt="Fotografía del integrante 2">
                    <h2>Integrante 2</h2>
                    <dl>
                        <dt>Cédula</dt><dd>Completar cédula</dd>
                        <dt>Carrera</dt><dd>Completar carrera</dd>
                        <dt>Experiencia</dt><dd>Completar el resumen de experiencia como desarrollador.</dd>
                    </dl>
                </article>

                <article class="card member-card">
                    <img class="member-photo" src="img/integrante3.jpg" alt="Fotografía del integrante 3">
                    <h2>Integrante 3</h2>
                    <dl>
                        <dt>Cédula</dt><dd>Completar cédula</dd>
                        <dt>Carrera</dt><dd>Completar carrera</dd>
                        <dt>Experiencia</dt><dd>Completar el resumen de experiencia como desarrollador.</dd>
                    </dl>
                </article>

                <article class="card member-card">
                    <img class="member-photo" src="img/integrante4.jpg" alt="Fotografía del integrante 4">
                    <h2>Integrante 4</h2>
                    <dl>
                        <dt>Cédula</dt><dd>Completar cédula</dd>
                        <dt>Carrera</dt><dd>Completar carrera</dd>
                        <dt>Experiencia</dt><dd>Completar el resumen de experiencia como desarrollador.</dd>
                    </dl>
                </article>

                <article class="card member-card">
                    <img class="member-photo" src="img/integrante5.jpg" alt="Fotografía del integrante 5">
                    <h2>Integrante 5</h2>
                    <dl>
                        <dt>Cédula</dt><dd>Completar cédula</dd>
                        <dt>Carrera</dt><dd>Completar carrera</dd>
                        <dt>Experiencia</dt><dd>Completar el resumen de experiencia como desarrollador.</dd>
                    </dl>
                </article>

                <article class="card member-card">
                    <img class="member-photo" src="img/integrante6.jpg" alt="Fotografía del integrante 6">
                    <h2>Integrante 6</h2>
                    <dl>
                        <dt>Cédula</dt><dd>Completar cédula</dd>
                        <dt>Carrera</dt><dd>Completar carrera</dd>
                        <dt>Experiencia</dt><dd>Completar el resumen de experiencia como desarrollador.</dd>
                    </dl>
                </article>
            </div>
        </section>
    </main>

    <jsp:include page="includes/footer.jsp" />
</body>
</html>
