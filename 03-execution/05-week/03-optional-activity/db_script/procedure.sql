CREATE OR REPLACE PROCEDURE sp_registrar_usuario(
    p_nombre VARCHAR, p_documento VARCHAR, p_correo VARCHAR,
    p_fecha_nacimiento DATE, p_contrasena_hash TEXT, p_id_rol INT
)
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM usuario WHERE correo = p_correo) THEN
        RAISE EXCEPTION 'Correo ya registrado';
    END IF;
    IF DATE_PART('year', AGE(p_fecha_nacimiento)) < 18 THEN
        RAISE EXCEPTION 'El usuario debe tener minimo 18 anos';
    END IF;
    INSERT INTO usuario (nombre_completo, numero_documento, correo, fecha_nacimiento, contrasena_hash, id_rol, acepto_terminos)
    VALUES (p_nombre, p_documento, p_correo, p_fecha_nacimiento, p_contrasena_hash, p_id_rol, TRUE);
END;
$$;


CREATE OR REPLACE PROCEDURE sp_iniciar_sesion(
    p_correo VARCHAR, p_ip INET, p_dispositivo VARCHAR
)
LANGUAGE plpgsql AS $$
DECLARE v_usr usuario%ROWTYPE;
BEGIN
    SELECT * INTO v_usr FROM usuario WHERE correo = p_correo;
    IF NOT FOUND THEN RAISE EXCEPTION 'Correo no registrado'; END IF;
    IF v_usr.estado != 'activo' THEN RAISE EXCEPTION 'Cuenta no activa: %', v_usr.estado; END IF;
    UPDATE usuario SET intentos_fallidos = 0, ultimo_acceso = NOW() WHERE id_usuario = v_usr.id_usuario;
    INSERT INTO sesion_usuario (id_usuario, token_jwt, ip_origen, dispositivo, estado)
    VALUES (v_usr.id_usuario, 'jwt-' || NOW()::TEXT, p_ip, p_dispositivo, 'activa');
END;
$$;


CREATE OR REPLACE PROCEDURE sp_registrar_intento_fallido(
    p_correo VARCHAR, p_ip INET
)
LANGUAGE plpgsql AS $$
DECLARE v_id UUID;
BEGIN
    SELECT id_usuario INTO v_id FROM usuario WHERE correo = p_correo;
    IF FOUND THEN
        UPDATE usuario SET intentos_fallidos = intentos_fallidos + 1 WHERE id_usuario = v_id;
    END IF;
    INSERT INTO log_errores (id_usuario, tipo_error, descripcion, ip_origen)
    VALUES (v_id, 'Contrasena incorrecta', 'Intento fallido de login', p_ip);
END;
$$;


CREATE OR REPLACE PROCEDURE sp_cerrar_sesion(p_id_sesion UUID)
LANGUAGE plpgsql AS $$
DECLARE v_id_usuario UUID;
BEGIN
    SELECT id_usuario INTO v_id_usuario FROM sesion_usuario WHERE id_sesion = p_id_sesion;
    IF NOT FOUND THEN RAISE EXCEPTION 'Sesion no encontrada'; END IF;
    UPDATE sesion_usuario SET estado = 'cerrada', fecha_cierre = NOW() WHERE id_sesion = p_id_sesion;
    INSERT INTO auditoria (id_usuario, accion, modulo, resultado)
    VALUES (v_id_usuario, 'Cierre de sesion', 'Auth', 'exitoso');
END;
$$;


CREATE OR REPLACE PROCEDURE sp_cambiar_contrasena(
    p_id_usuario UUID, p_hash_actual TEXT, p_hash_nueva TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM usuario WHERE id_usuario = p_id_usuario AND contrasena_hash = p_hash_actual) THEN
        RAISE EXCEPTION 'Contrasena actual incorrecta';
    END IF;
    IF EXISTS (SELECT 1 FROM historial_contrasena WHERE id_usuario = p_id_usuario AND contrasena_hash = p_hash_nueva) THEN
        RAISE EXCEPTION 'No puede reutilizar una contrasena anterior';
    END IF;
    UPDATE usuario SET contrasena_hash = p_hash_nueva WHERE id_usuario = p_id_usuario;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_registrar_vehiculo(
    p_marca VARCHAR, p_modelo VARCHAR, p_anio SMALLINT,
    p_placa VARCHAR, p_id_categoria INT, p_precio NUMERIC,
    p_id_sucursal INT, p_id_flota INT
)
LANGUAGE plpgsql AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM vehiculo WHERE placa = p_placa) THEN
        RAISE EXCEPTION 'Placa % ya registrada', p_placa;
    END IF;
    IF p_precio <= 0 THEN RAISE EXCEPTION 'El precio debe ser mayor a cero'; END IF;
    INSERT INTO vehiculo (marca, modelo, anio, placa, id_categoria, precio_por_dia, id_sucursal, id_flota, estado)
    VALUES (p_marca, p_modelo, p_anio, p_placa, p_id_categoria, p_precio, p_id_sucursal, p_id_flota, 'disponible');
END;
$$;


