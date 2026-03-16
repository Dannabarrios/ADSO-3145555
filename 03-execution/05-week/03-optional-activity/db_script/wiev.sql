CREATE OR REPLACE VIEW vw_catalogo_vehiculos AS
SELECT
    v.id_vehiculo,
    v.marca,
    v.modelo,
    v.anio,
    v.placa,
    v.color,
    v.tipo,
    v.combustible,
    v.transmision,
    v.capacidad_pasajeros,
    v.precio_por_dia,
    v.estado,
    c.nombre        AS categoria,
    c.tarifa_base,
    s.nombre        AS sucursal,
    s.ciudad,
    f.nombre        AS flota,
    i.url           AS imagen_principal
FROM vehiculo v
JOIN categoria_vehiculo c ON c.id_categoria   = v.id_categoria
LEFT JOIN sucursal      s ON s.id_sucursal    = v.id_sucursal
LEFT JOIN flota         f ON f.id_flota       = v.id_flota
LEFT JOIN imagen_vehiculo i ON i.id_vehiculo  = v.id_vehiculo AND i.es_principal = TRUE
WHERE v.activo = TRUE;


CREATE OR REPLACE VIEW vw_reservas_detalle AS
SELECT
    r.id_reserva,
    r.fecha_inicio,
    r.fecha_fin,
    r.tipo_kilometraje,
    r.costo_base,
    r.costo_seguros,
    r.costo_servicios,
    r.costo_total,
    r.estado                AS estado_reserva,
    r.fecha_creacion,
    u.nombre_completo       AS cliente,
    u.correo                AS correo_cliente,
    v.marca,
    v.modelo,
    v.placa,
    s.nombre                AS sucursal,
    s.ciudad,
    p.metodo_pago,
    p.valor                 AS valor_pagado,
    p.estado                AS estado_pago,
    c.estado_firma,
    c.archivo_url           AS contrato_url
FROM reserva r
JOIN usuario  u ON u.id_usuario  = r.id_usuario
JOIN vehiculo v ON v.id_vehiculo = r.id_vehiculo
JOIN sucursal s ON s.id_sucursal = r.id_sucursal
LEFT JOIN pago     p ON p.id_reserva = r.id_reserva
LEFT JOIN contrato c ON c.id_reserva = r.id_reserva;


CREATE OR REPLACE VIEW vw_usuarios_perfil AS
SELECT
    u.id_usuario,
    u.nombre_completo,
    u.correo,
    u.numero_celular,
    u.nacionalidad,
    u.fecha_nacimiento,
    DATE_PART('year', AGE(u.fecha_nacimiento)) AS edad,
    u.estado,
    u.correo_verificado,
    u.idioma_preferido,
    u.intentos_fallidos,
    u.ultimo_acceso,
    u.fecha_registro,
    r.nombre   AS rol,
    l.estado   AS estado_licencia,
    l.fecha_vencimiento AS vencimiento_licencia
FROM usuario u
JOIN rol r ON r.id_rol = u.id_rol
LEFT JOIN licencia l ON l.id_usuario = u.id_usuario
    AND l.estado = 'vigente';


CREATE OR REPLACE VIEW vw_mantenimientos_activos AS
SELECT
    m.id_mantenimiento,
    m.tipo,
    m.descripcion,
    m.costo,
    m.responsable,
    m.estado,
    m.fecha_programada,
    m.fecha_inicio,
    m.fecha_registro,
    v.marca,
    v.modelo,
    v.placa,
    v.estado   AS estado_vehiculo,
    s.nombre   AS sucursal,
    s.ciudad
FROM mantenimiento m
JOIN vehiculo v ON v.id_vehiculo = m.id_vehiculo
LEFT JOIN sucursal s ON s.id_sucursal = v.id_sucursal
WHERE m.estado IN ('pendiente', 'en_proceso');


CREATE OR REPLACE VIEW vw_pagos_resumen AS
SELECT
    p.id_pago,
    p.metodo_pago,
    p.valor,
    p.referencia,
    p.estado,
    p.fecha_pago,
    r.fecha_inicio,
    r.fecha_fin,
    r.estado       AS estado_reserva,
    u.nombre_completo AS cliente,
    u.correo,
    v.marca,
    v.modelo,
    v.placa
