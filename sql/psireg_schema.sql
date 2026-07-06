-- ============================================================
-- PSIREG - Registro Psicologico Institucional
-- Esquema compatible con MySQL 8.x
-- ============================================================

DROP DATABASE IF EXISTS psireg_db;

CREATE DATABASE psireg_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE psireg_db;

-- ============================================================
-- Usuarios del sistema y personal psicologico
-- ============================================================

CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    correo VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    rol ENUM('ADMIN', 'PSICOLOGO') NOT NULL,
    estado ENUM('ACTIVO', 'INACTIVO') NOT NULL DEFAULT 'ACTIVO',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE cargo (
    id_cargo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_cargo VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE psicologo (
    id_psicologo INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    primer_nombre VARCHAR(25) NOT NULL,
    segundo_nombre VARCHAR(25) NULL,
    apellido_paterno VARCHAR(25) NOT NULL,
    apellido_materno VARCHAR(25) NOT NULL,
    cedula VARCHAR(30) NOT NULL UNIQUE,
    genero ENUM('M', 'F', 'OTRO') NOT NULL,
    correo_institucional VARCHAR(120) NOT NULL UNIQUE,
    telefono VARCHAR(20) NOT NULL,
    casa VARCHAR(50) NULL,
    calle VARCHAR(50) NOT NULL,
    corregimiento VARCHAR(50) NOT NULL,
    id_cargo INT NOT NULL,
    estado ENUM('ACTIVO', 'INACTIVO') NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT fk_psicologo_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_psicologo_cargo
        FOREIGN KEY (id_cargo) REFERENCES cargo(id_cargo)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Estructura academica e institucional de pacientes
-- ============================================================

CREATE TABLE facultad (
    id_facultad INT AUTO_INCREMENT PRIMARY KEY,
    nombre_facultad VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE carrera (
    id_carrera INT AUTO_INCREMENT PRIMARY KEY,
    nombre_carrera VARCHAR(80) NOT NULL,
    id_facultad INT NOT NULL,
    CONSTRAINT uq_carrera_facultad UNIQUE (nombre_carrera, id_facultad),
    CONSTRAINT fk_carrera_facultad
        FOREIGN KEY (id_facultad) REFERENCES facultad(id_facultad)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE estudiante (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    primer_nombre VARCHAR(25) NOT NULL,
    segundo_nombre VARCHAR(25) NULL,
    apellido_paterno VARCHAR(25) NOT NULL,
    apellido_materno VARCHAR(25) NOT NULL,
    cedula VARCHAR(30) NOT NULL UNIQUE,
    genero ENUM('M', 'F', 'OTRO') NOT NULL,
    correo_institucional VARCHAR(120) NOT NULL UNIQUE,
    casa VARCHAR(50) NULL,
    calle VARCHAR(50) NOT NULL,
    corregimiento VARCHAR(50) NOT NULL,
    id_carrera INT NOT NULL,
    estado ENUM('ACTIVO', 'INACTIVO') NOT NULL DEFAULT 'ACTIVO',
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_estudiante_carrera
        FOREIGN KEY (id_carrera) REFERENCES carrera(id_carrera)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tipo_tlf_estudiante (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(25) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tlf_estudiante (
    id_estudiante INT NOT NULL,
    id_tipo INT NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_estudiante, id_tipo),
    CONSTRAINT fk_tlf_estudiante_estudiante
        FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tlf_estudiante_tipo
        FOREIGN KEY (id_tipo) REFERENCES tipo_tlf_estudiante(id_tipo)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE docente (
    id_docente INT AUTO_INCREMENT PRIMARY KEY,
    primer_nombre VARCHAR(25) NOT NULL,
    segundo_nombre VARCHAR(25) NULL,
    apellido_paterno VARCHAR(25) NOT NULL,
    apellido_materno VARCHAR(25) NOT NULL,
    cedula VARCHAR(30) NOT NULL UNIQUE,
    genero ENUM('M', 'F', 'OTRO') NOT NULL,
    correo_institucional VARCHAR(120) NOT NULL UNIQUE,
    telefono_personal VARCHAR(20) NOT NULL,
    casa VARCHAR(50) NULL,
    calle VARCHAR(50) NOT NULL,
    corregimiento VARCHAR(50) NOT NULL,
    id_facultad INT NULL,
    estado ENUM('ACTIVO', 'INACTIVO') NOT NULL DEFAULT 'ACTIVO',
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_docente_facultad
        FOREIGN KEY (id_facultad) REFERENCES facultad(id_facultad)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tipo_tlf_docente (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(25) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tlf_docente (
    id_docente INT NOT NULL,
    id_tipo INT NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_docente, id_tipo),
    CONSTRAINT fk_tlf_docente_docente
        FOREIGN KEY (id_docente) REFERENCES docente(id_docente)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tlf_docente_tipo
        FOREIGN KEY (id_tipo) REFERENCES tipo_tlf_docente(id_tipo)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE administrativo (
    id_admin INT AUTO_INCREMENT PRIMARY KEY,
    primer_nombre VARCHAR(25) NOT NULL,
    segundo_nombre VARCHAR(25) NULL,
    apellido_paterno VARCHAR(25) NOT NULL,
    apellido_materno VARCHAR(25) NOT NULL,
    cedula VARCHAR(30) NOT NULL UNIQUE,
    genero ENUM('M', 'F', 'OTRO') NOT NULL,
    correo_institucional VARCHAR(120) NOT NULL UNIQUE,
    telefono_personal VARCHAR(20) NOT NULL,
    casa VARCHAR(50) NOT NULL,
    calle VARCHAR(50) NOT NULL,
    corregimiento VARCHAR(50) NOT NULL,
    departamento VARCHAR(50) NOT NULL,
    estado ENUM('ACTIVO', 'INACTIVO') NOT NULL DEFAULT 'ACTIVO',
    fecha_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tipo_tlf_admin (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(25) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tlf_admin (
    id_admin INT NOT NULL,
    id_tipo INT NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_admin, id_tipo),
    CONSTRAINT fk_tlf_admin_administrativo
        FOREIGN KEY (id_admin) REFERENCES administrativo(id_admin)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_tlf_admin_tipo
        FOREIGN KEY (id_tipo) REFERENCES tipo_tlf_admin(id_tipo)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Servicios y citas
-- ============================================================

CREATE TABLE servicio (
    id_servicio INT AUTO_INCREMENT PRIMARY KEY,
    nombre_servicio VARCHAR(80) NOT NULL UNIQUE,
    estado ENUM('ACTIVO', 'INACTIVO') NOT NULL DEFAULT 'ACTIVO'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE cita (
    id_cita INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    id_servicio INT NOT NULL,
    id_estudiante INT NULL,
    id_docente INT NULL,
    id_admin INT NULL,
    id_psicologo INT NOT NULL,
    motivo VARCHAR(255) NULL,
    observaciones TEXT NULL,
    estado ENUM('PENDIENTE', 'ATENDIDA', 'CANCELADA', 'REPROGRAMADA') 
        NOT NULL DEFAULT 'PENDIENTE',
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_cita_psicologo_fecha_hora 
        UNIQUE (id_psicologo, fecha, hora),

    CONSTRAINT chk_cita_un_paciente CHECK (
        (id_estudiante IS NOT NULL) + 
        (id_docente IS NOT NULL) + 
        (id_admin IS NOT NULL) = 1
    ),

    CONSTRAINT fk_cita_servicio
        FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_cita_estudiante
        FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante),

    CONSTRAINT fk_cita_docente
        FOREIGN KEY (id_docente) REFERENCES docente(id_docente),

    CONSTRAINT fk_cita_admin
        FOREIGN KEY (id_admin) REFERENCES administrativo(id_admin),

    CONSTRAINT fk_cita_psicologo
        FOREIGN KEY (id_psicologo) REFERENCES psicologo(id_psicologo)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci;

-- Refuerzo para instalaciones MySQL que no apliquen CHECK correctamente.
DELIMITER //
CREATE TRIGGER trg_cita_un_paciente_insert
BEFORE INSERT ON cita
FOR EACH ROW
BEGIN
    IF (NEW.id_estudiante IS NOT NULL) + (NEW.id_docente IS NOT NULL) + (NEW.id_admin IS NOT NULL) <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Una cita debe estar asociada exactamente a un paciente.';
    END IF;
END//

CREATE TRIGGER trg_cita_un_paciente_update
BEFORE UPDATE ON cita
FOR EACH ROW
BEGIN
    IF (NEW.id_estudiante IS NOT NULL) + (NEW.id_docente IS NOT NULL) + (NEW.id_admin IS NOT NULL) <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Una cita debe estar asociada exactamente a un paciente.';
    END IF;
END//
DELIMITER ;

-- ============================================================
-- Datos iniciales y de prueba
-- Contraseñas iniciales temporales:
-- admin, lmendez y csoto: PSIREG2026!
-- drios: Contrasenh4
-- Deben cambiarse después de la primera instalación.
-- ============================================================

INSERT INTO usuarios (nombre, apellido, usuario, correo, password_hash, rol) VALUES
    ('Administrador', 'PSIREG', 'admin', 'admin@psireg.edu.pa', 'PBKDF2$120000$LR2cTeb19nCJT9LOTi4Xcw==$ejbKHr6r36Bg1xwpmHkwksZ4umjJUcxamRxnpd9/0eU=', 'ADMIN'),
    ('Laura', 'Mendez', 'lmendez', 'laura.mendez@psireg.edu.pa', 'PBKDF2$120000$+nPFKMrO7c5F8+GObB21PQ==$Y4ItaqKZIPrj1pDfc+nSa5bBs/OCND9ZjsoL3tDuIwk=', 'PSICOLOGO'),
    ('Carlos', 'Soto', 'csoto', 'carlos.soto@psireg.edu.pa', 'PBKDF2$120000$+nPFKMrO7c5F8+GObB21PQ==$Y4ItaqKZIPrj1pDfc+nSa5bBs/OCND9ZjsoL3tDuIwk=', 'PSICOLOGO'),
    ('David', 'Ríos', 'drios', 'david.rios5@utp.ac.pa', 'PBKDF2$120000$UFNJUkVHLURhdmlkLTAwMQ==$hp0nNFP0cdC+W92X3bWzYzXnSReGdRBvpdqYP+zYXHk=', 'PSICOLOGO');

INSERT INTO cargo (nombre_cargo) VALUES
    ('Psicologo Clinico'),
    ('Director');

INSERT INTO psicologo (
    id_usuario, primer_nombre, segundo_nombre, apellido_paterno, apellido_materno,
    cedula, genero, correo_institucional, telefono, casa, calle, corregimiento, id_cargo
) VALUES
    (2, 'Laura', 'Isabel', 'Mendez', 'Rios', '8-123-456', 'F', 'laura.mendez@utp.ac.pa', '6000-1001', '12', 'Avenida Central', 'Bella Vista', 1),
    (3, 'Carlos', 'Andres', 'Soto', 'Perez', '8-987-654', 'M', 'carlos.soto@utp.ac.pa', '6000-1002', '45', 'Calle 50', 'San Francisco', 2),
    (4, 'David', 'Manuel', 'Ríos', 'Estribí', '8-888-8888', 'M', 'david.rios5@utp.ac.pa', '6000-1003', '18', 'Vía España', 'Bella Vista', 1);

INSERT INTO facultad (nombre_facultad) VALUES
    ('Ingenieria de Sistemas Computacionales'),
    ('Ingenieria Civil'),
    ('Ingenieria Electrica');

INSERT INTO carrera (nombre_carrera, id_facultad) VALUES
    ('Lic. Desarrollo de Software', 1),
    ('Ing. Civil', 2),
    ('Ing. Electrica', 3);

INSERT INTO estudiante (
    primer_nombre, segundo_nombre, apellido_paterno, apellido_materno, cedula, genero,
    correo_institucional, casa, calle, corregimiento, id_carrera
) VALUES
    ('Ana', 'Maria', 'Gomez', 'Lopez', '8-111-111', 'F', 'ana.gomez@utp.ac.pa', '10', 'Calle Universidad', 'Bethania', 1),
    ('Jose', 'Luis', 'Rodriguez', 'Diaz', '8-222-222', 'M', 'jose.rodriguez@utp.ac.pa', NULL, 'Via Centenario', 'Ancón', 2);

INSERT INTO tipo_tlf_estudiante (nombre_tipo) VALUES ('Personal'), ('Residencial');
INSERT INTO tlf_estudiante (id_estudiante, id_tipo, telefono) VALUES
    (1, 1, '6000-2001'), (1, 2, '300-2001'), (2, 1, '6000-2002');

INSERT INTO docente (
    primer_nombre, segundo_nombre, apellido_paterno, apellido_materno, cedula, genero,
    correo_institucional, telefono_personal, casa, calle, corregimiento, id_facultad
) VALUES
    ('Marta', 'Elena', 'Castillo', 'Ruiz', '8-333-333', 'F', 'marta.castillo@utp.ac.pa', '6000-3001', '22', 'Calle 42', 'Bella Vista', 1),
    ('Ricardo', NULL, 'Herrera', 'Sanchez', '8-444-444', 'M', 'ricardo.herrera@utp.ac.pa', '6000-3002', NULL, 'Avenida Balboa', 'Calidonia', 2);

INSERT INTO tipo_tlf_docente (nombre_tipo) VALUES ('Personal'), ('Residencial');
INSERT INTO tlf_docente (id_docente, id_tipo, telefono) VALUES
    (1, 1, '6000-3001'), (1, 2, '300-3001'), (2, 1, '6000-3002');

INSERT INTO administrativo (
    primer_nombre, segundo_nombre, apellido_paterno, apellido_materno, cedula, genero,
    correo_institucional, telefono_personal, casa, calle, corregimiento, departamento
) VALUES
    ('Sofia', 'Patricia', 'Moreno', 'Vega', '8-555-555', 'F', 'sofia.moreno@utp.ac.pa', '6000-4001', '31', 'Calle 5', 'Pueblo Nuevo', 'Recursos Humanos'),
    ('Daniel', NULL, 'Torres', 'Gil', '8-666-666', 'M', 'daniel.torres@utp.ac.pa', '6000-4002', '18', 'Avenida Cuba', 'Calidonia', 'Finanzas');

INSERT INTO tipo_tlf_admin (nombre_tipo) VALUES ('Personal'), ('Residencial');
INSERT INTO tlf_admin (id_admin, id_tipo, telefono) VALUES
    (1, 1, '6000-4001'), (1, 2, '300-4001'), (2, 1, '6000-4002');

INSERT INTO servicio (nombre_servicio) VALUES
    ('Orientacion Psicologica'),
    ('Terapia Individual'),
    ('Seguimiento Academico');

INSERT INTO cita (
    fecha, hora, id_servicio, id_estudiante, id_docente, id_admin, id_psicologo,
    motivo, observaciones, estado
) VALUES
    ('2026-06-15', '09:00:00', 1, 1, NULL, NULL, 1, 'Orientacion inicial', 'Paciente referido por bienestar estudiantil.', 'ATENDIDA'),
    ('2026-06-16', '10:30:00', 2, NULL, 1, NULL, 2, 'Manejo de estres', 'Se recomienda seguimiento mensual.', 'ATENDIDA'),
    ('2026-06-17', '14:00:00', 3, NULL, NULL, 1, 1, 'Seguimiento institucional', 'Pendiente de proxima evaluacion.', 'PENDIENTE');

-- ============================================================
-- Vistas de consulta para los modulos JSP
-- ============================================================

CREATE VIEW vw_lista_pacientes AS
SELECT
    e.id_estudiante AS id_paciente,
    'ESTUDIANTE' AS tipo_paciente,
    e.primer_nombre,
    e.segundo_nombre,
    e.apellido_paterno,
    e.apellido_materno,
    CONCAT(e.primer_nombre, ' ', COALESCE(CONCAT(e.segundo_nombre, ' '), ''), e.apellido_paterno, ' ', e.apellido_materno) AS nombre_completo,
    e.cedula,
    e.genero,
    e.correo_institucional,
    e.estado
FROM estudiante e
UNION ALL
SELECT
    d.id_docente AS id_paciente,
    'DOCENTE' AS tipo_paciente,
    d.primer_nombre,
    d.segundo_nombre,
    d.apellido_paterno,
    d.apellido_materno,
    CONCAT(d.primer_nombre, ' ', COALESCE(CONCAT(d.segundo_nombre, ' '), ''), d.apellido_paterno, ' ', d.apellido_materno) AS nombre_completo,
    d.cedula,
    d.genero,
    d.correo_institucional,
    d.estado
FROM docente d
UNION ALL
SELECT
    a.id_admin AS id_paciente,
    'ADMINISTRATIVO' AS tipo_paciente,
    a.primer_nombre,
    a.segundo_nombre,
    a.apellido_paterno,
    a.apellido_materno,
    CONCAT(a.primer_nombre, ' ', COALESCE(CONCAT(a.segundo_nombre, ' '), ''), a.apellido_paterno, ' ', a.apellido_materno) AS nombre_completo,
    a.cedula,
    a.genero,
    a.correo_institucional,
    a.estado
FROM administrativo a;

CREATE VIEW vw_lista_psicologos AS
SELECT
    p.id_psicologo,
    p.id_usuario,
    p.primer_nombre,
    p.segundo_nombre,
    p.apellido_paterno,
    p.apellido_materno,
    CONCAT(p.primer_nombre, ' ', COALESCE(CONCAT(p.segundo_nombre, ' '), ''), p.apellido_paterno, ' ', p.apellido_materno) AS nombre_completo,
    p.cedula,
    p.genero,
    p.correo_institucional,
    p.telefono,
    c.nombre_cargo,
    p.estado
FROM psicologo p
INNER JOIN cargo c ON c.id_cargo = p.id_cargo;

CREATE VIEW vw_expediente_paciente AS
SELECT
    e.id_estudiante AS id_paciente,
    'ESTUDIANTE' AS tipo_paciente,
    CONCAT(e.primer_nombre, ' ', COALESCE(CONCAT(e.segundo_nombre, ' '), ''), e.apellido_paterno, ' ', e.apellido_materno) AS nombre_completo,
    e.cedula,
    e.correo_institucional,
    ci.id_cita,
    ci.fecha,
    ci.hora,
    s.id_servicio,
    s.nombre_servicio,
    p.id_psicologo,
    CONCAT(p.primer_nombre, ' ', COALESCE(CONCAT(p.segundo_nombre, ' '), ''), p.apellido_paterno, ' ', p.apellido_materno) AS psicologo,
    ci.motivo,
    ci.observaciones,
    ci.estado AS estado_cita
FROM cita ci
INNER JOIN estudiante e ON e.id_estudiante = ci.id_estudiante
INNER JOIN servicio s ON s.id_servicio = ci.id_servicio
INNER JOIN psicologo p ON p.id_psicologo = ci.id_psicologo
UNION ALL
SELECT
    d.id_docente,
    'DOCENTE',
    CONCAT(d.primer_nombre, ' ', COALESCE(CONCAT(d.segundo_nombre, ' '), ''), d.apellido_paterno, ' ', d.apellido_materno),
    d.cedula,
    d.correo_institucional,
    ci.id_cita,
    ci.fecha,
    ci.hora,
    s.id_servicio,
    s.nombre_servicio,
    p.id_psicologo,
    CONCAT(p.primer_nombre, ' ', COALESCE(CONCAT(p.segundo_nombre, ' '), ''), p.apellido_paterno, ' ', p.apellido_materno),
    ci.motivo,
    ci.observaciones,
    ci.estado
FROM cita ci
INNER JOIN docente d ON d.id_docente = ci.id_docente
INNER JOIN servicio s ON s.id_servicio = ci.id_servicio
INNER JOIN psicologo p ON p.id_psicologo = ci.id_psicologo
UNION ALL
SELECT
    a.id_admin,
    'ADMINISTRATIVO',
    CONCAT(a.primer_nombre, ' ', COALESCE(CONCAT(a.segundo_nombre, ' '), ''), a.apellido_paterno, ' ', a.apellido_materno),
    a.cedula,
    a.correo_institucional,
    ci.id_cita,
    ci.fecha,
    ci.hora,
    s.id_servicio,
    s.nombre_servicio,
    p.id_psicologo,
    CONCAT(p.primer_nombre, ' ', COALESCE(CONCAT(p.segundo_nombre, ' '), ''), p.apellido_paterno, ' ', p.apellido_materno),
    ci.motivo,
    ci.observaciones,
    ci.estado
FROM cita ci
INNER JOIN administrativo a ON a.id_admin = ci.id_admin
INNER JOIN servicio s ON s.id_servicio = ci.id_servicio
INNER JOIN psicologo p ON p.id_psicologo = ci.id_psicologo;

CREATE VIEW vw_rep_atenciones_psico AS
SELECT
    ep.id_cita,
    ep.fecha,
    ep.hora,
    ep.id_servicio,
    ep.nombre_servicio,
    ep.id_psicologo,
    ep.psicologo,
    ep.id_paciente,
    ep.tipo_paciente,
    ep.nombre_completo AS paciente,
    ep.estado_cita
FROM vw_expediente_paciente ep;

CREATE VIEW vw_expedientes AS
SELECT
    lp.id_paciente,
    lp.tipo_paciente,
    lp.nombre_completo AS paciente,
    lp.cedula,
    lp.correo_institucional,
    ult.fecha AS ultima_fecha_cita,
    ult.psicologo AS ultimo_psicologo,
    ult.estado_cita AS estado_ultima_cita,
    (
        SELECT COUNT(*)
        FROM vw_expediente_paciente ep_total
        WHERE ep_total.id_paciente = lp.id_paciente
          AND ep_total.tipo_paciente = lp.tipo_paciente
    ) AS total_citas
FROM vw_lista_pacientes lp
LEFT JOIN vw_expediente_paciente ult
    ON ult.id_cita = (
        SELECT ep_ultima.id_cita
        FROM vw_expediente_paciente ep_ultima
        WHERE ep_ultima.id_paciente = lp.id_paciente
          AND ep_ultima.tipo_paciente = lp.tipo_paciente
        ORDER BY ep_ultima.fecha DESC, ep_ultima.hora DESC, ep_ultima.id_cita DESC
        LIMIT 1
    );
