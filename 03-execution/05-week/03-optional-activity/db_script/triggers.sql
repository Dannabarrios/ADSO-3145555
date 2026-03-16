CREATE OR REPLACE FUNCTION fn_bloquear_usuario_intentos()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.intentos_fallidos >= 3 AND OLD.intentos_fallidos < 3 THEN
        NEW.estado        := 'bloqueado';
        NEW.fecha_bloqueo := NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_bloquear_usuario_intentos
BEFORE UPDATE ON usuario
FOR EACH ROW
EXECUTE FUNCTION fn_bloquear_usuario_intentos();


CREATE OR REPLACE FUNCTION fn_actualizar_fecha_usuario()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion := NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_fecha_usuario
BEFORE UPDATE ON usuario
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_fecha_usuario();


CREATE OR REPLACE FUNCTION fn_log_cambio_perfil()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.nombre_completo IS DISTINCT FROM OLD.nombre_completo THEN
        INSERT INTO log_cambio_perfil (id_usuario, campo_modificado, valor_anterior, valor_nuevo)
        VALUES (NEW.id_usuario, 'nombre_completo', OLD.nombre_completo, NEW.nombre_completo);
    END IF;
    IF NEW.correo IS DISTINCT FROM OLD.correo THEN
        INSERT INTO log_cambio_perfil (id_usuario, campo_modificado, valor_anterior, valor_nuevo)
        VALUES (NEW.id_usuario, 'correo', OLD.correo, NEW.correo);
    END IF;
    IF NEW.numero_celular IS DISTINCT FROM OLD.numero_celular THEN
        INSERT INTO log_cambio_perfil (id_usuario, campo_modificado, valor_anterior, valor_nuevo)
        VALUES (NEW.id_usuario, 'numero_celular', OLD.numero_celular, NEW.numero_celular);
    END IF;
    IF NEW.idioma_preferido IS DISTINCT FROM OLD.idioma_preferido THEN
        INSERT INTO log_cambio_perfil (id_usuario, campo_modificado, valor_anterior, valor_nuevo)
        VALUES (NEW.id_usuario, 'idioma_preferido', OLD.idioma_preferido, NEW.idioma_preferido);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_cambio_perfil
AFTER UPDATE ON usuario
FOR EACH ROW
EXECUTE FUNCTION fn_log_cambio_perfil();


CREATE OR REPLACE FUNCTION fn_historial_contrasena()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.contrasena_hash IS DISTINCT FROM OLD.contrasena_hash THEN
        INSERT INTO historial_contrasena (id_usuario, contrasena_hash)
        VALUES (OLD.id_usuario, OLD.contrasena_hash);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_historial_contrasena
AFTER UPDATE ON usuario
FOR EACH ROW
EXECUTE FUNCTION fn_historial_contrasena();


CREATE OR REPLACE FUNCTION fn_bloquear_vehiculo_mantenimiento()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.estado IN ('pendiente', 'en_proceso') THEN
        UPDATE vehiculo
        SET estado = 'en_revision'
        WHERE id_vehiculo = NEW.id_vehiculo
          AND estado NOT IN ('en_revision', 'no_disponible', 'inactivo');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_bloquear_vehiculo_mantenimiento
AFTER INSERT OR UPDATE ON mantenimiento
FOR EACH ROW
EXECUTE FUNCTION fn_bloquear_vehiculo_mantenimiento();


CREATE OR REPLACE FUNCTION fn_liberar_vehiculo_mantenimiento()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.estado = 'finalizado' AND OLD.estado != 'finalizado' THEN
        UPDATE vehiculo
        SET estado = 'disponible'
        WHERE id_vehiculo = NEW.id_vehiculo
          AND estado = 'en_revision';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_liberar_vehiculo_mantenimiento
AFTER UPDATE ON mantenimiento
FOR EACH ROW
EXECUTE FUNCTION fn_liberar_vehiculo_mantenimiento();


CREATE OR REPLACE FUNCTION fn_bloquear_vehiculo_reserva()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.estado = 'confirmada' AND (OLD.estado IS NULL OR OLD.estado != 'confirmada') THEN
        UPDATE vehiculo
        SET estado = 'reservado'
        WHERE id_vehiculo = NEW.id_vehiculo
          AND estado = 'disponible';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_bloquear_vehiculo_reserva
AFTER INSERT OR UPDATE ON reserva
FOR EACH ROW
EXECUTE FUNCTION fn_bloquear_vehiculo_reserva();


CREATE OR REPLACE FUNCTION fn_liberar_vehiculo_reserva()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.estado IN ('finalizada', 'cancelada') AND OLD.estado NOT IN ('finalizada', 'cancelada') THEN
        UPDATE vehiculo
        SET estado = 'disponible'
        WHERE id_vehiculo = NEW.id_vehiculo
          AND estado = 'reservado';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_liberar_vehiculo_reserva
AFTER UPDATE ON reserva
FOR EACH ROW
EXECUTE FUNCTION fn_liberar_vehiculo_reserva();


CREATE OR REPLACE FUNCTION fn_confirmar_reserva_pago()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.estado = 'aprobado' AND OLD.estado != 'aprobado' THEN
        UPDATE reserva
        SET estado = 'confirmada'
        WHERE id_reserva = NEW.id_reserva
          AND estado = 'pendiente';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_confirmar_reserva_pago
AFTER UPDATE ON pago
FOR EACH ROW
EXECUTE FUNCTION fn_confirmar_reserva_pago();


CREATE OR REPLACE FUNCTION fn_auditoria_reserva()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO auditoria (id_usuario, accion, modulo, resultado)
        VALUES (NEW.id_usuario, 'Creacion de reserva', 'Reservas', 'exitoso');
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO auditoria (id_usuario, accion, modulo, resultado)
        VALUES (NEW.id_usuario, 'Actualizacion de reserva estado: ' || NEW.estado, 'Reservas', 'exitoso');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_reserva
AFTER INSERT OR UPDATE ON reserva
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_reserva();


CREATE OR REPLACE FUNCTION fn_auditoria_registro_usuario()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO auditoria (id_usuario, accion, modulo, resultado)
    VALUES (NEW.id_usuario, 'Registro de nuevo usuario', 'Usuarios', 'exitoso');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_registro_usuario
AFTER INSERT ON usuario
FOR EACH ROW
EXECUTE FUNCTION fn_auditoria_registro_usuario();


CREATE OR REPLACE FUNCTION fn_historial_config_visual()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.valor IS DISTINCT FROM OLD.valor THEN
        INSERT INTO historial_config_visual (id_config, valor_anterior, valor_nuevo, id_admin)
        VALUES (NEW.id_config, OLD.valor, NEW.valor, NEW.id_admin);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_historial_config_visual
AFTER UPDATE ON configuracion_visual
FOR EACH ROW
EXECUTE FUNCTION fn_historial_config_visual();


CREATE OR REPLACE FUNCTION fn_cerrar_ticket_evaluacion()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.evaluacion IS NOT NULL AND OLD.evaluacion IS NULL THEN
        NEW.estado       := 'cerrado';
        NEW.fecha_cierre := NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cerrar_ticket_evaluacion
BEFORE UPDATE ON ticket_soporte
FOR EACH ROW
EXECUTE FUNCTION fn_cerrar_ticket_evaluacion();