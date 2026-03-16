CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE permiso (
    id_permiso  SERIAL PRIMARY KEY,
    nombre      VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE rol (
    id_rol      SERIAL PRIMARY KEY,
    nombre      VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    activo      BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE rol_permiso (
    id_rol     INT NOT NULL REFERENCES rol(id_rol) ON DELETE CASCADE,
    id_permiso INT NOT NULL REFERENCES permiso(id_permiso) ON DELETE CASCADE,
    fecha_asignacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_rol, id_permiso)
);

CREATE TABLE politica_contrasena (
    id_politica        SERIAL PRIMARY KEY,
    min_longitud       SMALLINT NOT NULL DEFAULT 8,
    max_longitud       SMALLINT NOT NULL DEFAULT 20,
    requiere_mayuscula BOOLEAN NOT NULL DEFAULT TRUE,
    requiere_numero    BOOLEAN NOT NULL DEFAULT TRUE,
    requiere_simbolo   BOOLEAN NOT NULL DEFAULT TRUE,
    caducidad_dias     INT NOT NULL DEFAULT 90,
    activa             BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE configuracion_seguridad (
    id_config   SERIAL PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL UNIQUE,
    valor       VARCHAR(100) NOT NULL,
    descripcion TEXT
);

CREATE TABLE usuario (
    id_usuario          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre_completo     VARCHAR(150) NOT NULL,
    nacionalidad        VARCHAR(80),
    numero_documento    VARCHAR(30) NOT NULL UNIQUE,
    correo              VARCHAR(150) NOT NULL UNIQUE,
    numero_celular      VARCHAR(20),
    fecha_nacimiento    DATE NOT NULL,
    contrasena_hash     TEXT NOT NULL,
    tipo_autenticacion  VARCHAR(20) NOT NULL DEFAULT 'sistema' CHECK (tipo_autenticacion IN ('sistema','oauth')),
    id_rol              INT NOT NULL REFERENCES rol(id_rol),
    estado              VARCHAR(20) NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo','inactivo','bloqueado','eliminado')),
    acepto_terminos     BOOLEAN NOT NULL DEFAULT FALSE,
    correo_verificado   BOOLEAN NOT NULL DEFAULT FALSE,
    idioma_preferido    VARCHAR(10) NOT NULL DEFAULT 'es',
    intentos_fallidos   SMALLINT NOT NULL DEFAULT 0,
    fecha_bloqueo       TIMESTAMPTZ,
    ultimo_acceso       TIMESTAMPTZ,
    fecha_registro      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE usuario_rol (
    id_usuario       UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    id_rol           INT NOT NULL REFERENCES rol(id_rol) ON DELETE CASCADE,
    fecha_asignacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id_usuario, id_rol)
);

CREATE TABLE token_seguridad (
    id_token         SERIAL PRIMARY KEY,
    id_usuario       UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    token            TEXT NOT NULL UNIQUE,
    tipo             VARCHAR(30) NOT NULL CHECK (tipo IN ('activacion','recuperacion')),
    usado            BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_expiracion TIMESTAMPTZ NOT NULL,
    fecha_creacion   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE sesion_usuario (
    id_sesion    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_usuario   UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    token_jwt    TEXT NOT NULL,
    ip_origen    INET,
    dispositivo  VARCHAR(200),
    estado       VARCHAR(20) NOT NULL DEFAULT 'activa' CHECK (estado IN ('activa','cerrada')),
    fecha_inicio TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_cierre TIMESTAMPTZ
);

CREATE TABLE log_errores (
    id_error    BIGSERIAL PRIMARY KEY,
    id_usuario  UUID REFERENCES usuario(id_usuario),
    tipo_error  VARCHAR(100) NOT NULL,
    descripcion TEXT,
    ip_origen   INET,
    fecha       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE token_revocado (
    id_token         BIGSERIAL PRIMARY KEY,
    jti              TEXT NOT NULL UNIQUE,
    id_usuario       UUID NOT NULL REFERENCES usuario(id_usuario),
    fecha_expiracion TIMESTAMPTZ NOT NULL,
    fecha_revocacion TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE historial_contrasena (
    id_historial    BIGSERIAL PRIMARY KEY,
    id_usuario      UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    contrasena_hash TEXT NOT NULL,
    fecha_cambio    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE idioma (
    id_idioma SERIAL PRIMARY KEY,
    codigo    VARCHAR(10) NOT NULL UNIQUE,
    nombre    VARCHAR(50) NOT NULL,
    activo    BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE categoria_vehiculo (
    id_categoria SERIAL PRIMARY KEY,
    nombre       VARCHAR(80) NOT NULL UNIQUE,
    descripcion  TEXT,
    tarifa_base  NUMERIC(10,2) NOT NULL CHECK (tarifa_base > 0),
    capacidad    SMALLINT,
    tipo_uso     VARCHAR(60),
    tamano       VARCHAR(40),
    equipamiento TEXT,
    activo       BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE sucursal (
    id_sucursal      SERIAL PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL UNIQUE,
    direccion        TEXT NOT NULL UNIQUE,
    ciudad           VARCHAR(80) NOT NULL,
    telefono         VARCHAR(20),
    correo           VARCHAR(150),
    horario_apertura TIME,
    horario_cierre   TIME,
    activa           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE flota (
    id_flota       SERIAL PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL UNIQUE,
    codigo         VARCHAR(30) NOT NULL UNIQUE,
    descripcion    TEXT,
    id_sucursal    INT REFERENCES sucursal(id_sucursal),
    activa         BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE vehiculo (
    id_vehiculo         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    marca               VARCHAR(60) NOT NULL,
    modelo              VARCHAR(60) NOT NULL,
    anio                SMALLINT NOT NULL CHECK (anio BETWEEN 2000 AND 2100),
    placa               VARCHAR(10) NOT NULL UNIQUE,
    color               VARCHAR(40),
    tipo                VARCHAR(40),
    id_categoria        INT NOT NULL REFERENCES categoria_vehiculo(id_categoria),
    combustible         VARCHAR(30),
    transmision         VARCHAR(30),
    capacidad_pasajeros SMALLINT,
    precio_por_dia      NUMERIC(10,2) NOT NULL CHECK (precio_por_dia > 0),
    estado              VARCHAR(30) NOT NULL DEFAULT 'disponible' CHECK (estado IN ('disponible','reservado','en_revision','no_disponible','inactivo')),
    kilometraje_inicial NUMERIC(10,2) NOT NULL DEFAULT 0,
    id_sucursal         INT REFERENCES sucursal(id_sucursal),
    id_flota            INT REFERENCES flota(id_flota),
    vin_encriptado      TEXT,
    activo              BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE seguro_vehiculo (
    id_seguro         SERIAL PRIMARY KEY,
    id_vehiculo       UUID NOT NULL REFERENCES vehiculo(id_vehiculo) ON DELETE CASCADE,
    tipo              VARCHAR(20) NOT NULL CHECK (tipo IN ('SOAT','adicional')),
    numero_poliza_enc TEXT NOT NULL,
    fecha_inicio      DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    activo            BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE imagen_vehiculo (
    id_imagen    SERIAL PRIMARY KEY,
    id_vehiculo  UUID NOT NULL REFERENCES vehiculo(id_vehiculo) ON DELETE CASCADE,
    url          TEXT NOT NULL,
    descripcion  VARCHAR(150),
    es_principal BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_carga  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE servicio_adicional (
    id_servicio  SERIAL PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL UNIQUE,
    descripcion  TEXT,
    precio       NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
    disponible   BOOLEAN NOT NULL DEFAULT TRUE,
    id_categoria INT REFERENCES categoria_vehiculo(id_categoria)
);

CREATE TABLE servicio_vehiculo (
    id_servicio INT NOT NULL REFERENCES servicio_adicional(id_servicio),
    id_vehiculo UUID NOT NULL REFERENCES vehiculo(id_vehiculo) ON DELETE CASCADE,
    PRIMARY KEY (id_servicio, id_vehiculo)
);

CREATE TABLE reserva (
    id_reserva          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_usuario          UUID NOT NULL REFERENCES usuario(id_usuario),
    id_vehiculo         UUID NOT NULL REFERENCES vehiculo(id_vehiculo),
    id_sucursal         INT NOT NULL REFERENCES sucursal(id_sucursal),
    fecha_inicio        DATE NOT NULL,
    fecha_fin           DATE NOT NULL,
    tipo_kilometraje    VARCHAR(20) NOT NULL DEFAULT 'limitado' CHECK (tipo_kilometraje IN ('limitado','ilimitado')),
    tarifa_exceso_km    NUMERIC(8,2),
    costo_base          NUMERIC(12,2) NOT NULL CHECK (costo_base >= 0),
    costo_seguros       NUMERIC(12,2) NOT NULL DEFAULT 0,
    costo_servicios     NUMERIC(12,2) NOT NULL DEFAULT 0,
    costo_total         NUMERIC(12,2) NOT NULL CHECK (costo_total >= 0),
    estado              VARCHAR(30) NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente','confirmada','en_curso','finalizada','cancelada')),
    fecha_creacion      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fechas_validas CHECK (fecha_fin > fecha_inicio)
);

CREATE TABLE reserva_servicio (
    id_reserva      UUID NOT NULL REFERENCES reserva(id_reserva) ON DELETE CASCADE,
    id_servicio     INT NOT NULL REFERENCES servicio_adicional(id_servicio),
    cantidad        SMALLINT NOT NULL DEFAULT 1,
    precio_unitario NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (id_reserva, id_servicio)
);

CREATE TABLE contrato (
    id_contrato      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_reserva       UUID NOT NULL UNIQUE REFERENCES reserva(id_reserva),
    metodo_firma     VARCHAR(20) NOT NULL CHECK (metodo_firma IN ('digital','fisico')),
    estado_firma     VARCHAR(20) NOT NULL DEFAULT 'pendiente' CHECK (estado_firma IN ('pendiente','firmado','rechazado')),
    archivo_url      TEXT,
    fecha_generacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_firma      TIMESTAMPTZ
);

CREATE TABLE pago (
    id_pago        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_reserva     UUID NOT NULL REFERENCES reserva(id_reserva),
    metodo_pago    VARCHAR(20) NOT NULL CHECK (metodo_pago IN ('PSE','efectivo')),
    valor          NUMERIC(12,2) NOT NULL CHECK (valor > 0),
    referencia     VARCHAR(100),
    estado         VARCHAR(20) NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente','aprobado','rechazado')),
    fecha_pago     TIMESTAMPTZ,
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE auditoria (
    id_auditoria BIGSERIAL PRIMARY KEY,
    id_usuario   UUID REFERENCES usuario(id_usuario),
    accion       VARCHAR(100) NOT NULL,
    modulo       VARCHAR(60),
    endpoint     VARCHAR(200),
    aplicacion   VARCHAR(100),
    resultado    VARCHAR(20) NOT NULL CHECK (resultado IN ('exitoso','fallido','bloqueado')),
    ip_origen    INET,
    datos_extra  JSONB,
    fecha_evento TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE notificacion_correo (
    id_notificacion BIGSERIAL PRIMARY KEY,
    id_usuario      UUID NOT NULL REFERENCES usuario(id_usuario),
    tipo_evento     VARCHAR(60) NOT NULL,
    asunto          VARCHAR(200) NOT NULL,
    cuerpo_html     TEXT NOT NULL,
    enviado         BOOLEAN NOT NULL DEFAULT FALSE,
    fecha_envio     TIMESTAMPTZ,
    fecha_creacion  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE log_cambio_perfil (
    id_log           BIGSERIAL PRIMARY KEY,
    id_usuario       UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    campo_modificado VARCHAR(60) NOT NULL,
    valor_anterior   TEXT,
    valor_nuevo      TEXT,
    fecha_cambio     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE caso (
    id_caso        BIGSERIAL PRIMARY KEY,
    id_usuario     UUID NOT NULL REFERENCES usuario(id_usuario),
    tipo           VARCHAR(20) NOT NULL CHECK (tipo IN ('queja','sugerencia')),
    descripcion    TEXT NOT NULL,
    estado         VARCHAR(20) NOT NULL DEFAULT 'abierto' CHECK (estado IN ('abierto','en_proceso','cerrado')),
    respuesta      TEXT,
    id_admin_resp  UUID REFERENCES usuario(id_usuario),
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_cierre   TIMESTAMPTZ
);

CREATE TABLE evidencia_caso (
    id_evidencia BIGSERIAL PRIMARY KEY,
    id_caso      BIGINT NOT NULL REFERENCES caso(id_caso) ON DELETE CASCADE,
    url_archivo  TEXT NOT NULL,
    tipo_archivo VARCHAR(10) NOT NULL CHECK (tipo_archivo IN ('PDF','JPG','PNG')),
    fecha_carga  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE ticket_soporte (
    id_ticket      BIGSERIAL PRIMARY KEY,
    id_usuario     UUID NOT NULL REFERENCES usuario(id_usuario),
    asunto         VARCHAR(200) NOT NULL,
    mensaje        TEXT NOT NULL,
    estado         VARCHAR(20) NOT NULL DEFAULT 'abierto' CHECK (estado IN ('abierto','en_proceso','cerrado')),
    evaluacion     SMALLINT CHECK (evaluacion BETWEEN 1 AND 5),
    id_agente      UUID REFERENCES usuario(id_usuario),
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_cierre   TIMESTAMPTZ
);

CREATE TABLE mensaje_ticket (
    id_mensaje  BIGSERIAL PRIMARY KEY,
    id_ticket   BIGINT NOT NULL REFERENCES ticket_soporte(id_ticket) ON DELETE CASCADE,
    id_emisor   UUID NOT NULL REFERENCES usuario(id_usuario),
    contenido   TEXT NOT NULL,
    fecha_envio TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE licencia (
    id_licencia       BIGSERIAL PRIMARY KEY,
    id_usuario        UUID NOT NULL REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    numero_licencia   VARCHAR(50) NOT NULL,
    tipo_licencia     VARCHAR(20),
    fecha_expedicion  DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    estado            VARCHAR(20) NOT NULL DEFAULT 'en_revision' CHECK (estado IN ('vigente','en_revision','rechazada','vencida')),
    url_documento     TEXT,
    id_admin_revisor  UUID REFERENCES usuario(id_usuario),
    fecha_carga       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fecha_revision    TIMESTAMPTZ
);

CREATE TABLE calificacion (
    id_calificacion     BIGSERIAL PRIMARY KEY,
    id_usuario          UUID NOT NULL REFERENCES usuario(id_usuario),
    id_vehiculo         UUID REFERENCES vehiculo(id_vehiculo),
    id_reserva          UUID REFERENCES reserva(id_reserva),
    puntuacion_vehiculo SMALLINT CHECK (puntuacion_vehiculo BETWEEN 1 AND 5),
    puntuacion_servicio SMALLINT CHECK (puntuacion_servicio BETWEEN 1 AND 5),
    comentario          TEXT,
    estado_moderacion   VARCHAR(20) NOT NULL DEFAULT 'pendiente' CHECK (estado_moderacion IN ('pendiente','aprobado','rechazado')),
    id_moderador        UUID REFERENCES usuario(id_usuario),
    fecha_creacion      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE mantenimiento (
    id_mantenimiento BIGSERIAL PRIMARY KEY,
    id_vehiculo      UUID NOT NULL REFERENCES vehiculo(id_vehiculo),
    tipo             VARCHAR(30) NOT NULL CHECK (tipo IN ('preventivo','correctivo','urgente','estetico')),
    descripcion      TEXT NOT NULL,
    costo            NUMERIC(12,2),
    responsable      VARCHAR(100),
    observaciones    TEXT,
    estado           VARCHAR(20) NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente','en_proceso','finalizado')),
    fecha_programada DATE,
    fecha_inicio     TIMESTAMPTZ,
    fecha_fin        TIMESTAMPTZ,
    fecha_registro   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE evidencia_mantenimiento (
    id_evidencia     BIGSERIAL PRIMARY KEY,
    id_mantenimiento BIGINT NOT NULL REFERENCES mantenimiento(id_mantenimiento) ON DELETE CASCADE,
    url_archivo      TEXT NOT NULL,
    tipo_archivo     VARCHAR(10) NOT NULL CHECK (tipo_archivo IN ('PDF','JPG','PNG','MP4')),
    fecha_carga      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE configuracion_visual (
    id_config           SERIAL PRIMARY KEY,
    clave               VARCHAR(100) NOT NULL UNIQUE,
    valor               TEXT NOT NULL,
    descripcion         VARCHAR(200),
    id_admin            UUID REFERENCES usuario(id_usuario),
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE historial_config_visual (
    id_historial   BIGSERIAL PRIMARY KEY,
    id_config      INT NOT NULL REFERENCES configuracion_visual(id_config),
    valor_anterior TEXT,
    valor_nuevo    TEXT,
    id_admin       UUID REFERENCES usuario(id_usuario),
    fecha_cambio   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE log_api (
    id_log        BIGSERIAL PRIMARY KEY,
    id_usuario    UUID REFERENCES usuario(id_usuario),
    metodo_http   VARCHAR(10) NOT NULL CHECK (metodo_http IN ('GET','POST','PUT','PATCH','DELETE')),
    endpoint      VARCHAR(300) NOT NULL,
    version       VARCHAR(10) NOT NULL DEFAULT 'v1',
    codigo_http   SMALLINT NOT NULL,
    ip_origen     INET,
    duracion_ms   INT,
    request_body  JSONB,
    response_body JSONB,
    fecha_llamada TIMESTAMPTZ NOT NULL DEFAULT NOW()
);