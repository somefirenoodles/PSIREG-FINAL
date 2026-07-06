PSIREG ACTIVE
=============

<!-- Este archivo es la referencia operativa del entorno local; no contiene configuración de producción. -->

Entorno local probado:

- Eclipse IDE for Enterprise Java 2026-03
- Apache Tomcat 9.0.118 independiente del Tomcat de XAMPP
- MariaDB 10.4.32 de XAMPP en `127.0.0.1:3307`
- MySQL Connector/J 8.4.0 en `WEB-INF/lib`
- Contexto web: `PSIREG`

Inicio rápido
-------------

1. Inicie solamente MySQL desde XAMPP. No inicie el Tomcat de XAMPP.
2. Si la base no existe, ejecute `sql/psireg_schema.sql` en MariaDB.
3. En Eclipse, inicie `Tomcat v9.0 Server at localhost`.
4. Abra `http://localhost:8088/PSIREG/`.

Cuentas locales de prueba
--------------------------

- Administrador: usuario `admin`, contraseña temporal `PSIREG2026!`.
- Psicólogo: usuario `drios` o correo `david.rios5@utp.ac.pa`, contraseña
  temporal `Contrasenh4`.

Después de reemplazar archivos JSP, reinicie Tomcat para publicar los cambios
de forma estable.

Iniciar y detener los servicios
--------------------------------

Ejecute estos comandos desde PowerShell.

### MariaDB de XAMPP

Iniciar:

```powershell
& "C:\Users\Home\Downloads\eclipse-jee-2026-03-R-win32-x86_64\XAMPP\mysql_start.bat"
```

Detener:

```powershell
& "C:\Users\Home\Downloads\eclipse-jee-2026-03-R-win32-x86_64\XAMPP\mysql_stop.bat"
```

También se puede iniciar o detener con el botón **MySQL** de XAMPP Control.

### Tomcat independiente

Iniciar:

```powershell
& "C:\Users\Home\Downloads\eclipse-jee-2026-03-R-win32-x86_64\apache-tomcat-9.0.118\bin\startup.bat"
```

Detener:

```powershell
& "C:\Users\Home\Downloads\eclipse-jee-2026-03-R-win32-x86_64\apache-tomcat-9.0.118\bin\shutdown.bat"
```

Como alternativa, Tomcat se puede iniciar y detener desde la vista **Servers**
de Eclipse. No ejecute simultáneamente el Tomcat iniciado por PowerShell y el
administrado por Eclipse, porque ambos utilizan el puerto `8088`.

Orden recomendado: inicie primero MariaDB y después Tomcat. Para apagar el
entorno, detenga primero Tomcat y luego MariaDB.

La conexión usa por defecto `root`, contraseña vacía y puerto `3307`, que son
los valores del XAMPP local configurado. Se pueden sobrescribir sin editar el
código mediante:

- `PSIREG_DB_URL`
- `PSIREG_DB_USER`
- `PSIREG_DB_PASSWORD`

También se aceptan las propiedades Java equivalentes `psireg.db.url`,
`psireg.db.user` y `psireg.db.password`.
