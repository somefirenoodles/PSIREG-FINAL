# PSIREG JSP simplificado

Este paquete contiene reemplazos para los JSP principales de `PSIREG ACTIVE`.

Objetivo aplicado:
- Mantener el HTML, clases CSS y flujo funcional.
- Reducir Java repetido dentro de cada JSP.
- Centralizar helpers en `includes/utilidades.jsp`.
- Mantener login, roles, conexión JDBC, PBKDF2, formularios y consultas principales.
- Sacrificar validaciones redundantes y mensajes técnicos internos para mejorar legibilidad.

Uso:
1. Haz backup del proyecto.
2. Copia la carpeta `PSIREG ACTIVE` de este paquete encima de la carpeta `PSIREG ACTIVE` del repositorio.
3. Revisa `db/conexion.jsp` y ajusta `DB_PASSWORD`.
4. Ejecuta en Tomcat/GlassFish y prueba:
   - login ADMIN
   - registro de usuario
   - registro de psicólogo
   - login PSICOLOGO
   - registro de paciente
   - registro de cita
   - lista de citas
   - expedientes

Nota:
No se incluyen CSS ni imágenes porque no se modificaron.
