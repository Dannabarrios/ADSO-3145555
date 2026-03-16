CREATE INDEX idx_usuario_correo ON usuario(correo);

CREATE INDEX idx_usuario_estado ON usuario(estado);

CREATE INDEX idx_usuario_rol ON usuario(id_rol);

CREATE INDEX idx_vehiculo_estado ON vehiculo(estado);

CREATE INDEX idx_vehiculo_categoria ON vehiculo(id_categoria);

CREATE INDEX idx_vehiculo_sucursal ON vehiculo(id_sucursal);

CREATE INDEX idx_vehiculo_placa ON vehiculo(placa);

CREATE INDEX idx_reserva_usuario ON reserva(id_usuario);

CREATE INDEX idx_reserva_vehiculo ON reserva(id_vehiculo);

CREATE INDEX idx_reserva_estado ON reserva(estado);

CREATE INDEX idx_reserva_fechas ON reserva(fecha_inicio, fecha_fin);

CREATE INDEX idx_pago_reserva ON pago(id_reserva);

CREATE INDEX idx_auditoria_usuario ON auditoria(id_usuario);

CREATE INDEX idx_auditoria_fecha ON auditoria(fecha_evento);

CREATE INDEX idx_mantenimiento_vehiculo ON mantenimiento(id_vehiculo);