FROM pago p
JOIN reserva  r ON r.id_reserva  = p.id_reserva
JOIN usuario  u ON u.id_usuario  = r.id_usuario
JOIN vehiculo v ON v.id_vehiculo = r.id_vehiculo;


CREATE OR REPLACE VIEW vw_auditoria_detalle AS
SELECT
    a.id_auditoria,
    a.accion,
    a.modulo,
    a.endpoint,
    a.aplicacion,
    a.resultado,
    a.ip_origen,
    a.fecha_evento,
    u.nombre_completo AS usuario,
    u.correo,
    r.nombre          AS rol
FROM auditoria a
LEFT JOIN usuario u ON u.id_usuario = a.id_usuario
LEFT JOIN rol     r ON r.id_rol     = u.id_rol
ORDER BY a.fecha_evento DESC;


CREATE OR REPLACE VIEW vw_casos_soporte AS
SELECT
    c.id_caso,
    c.tipo,
    c.descripcion,
    c.estado,
    c.respuesta,
    c.fecha_creacion,
    c.fecha_cierre,
    u.nombre_completo AS cliente,
    u.correo,
    a.nombre_completo AS administrador
FROM caso c
JOIN usuario u ON u.id_usuario = c.id_usuario
LEFT JOIN usuario a ON a.id_usuario = c.id_admin_resp;


CREATE OR REPLACE VIEW vw_tickets_soporte AS
SELECT
    t.id_ticket,
    t.asunto,
    t.estado,
    t.evaluacion,
    t.fecha_creacion,
    t.fecha_cierre,
    u.nombre_completo AS cliente,
    u.correo,
    a.nombre_completo AS agente,
    COUNT(m.id_mensaje) AS total_mensajes
FROM ticket_soporte t
JOIN usuario u ON u.id_usuario = t.id_usuario
LEFT JOIN usuario  a ON a.id_usuario = t.id_agente
LEFT JOIN mensaje_ticket m ON m.id_ticket = t.id_ticket
GROUP BY
    t.id_ticket, t.asunto, t.estado, t.evaluacion,
    t.fecha_creacion, t.fecha_cierre,
    u.nombre_completo, u.correo,
    a.nombre_completo;


CREATE OR REPLACE VIEW vw_calificaciones_vehiculo AS
SELECT
    v.id_vehiculo,
    v.marca,
    v.modelo,
    v.placa,
    COUNT(c.id_calificacion)                            AS total_calificaciones,
    ROUND(AVG(c.puntuacion_vehiculo), 2)                AS promedio_vehiculo,
    ROUND(AVG(c.puntuacion_servicio), 2)                AS promedio_servicio,
    ROUND(AVG((c.puntuacion_vehiculo + c.puntuacion_servicio) / 2.0), 2) AS promedio_general
FROM vehiculo v
LEFT JOIN calificacion c ON c.id_vehiculo = v.id_vehiculo
    AND c.estado_moderacion = 'aprobado'
GROUP BY v.id_vehiculo, v.marca, v.modelo, v.placa;


CREATE OR REPLACE VIEW vw_disponibilidad_vehiculos AS
SELECT
    v.id_vehiculo,
    v.marca,
    v.modelo,
    v.anio,
    v.placa,
    v.precio_por_dia,
    v.estado,
    c.nombre   AS categoria,
    s.nombre   AS sucursal,
    s.ciudad,
    COUNT(r.id_reserva) FILTER (WHERE r.estado = 'confirmada') AS reservas_activas,
    COUNT(m.id_mantenimiento) FILTER (WHERE m.estado != 'finalizado') AS mantenimientos_activos
FROM vehiculo v
JOIN categoria_vehiculo c ON c.id_categoria  = v.id_categoria
LEFT JOIN sucursal      s ON s.id_sucursal   = v.id_sucursal
LEFT JOIN reserva       r ON r.id_vehiculo   = v.id_vehiculo
LEFT JOIN mantenimiento m ON m.id_vehiculo   = v.id_vehiculo
WHERE v.activo = TRUE
GROUP BY
    v.id_vehiculo, v.marca, v.modelo, v.anio,
    v.placa, v.precio_por_dia, v.estado,
    c.nombre, s.nombre, s.ciudad;