CREATE OR REPLACE PROCEDURE sp_crear_reserva(
    p_id_usuario UUID, p_id_vehiculo UUID, p_id_sucursal INT,
    p_fecha_inicio DATE, p_fecha_fin DATE,
    p_tipo_km VARCHAR, p_costo_base NUMERIC,
    p_costo_seguros NUMERIC, p_costo_servicios NUMERIC
)
LANGUAGE plpgsql AS $$
BEGIN
    IF (SELECT estado FROM vehiculo WHERE id_vehiculo = p_id_vehiculo) != 'disponible' THEN
        RAISE EXCEPTION 'Vehiculo no disponible';
    END IF;
    IF p_fecha_fin <= p_fecha_inicio THEN
        RAISE EXCEPTION 'Fechas invalidas';
    END IF;
    INSERT INTO reserva (id_usuario, id_vehiculo, id_sucursal, fecha_inicio, fecha_fin,
        tipo_kilometraje, costo_base, costo_seguros, costo_servicios, costo_total, estado)
    VALUES (p_id_usuario, p_id_vehiculo, p_id_sucursal, p_fecha_inicio, p_fecha_fin,
        p_tipo_km, p_costo_base, p_costo_seguros, p_costo_servicios,
        p_costo_base + p_costo_seguros + p_costo_servicios, 'pendiente');
END;
$$;


CREATE OR REPLACE PROCEDURE sp_cancelar_reserva(p_id_reserva UUID, p_id_usuario UUID)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM reserva WHERE id_reserva = p_id_reserva AND id_usuario = p_id_usuario) THEN
        RAISE EXCEPTION 'Reserva no encontrada o sin permiso';
    END IF;
    IF (SELECT estado FROM reserva WHERE id_reserva = p_id_reserva) IN ('finalizada','cancelada') THEN
        RAISE EXCEPTION 'La reserva no puede cancelarse en su estado actual';
    END IF;
    UPDATE reserva SET estado = 'cancelada' WHERE id_reserva = p_id_reserva;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_procesar_pago(
    p_id_reserva UUID, p_metodo VARCHAR, p_valor NUMERIC, p_referencia VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM reserva WHERE id_reserva = p_id_reserva) THEN
        RAISE EXCEPTION 'Reserva no encontrada';
    END IF;
    IF p_valor <= 0 THEN RAISE EXCEPTION 'El valor debe ser mayor a cero'; END IF;
    INSERT INTO pago (id_reserva, metodo_pago, valor, referencia, estado, fecha_pago)
    VALUES (p_id_reserva, p_metodo, p_valor, p_referencia, 'aprobado', NOW());
END;
$$;


CREATE OR REPLACE PROCEDURE sp_registrar_mantenimiento(
    p_id_vehiculo UUID, p_tipo VARCHAR, p_descripcion TEXT,
    p_costo NUMERIC, p_responsable VARCHAR, p_fecha_programada DATE
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM vehiculo WHERE id_vehiculo = p_id_vehiculo) THEN
        RAISE EXCEPTION 'Vehiculo no encontrado';
    END IF;
    INSERT INTO mantenimiento (id_vehiculo, tipo, descripcion, costo, responsable, estado, fecha_programada)
    VALUES (p_id_vehiculo, p_tipo, p_descripcion, p_costo, p_responsable, 'pendiente', p_fecha_programada);
END;
$$;


CREATE OR REPLACE PROCEDURE sp_registrar_caso(
    p_id_usuario UUID, p_tipo VARCHAR, p_descripcion TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    IF TRIM(p_descripcion) = '' OR p_descripcion IS NULL THEN
        RAISE EXCEPTION 'La descripcion no puede estar vacia';
    END IF;
    INSERT INTO caso (id_usuario, tipo, descripcion, estado)
    VALUES (p_id_usuario, p_tipo, p_descripcion, 'abierto');
END;
$$;


CREATE OR REPLACE PROCEDURE sp_responder_caso(
    p_id_caso BIGINT, p_id_admin UUID, p_respuesta TEXT
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM caso WHERE id_caso = p_id_caso AND estado != 'cerrado') THEN
        RAISE EXCEPTION 'Caso no encontrado o ya cerrado';
    END IF;
    UPDATE caso SET respuesta = p_respuesta, id_admin_resp = p_id_admin,
        estado = 'cerrado', fecha_cierre = NOW()
    WHERE id_caso = p_id_caso;
END;
$$;


CREATE OR REPLACE PROCEDURE sp_actualizar_estado_licencia(
    p_id_licencia BIGINT, p_estado VARCHAR, p_id_admin UUID
)
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM licencia WHERE id_licencia = p_id_licencia) THEN
        RAISE EXCEPTION 'Licencia no encontrada';
    END IF;
    UPDATE licencia SET estado = p_estado, id_admin_revisor = p_id_admin, fecha_revision = NOW()
    WHERE id_licencia = p_id_licencia;
    INSERT INTO auditoria (id_usuario, accion, modulo, resultado)
    VALUES (p_id_admin, 'Licencia actualizada a: ' || p_estado, 'Licencias', 'exitoso');
END;
$$;