
-- permiso
INSERT INTO permiso (nombre, descripcion) VALUES
('SELECT',  'Permiso de lectura de datos'),
('INSERT',  'Permiso de insercion de datos'),
('UPDATE',  'Permiso de actualizacion de datos'),
('DELETE',  'Permiso de eliminacion de datos'),
('EXECUTE', 'Permiso de ejecucion de procedimientos'),
('ADMIN',   'Permiso administrativo total'),
('REPORT',  'Permiso para generar reportes'),
('EXPORT',  'Permiso para exportar informacion'),
('AUDIT',   'Permiso para consultar auditoria'),
('CONFIG',  'Permiso para modificar configuracion');

-- rol
INSERT INTO rol (nombre, descripcion, activo) VALUES
('administrador',    'Acceso total al sistema',                    TRUE),
('usuario',          'Acceso a reservas y perfil personal',        TRUE),
('invitado',         'Acceso de solo lectura al catalogo',         TRUE),
('supervisor',       'Supervision de operaciones y reportes',      TRUE),
('agente_soporte',   'Atencion al cliente y gestion de tickets',   TRUE),
('auditor',          'Consulta de registros de auditoria',         TRUE),
('gestor_flota',     'Gestion de vehiculos y flotas',              TRUE),
('gestor_sucursal',  'Administracion de sucursales',               TRUE),
('financiero',       'Acceso a modulo de pagos y finanzas',        TRUE),
('moderador',        'Moderacion de calificaciones y comentarios', TRUE);

-- rol_permiso
INSERT INTO rol_permiso (id_rol, id_permiso) VALUES
(1, 1), (1, 2), (1, 3), (1, 4),
(2, 1), (2, 2),
(3, 1),
(4, 1), (4, 7),
(5, 1), (5, 2),
(6, 1), (6, 9),
(7, 1), (7, 2), (7, 3),
(8, 1), (8, 3),
(9, 1), (9, 7),
(10, 1), (10, 3);

-- politica_contrasena
INSERT INTO politica_contrasena (min_longitud, max_longitud, requiere_mayuscula, requiere_numero, requiere_simbolo, caducidad_dias, activa) VALUES
(8,  20, TRUE,  TRUE,  TRUE,  90,  TRUE),
(10, 25, TRUE,  TRUE,  TRUE,  60,  TRUE),
(6,  15, FALSE, TRUE,  FALSE, 180, FALSE),
(12, 30, TRUE,  TRUE,  TRUE,  30,  FALSE),
(8,  20, TRUE,  TRUE,  FALSE, 90,  FALSE),
(8,  20, FALSE, FALSE, TRUE,  120, FALSE),
(10, 20, TRUE,  TRUE,  TRUE,  45,  FALSE),
(8,  20, TRUE,  FALSE, TRUE,  90,  FALSE),
(9,  25, TRUE,  TRUE,  TRUE,  60,  FALSE),
(8,  20, TRUE,  TRUE,  TRUE,  365, FALSE);

-- configuracion_seguridad
INSERT INTO configuracion_seguridad (nombre, valor, descripcion) VALUES
('max_intentos_fallidos',   '3',     'Intentos maximos antes de bloquear cuenta'),
('duracion_sesion_minutos', '60',    'Tiempo de inactividad para cerrar sesion'),
('token_expiracion_horas',  '24',    'Horas de validez del token JWT'),
('bloqueo_duracion_minutos','30',    'Minutos de bloqueo tras intentos fallidos'),
('tamano_maximo_archivo_mb','10',    'Tamano maximo permitido para archivos adjuntos'),
('formatos_imagen_validos', 'JPG,PNG,SVG', 'Formatos aceptados para imagenes'),
('requiere_https',          'true',  'Forzar uso de HTTPS en todas las solicitudes'),
('version_api',             'v1',    'Version activa de la API REST'),
('idioma_default',          'es',    'Idioma predeterminado del sistema'),
('dias_cierre_caso_auto',   '7',     'Dias para cerrar casos sin respuesta automaticamente');

-- usuario (10 usuarios, roles 1 y 2)
INSERT INTO usuario (id_usuario, nombre_completo, nacionalidad, numero_documento, correo, numero_celular, fecha_nacimiento, contrasena_hash, tipo_autenticacion, id_rol, estado, acepto_terminos, correo_verificado, idioma_preferido, intentos_fallidos) VALUES
('a1000000-0000-0000-0000-000000000001', 'Carlos Andres Perez',   'Colombiana', '10000001', 'carlos.perez@mail.com',   '3001000001', '1990-05-10', '$2b$12$hashadmin001', 'sistema', 1, 'activo',   TRUE,  TRUE,  'es', 0),
('a1000000-0000-0000-0000-000000000002', 'Maria Lucia Gomez',     'Colombiana', '10000002', 'maria.gomez@mail.com',    '3001000002', '1995-08-22', '$2b$12$hashusr002',  'sistema', 2, 'activo',   TRUE,  TRUE,  'es', 0),
('a1000000-0000-0000-0000-000000000003', 'Juan Sebastian Torres', 'Colombiana', '10000003', 'juan.torres@mail.com',    '3001000003', '1988-11-15', '$2b$12$hashusr003',  'sistema', 2, 'activo',   TRUE,  TRUE,  'es', 0),
('a1000000-0000-0000-0000-000000000004', 'Ana Sofia Ramirez',     'Venezolana', '10000004', 'ana.ramirez@mail.com',    '3001000004', '1993-03-07', '$2b$12$hashusr004',  'sistema', 2, 'activo',   TRUE,  TRUE,  'en', 0),
('a1000000-0000-0000-0000-000000000005', 'Luis Fernando Mejia',   'Colombiana', '10000005', 'luis.mejia@mail.com',     '3001000005', '1985-07-19', '$2b$12$hashusr005',  'sistema', 2, 'activo',   TRUE,  TRUE,  'es', 0),
('a1000000-0000-0000-0000-000000000006', 'Daniela Castillo',      'Colombiana', '10000006', 'daniela.castillo@mail.com','3001000006','1997-01-30', '$2b$12$hashusr006',  'sistema', 2, 'activo',   TRUE,  TRUE,  'es', 0),
('a1000000-0000-0000-0000-000000000007', 'Sergio Hernandez',      'Ecuatoriana','10000007', 'sergio.hernandez@mail.com','3001000007','1991-09-12', '$2b$12$hashusr007',  'sistema', 2, 'activo',   TRUE,  TRUE,  'es', 0),
('a1000000-0000-0000-0000-000000000008', 'Valentina Morales',     'Colombiana', '10000008', 'valentina.morales@mail.com','3001000008','1999-06-25','$2b$12$hashusr008',   'sistema', 2, 'bloqueado',TRUE,  FALSE, 'es', 3),
('a1000000-0000-0000-0000-000000000009', 'Diego Alejandro Ruiz',  'Colombiana', '10000009', 'diego.ruiz@mail.com',     '3001000009', '1986-04-18', '$2b$12$hashadmin009','sistema', 1, 'activo',   TRUE,  TRUE,  'es', 0),
('a1000000-0000-0000-0000-000000000010', 'Laura Cristina Vargas', 'Colombiana', '10000010', 'laura.vargas@mail.com',   '3001000010', '2000-12-05', '$2b$12$hashusr010',  'oauth',   2, 'activo',   TRUE,  TRUE,  'fr', 0);

-- usuario_rol
INSERT INTO usuario_rol (id_usuario, id_rol) VALUES
('a1000000-0000-0000-0000-000000000001', 1),
('a1000000-0000-0000-0000-000000000001', 4),
('a1000000-0000-0000-0000-000000000002', 2),
('a1000000-0000-0000-0000-000000000003', 2),
('a1000000-0000-0000-0000-000000000004', 2),
('a1000000-0000-0000-0000-000000000005', 2),
('a1000000-0000-0000-0000-000000000006', 2),
('a1000000-0000-0000-0000-000000000007', 2),
('a1000000-0000-0000-0000-000000000008', 2),
('a1000000-0000-0000-0000-000000000009', 1);

-- token_seguridad
INSERT INTO token_seguridad (id_usuario, token, tipo, usado, fecha_expiracion) VALUES
('a1000000-0000-0000-0000-000000000002', 'tok-act-001', 'activacion',   TRUE,  NOW() - INTERVAL '5 days'),
('a1000000-0000-0000-0000-000000000003', 'tok-act-002', 'activacion',   TRUE,  NOW() - INTERVAL '3 days'),
('a1000000-0000-0000-0000-000000000004', 'tok-rec-001', 'recuperacion', FALSE, NOW() + INTERVAL '1 day'),
('a1000000-0000-0000-0000-000000000005', 'tok-act-003', 'activacion',   TRUE,  NOW() - INTERVAL '10 days'),
('a1000000-0000-0000-0000-000000000006', 'tok-rec-002', 'recuperacion', TRUE,  NOW() - INTERVAL '2 days'),
('a1000000-0000-0000-0000-000000000007', 'tok-act-004', 'activacion',   FALSE, NOW() + INTERVAL '2 days'),
('a1000000-0000-0000-0000-000000000008', 'tok-rec-003', 'recuperacion', FALSE, NOW() + INTERVAL '12 hours'),
('a1000000-0000-0000-0000-000000000009', 'tok-act-005', 'activacion',   TRUE,  NOW() - INTERVAL '7 days'),
('a1000000-0000-0000-0000-000000000010', 'tok-act-006', 'activacion',   TRUE,  NOW() - INTERVAL '1 day'),
('a1000000-0000-0000-0000-000000000001', 'tok-rec-004', 'recuperacion', TRUE,  NOW() - INTERVAL '15 days');

-- sesion_usuario
INSERT INTO sesion_usuario (id_usuario, token_jwt, ip_origen, dispositivo, estado, fecha_inicio, fecha_cierre) VALUES
('a1000000-0000-0000-0000-000000000001', 'jwt-ses-001', '192.168.1.10', 'Chrome/Windows',   'cerrada', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days' + INTERVAL '1 hour'),
('a1000000-0000-0000-0000-000000000002', 'jwt-ses-002', '192.168.1.11', 'Firefox/Ubuntu',   'activa',  NOW() - INTERVAL '30 minutes', NULL),
('a1000000-0000-0000-0000-000000000003', 'jwt-ses-003', '10.0.0.5',     'Safari/macOS',     'cerrada', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day' + INTERVAL '2 hours'),
('a1000000-0000-0000-0000-000000000004', 'jwt-ses-004', '10.0.0.8',     'Chrome/Android',   'activa',  NOW() - INTERVAL '10 minutes', NULL),
('a1000000-0000-0000-0000-000000000005', 'jwt-ses-005', '172.16.0.3',   'Edge/Windows',     'cerrada', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days' + INTERVAL '45 minutes'),
('a1000000-0000-0000-0000-000000000006', 'jwt-ses-006', '192.168.2.20', 'Chrome/Windows',   'activa',  NOW() - INTERVAL '5 minutes', NULL),
('a1000000-0000-0000-0000-000000000007', 'jwt-ses-007', '192.168.3.15', 'Firefox/Windows',  'cerrada', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days' + INTERVAL '30 minutes'),
('a1000000-0000-0000-0000-000000000008', 'jwt-ses-008', '10.10.0.1',    'Chrome/iOS',       'cerrada', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day' + INTERVAL '5 minutes'),
('a1000000-0000-0000-0000-000000000009', 'jwt-ses-009', '192.168.1.50', 'Chrome/Windows',   'activa',  NOW() - INTERVAL '1 hour', NULL),
('a1000000-0000-0000-0000-000000000010', 'jwt-ses-010', '10.0.1.9',     'Safari/iPhone',    'activa',  NOW() - INTERVAL '20 minutes', NULL);

-- log_errores
INSERT INTO log_errores (id_usuario, tipo_error, descripcion, ip_origen) VALUES
('a1000000-0000-0000-0000-000000000008', 'Contrasena incorrecta',      'Intento fallido de inicio de sesion',     '10.10.0.1'),
('a1000000-0000-0000-0000-000000000008', 'Contrasena incorrecta',      'Segundo intento fallido',                 '10.10.0.1'),
('a1000000-0000-0000-0000-000000000008', 'Cuenta bloqueada',           'Tercer intento fallido, cuenta bloqueada','10.10.0.1'),
('a1000000-0000-0000-0000-000000000003', 'Token expirado',             'Token de recuperacion ya no es valido',   '10.0.0.5'),
('a1000000-0000-0000-0000-000000000005', 'Acceso no autorizado',       'Intento de acceso a modulo restringido',  '172.16.0.3'),
(NULL,                                   'IP sospechosa',              'Multiples intentos desde IP desconocida', '45.33.32.156'),
('a1000000-0000-0000-0000-000000000004', 'Formato de correo invalido', 'Correo ingresado no tiene formato valido','10.0.0.8'),
('a1000000-0000-0000-0000-000000000007', 'Contrasena incorrecta',      'Intento fallido de inicio de sesion',     '192.168.3.15'),
(NULL,                                   'Solicitud malformada',       'Body JSON invalido en endpoint /reservas', '203.0.113.10'),
('a1000000-0000-0000-0000-000000000002', 'Token invalido',             'JWT con firma incorrecta rechazado',      '192.168.1.11');

-- token_revocado
INSERT INTO token_revocado (jti, id_usuario, fecha_expiracion) VALUES
('jti-rev-001', 'a1000000-0000-0000-0000-000000000001', NOW() - INTERVAL '1 day'),
('jti-rev-002', 'a1000000-0000-0000-0000-000000000003', NOW() - INTERVAL '2 days'),
('jti-rev-003', 'a1000000-0000-0000-0000-000000000005', NOW() - INTERVAL '3 days'),
('jti-rev-004', 'a1000000-0000-0000-0000-000000000007', NOW() - INTERVAL '4 days'),
('jti-rev-005', 'a1000000-0000-0000-0000-000000000008', NOW() - INTERVAL '5 days'),
('jti-rev-006', 'a1000000-0000-0000-0000-000000000002', NOW() - INTERVAL '6 days'),
('jti-rev-007', 'a1000000-0000-0000-0000-000000000009', NOW() - INTERVAL '7 days'),
('jti-rev-008', 'a1000000-0000-0000-0000-000000000004', NOW() - INTERVAL '8 days'),
('jti-rev-009', 'a1000000-0000-0000-0000-000000000006', NOW() - INTERVAL '9 days'),
('jti-rev-010', 'a1000000-0000-0000-0000-000000000010', NOW() - INTERVAL '10 days');

-- historial_contrasena
INSERT INTO historial_contrasena (id_usuario, contrasena_hash) VALUES
('a1000000-0000-0000-0000-000000000001', '$2b$12$oldhash001a'),
('a1000000-0000-0000-0000-000000000001', '$2b$12$oldhash001b'),
('a1000000-0000-0000-0000-000000000002', '$2b$12$oldhash002a'),
('a1000000-0000-0000-0000-000000000003', '$2b$12$oldhash003a'),
('a1000000-0000-0000-0000-000000000004', '$2b$12$oldhash004a'),
('a1000000-0000-0000-0000-000000000005', '$2b$12$oldhash005a'),
('a1000000-0000-0000-0000-000000000006', '$2b$12$oldhash006a'),
('a1000000-0000-0000-0000-000000000007', '$2b$12$oldhash007a'),
('a1000000-0000-0000-0000-000000000009', '$2b$12$oldhash009a'),
('a1000000-0000-0000-0000-000000000010', '$2b$12$oldhash010a');

-- idioma
INSERT INTO idioma (codigo, nombre, activo) VALUES
('es',    'Espanol',              TRUE),
('en',    'Ingles',               TRUE),
('fr',    'Frances',              TRUE),
('pt',    'Portugues',            TRUE),
('pt-BR', 'Portugues Brasileno',  TRUE),
('de',    'Aleman',               FALSE),
('it',    'Italiano',             FALSE),
('zh',    'Chino',                FALSE),
('ar',    'Arabe',                FALSE),
('ja',    'Japones',              FALSE);

-- categoria_vehiculo
INSERT INTO categoria_vehiculo (nombre, descripcion, tarifa_base, capacidad, tipo_uso, tamano, equipamiento, activo) VALUES
('Sedan',      'Automovil de 4 puertas estandar',         80000.00,  5, 'urbano',       'mediano',  'AC, radio, GPS',              TRUE),
('SUV',        'Vehiculo utilitario deportivo',            120000.00, 7, 'todo terreno', 'grande',   'AC, 4x4, GPS, camara',        TRUE),
('Pick-Up',    'Camioneta con platafoma de carga',         150000.00, 5, 'carga',        'grande',   'AC, toldo, GPS',              TRUE),
('Van',        'Furgoneta para pasajeros o carga',         180000.00, 9, 'transporte',   'grande',   'AC, TV, GPS',                 TRUE),
('Deportivo',  'Vehiculo de alto rendimiento',             200000.00, 2, 'recreativo',   'pequeno',  'AC, turbo, pantalla tactil',  TRUE),
('Compacto',   'Vehiculo pequeno de bajo consumo',         60000.00,  5, 'urbano',       'pequeno',  'AC, radio',                   TRUE),
('Minivan',    'Furgoneta familiar amplia',                160000.00, 8, 'familiar',     'grande',   'AC, TV, GPS, camara',         TRUE),
('Electrico',  'Vehiculo de propulsion electrica',         140000.00, 5, 'urbano',       'mediano',  'AC, cargador, pantalla',      TRUE),
('Camioneta',  'Vehiculo de doble cabina',                 170000.00, 5, 'mixto',        'grande',   'AC, GPS, caja',               TRUE),
('Lujo',       'Vehiculo premium de alta gama',            350000.00, 5, 'ejecutivo',    'grande',   'AC, cuero, masaje, GPS, TV',  TRUE);

-- sucursal
INSERT INTO sucursal (nombre, direccion, ciudad, telefono, correo, horario_apertura, horario_cierre, activa) VALUES
('Sucursal Centro',      'Calle 10 # 5-20',         'Bogota',      '6011000001', 'centro@renta.com',      '07:00', '20:00', TRUE),
('Sucursal Norte',       'Carrera 15 # 80-30',      'Bogota',      '6011000002', 'norte@renta.com',       '07:00', '20:00', TRUE),
('Sucursal Sur',         'Av. 68 # 40-10',          'Bogota',      '6011000003', 'sur@renta.com',         '08:00', '19:00', TRUE),
('Sucursal Medellin',    'Carrera 43A # 19-50',     'Medellin',    '6041000004', 'medellin@renta.com',    '07:00', '20:00', TRUE),
('Sucursal Cali',        'Av. 9N # 15-40',          'Cali',        '6021000005', 'cali@renta.com',        '08:00', '19:00', TRUE),
('Sucursal Barranquilla','Carrera 53 # 72-150',     'Barranquilla','6051000006', 'barranquilla@renta.com','07:00', '19:00', TRUE),
('Sucursal Cartagena',   'Av. Santander # 40-30',   'Cartagena',   '6061000007', 'cartagena@renta.com',   '08:00', '18:00', TRUE),
('Sucursal Bucaramanga', 'Calle 52 # 30-15',        'Bucaramanga', '6071000008', 'bucaramanga@renta.com', '07:00', '19:00', TRUE),
('Sucursal Pereira',     'Carrera 8 # 20-60',       'Pereira',     '6061000009', 'pereira@renta.com',     '08:00', '18:00', FALSE),
('Sucursal Manizales',   'Carrera 23 # 62-14',      'Manizales',   '6068000010', 'manizales@renta.com',   '08:00', '17:00', FALSE);

-- flota
INSERT INTO flota (nombre, codigo, descripcion, id_sucursal, activa) VALUES
('Flota Ejecutiva Bogota',  'FLT-BOG-EJE', 'Vehiculos de lujo para clientes corporativos', 1, TRUE),
('Flota Economica Norte',   'FLT-BOG-ECO', 'Vehiculos compactos y sedanes',                2, TRUE),
('Flota SUV Medellin',      'FLT-MED-SUV', 'SUV y camionetas para todo terreno',           4, TRUE),
('Flota Familiar Cali',     'FLT-CAL-FAM', 'Minivans y vans para familias',                5, TRUE),
('Flota Electrica',         'FLT-BOG-ELE', 'Vehiculos electricos en Bogota',               1, TRUE),
('Flota Pick-Up Caribe',    'FLT-CTG-PIC', 'Camionetas pick-up zona caribe',               7, TRUE),
('Flota Deportiva',         'FLT-BOG-DEP', 'Vehiculos deportivos de alto rendimiento',     2, TRUE),
('Flota Carga Bogota',      'FLT-BOG-CAR', 'Vans y pick-ups para transporte de carga',     3, TRUE),
('Flota Estandar Sur',      'FLT-BOG-STD', 'Vehiculos estandar para uso diario',           3, TRUE),
('Flota Bucaramanga',       'FLT-BUC-GEN', 'Flota general sucursal Bucaramanga',           8, TRUE);

-- vehiculo
INSERT INTO vehiculo (id_vehiculo, marca, modelo, anio, placa, color, tipo, id_categoria, combustible, transmision, capacidad_pasajeros, precio_por_dia, estado, kilometraje_inicial, id_sucursal, id_flota) VALUES
('b2000000-0000-0000-0000-000000000001', 'Toyota',  'Corolla',    2022, 'ABC123', 'Blanco',  'Sedan',    1, 'Gasolina', 'Automatica', 5, 80000.00,  'disponible', 5000.00,  1, 1),
('b2000000-0000-0000-0000-000000000002', 'Chevrolet','Tracker',   2023, 'DEF456', 'Gris',    'SUV',      2, 'Gasolina', 'Automatica', 5, 120000.00, 'disponible', 3200.00,  4, 3),
('b2000000-0000-0000-0000-000000000003', 'Ford',    'Ranger',     2021, 'GHI789', 'Negro',   'Pick-Up',  3, 'Diesel',   'Manual',     5, 150000.00, 'disponible', 28000.00, 7, 6),
('b2000000-0000-0000-0000-000000000004', 'Mercedes','Sprinter',   2020, 'JKL012', 'Blanco',  'Van',      4, 'Diesel',   'Manual',     9, 180000.00, 'disponible', 52000.00, 3, 8),
('b2000000-0000-0000-0000-000000000005', 'Porsche', '718 Cayman', 2022, 'MNO345', 'Rojo',    'Deportivo',5, 'Gasolina', 'Automatica', 2, 200000.00, 'disponible', 8000.00,  2, 7),
('b2000000-0000-0000-0000-000000000006', 'Renault', 'Logan',      2021, 'PQR678', 'Azul',    'Compacto', 6, 'Gasolina', 'Manual',     5, 60000.00,  'disponible', 15000.00, 5, 9),
('b2000000-0000-0000-0000-000000000007', 'Kia',     'Carnival',   2023, 'STU901', 'Plata',   'Minivan',  7, 'Gasolina', 'Automatica', 8, 160000.00, 'disponible', 2000.00,  5, 4),
('b2000000-0000-0000-0000-000000000008', 'BYD',     'Atto 3',     2023, 'VWX234', 'Verde',   'Electrico',8, 'Electrico','Automatica', 5, 140000.00, 'disponible', 500.00,   1, 5),
('b2000000-0000-0000-0000-000000000009', 'Mazda',   'CX-5',       2022, 'YZA567', 'Blanco',  'SUV',      2, 'Gasolina', 'Automatica', 5, 125000.00, 'en_revision',18000.00, 4, 3),
('b2000000-0000-0000-0000-000000000010', 'BMW',     '520i',       2023, 'BCD890', 'Negro',   'Lujo',     10,'Gasolina', 'Automatica', 5, 350000.00, 'disponible', 4500.00,  1, 1);

-- seguro_vehiculo
INSERT INTO seguro_vehiculo (id_vehiculo, tipo, numero_poliza_enc, fecha_inicio, fecha_vencimiento, activo) VALUES
('b2000000-0000-0000-0000-000000000001', 'SOAT',     'enc-soat-001', '2024-01-01', '2025-01-01', TRUE),
('b2000000-0000-0000-0000-000000000001', 'adicional', 'enc-adi-001',  '2024-01-01', '2025-01-01', TRUE),
('b2000000-0000-0000-0000-000000000002', 'SOAT',     'enc-soat-002', '2024-02-01', '2025-02-01', TRUE),
('b2000000-0000-0000-0000-000000000002', 'adicional', 'enc-adi-002',  '2024-02-01', '2025-02-01', TRUE),
('b2000000-0000-0000-0000-000000000003', 'SOAT',     'enc-soat-003', '2024-03-01', '2025-03-01', TRUE),
('b2000000-0000-0000-0000-000000000004', 'SOAT',     'enc-soat-004', '2024-01-15', '2025-01-15', TRUE),
('b2000000-0000-0000-0000-000000000005', 'SOAT',     'enc-soat-005', '2024-04-01', '2025-04-01', TRUE),
('b2000000-0000-0000-0000-000000000005', 'adicional', 'enc-adi-005',  '2024-04-01', '2025-04-01', TRUE),
('b2000000-0000-0000-0000-000000000008', 'SOAT',     'enc-soat-008', '2024-05-01', '2025-05-01', TRUE),
('b2000000-0000-0000-0000-000000000010','SOAT',      'enc-soat-010', '2024-06-01', '2025-06-01', TRUE);

-- imagen_vehiculo
INSERT INTO imagen_vehiculo (id_vehiculo, url, descripcion, es_principal) VALUES
('b2000000-0000-0000-0000-000000000001', '/img/v001_front.jpg',  'Vista frontal Toyota Corolla',    TRUE),
('b2000000-0000-0000-0000-000000000001', '/img/v001_side.jpg',   'Vista lateral Toyota Corolla',    FALSE),
('b2000000-0000-0000-0000-000000000002', '/img/v002_front.jpg',  'Vista frontal Chevrolet Tracker', TRUE),
('b2000000-0000-0000-0000-000000000003', '/img/v003_front.jpg',  'Vista frontal Ford Ranger',       TRUE),
('b2000000-0000-0000-0000-000000000004', '/img/v004_front.jpg',  'Vista frontal Mercedes Sprinter', TRUE),
('b2000000-0000-0000-0000-000000000005', '/img/v005_front.jpg',  'Vista frontal Porsche 718',       TRUE),
('b2000000-0000-0000-0000-000000000006', '/img/v006_front.jpg',  'Vista frontal Renault Logan',     TRUE),
('b2000000-0000-0000-0000-000000000007', '/img/v007_front.jpg',  'Vista frontal Kia Carnival',      TRUE),
('b2000000-0000-0000-0000-000000000008', '/img/v008_front.jpg',  'Vista frontal BYD Atto 3',        TRUE),
('b2000000-0000-0000-0000-000000000010', '/img/v010_front.jpg',  'Vista frontal BMW 520i',          TRUE);

-- servicio_adicional
INSERT INTO servicio_adicional (nombre, descripcion, precio, disponible, id_categoria) VALUES
('Silla para bebe',       'Silla de seguridad para menores',          25000.00, TRUE,  NULL),
('GPS premium',           'Navegador GPS actualizado',                 15000.00, TRUE,  NULL),
('Seguro adicional',      'Cobertura extra ante danos',                50000.00, TRUE,  NULL),
('Conductor adicional',   'Registro de segundo conductor autorizado',  20000.00, TRUE,  NULL),
('Tanque lleno garantizado', 'Vehiculo entregado con tanque lleno',    30000.00, TRUE,  NULL),
('Asistencia en carretera',  'Servicio de asistencia 24/7',            35000.00, TRUE,  NULL),
('Wi-Fi portatil',        'Dispositivo de internet movil incluido',    20000.00, TRUE,  NULL),
('Limpieza premium',      'Limpieza detallada previa a la entrega',    15000.00, TRUE,  NULL),
('Entrega en aeropuerto', 'Entrega y recogida en terminal aerea',      40000.00, TRUE,  NULL),
('Portaequipajes',        'Rack de techo para equipaje extra',         20000.00, TRUE,  NULL);

-- servicio_vehiculo
INSERT INTO servicio_vehiculo (id_servicio, id_vehiculo) VALUES
(1, 'b2000000-0000-0000-0000-000000000001'),
(2, 'b2000000-0000-0000-0000-000000000001'),
(3, 'b2000000-0000-0000-0000-000000000002'),
(4, 'b2000000-0000-0000-0000-000000000002'),
(5, 'b2000000-0000-0000-0000-000000000003'),
(6, 'b2000000-0000-0000-0000-000000000004'),
(7, 'b2000000-0000-0000-0000-000000000008'),
(8, 'b2000000-0000-0000-0000-000000000010'),
(9, 'b2000000-0000-0000-0000-000000000010'),
(10,'b2000000-0000-0000-0000-000000000003');

-- reserva
INSERT INTO reserva (id_reserva, id_usuario, id_vehiculo, id_sucursal, fecha_inicio, fecha_fin, tipo_kilometraje, costo_base, costo_seguros, costo_servicios, costo_total, estado) VALUES
('c3000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000002', 'b2000000-0000-0000-0000-000000000001', 1, '2024-07-01', '2024-07-05', 'limitado',   320000.00, 50000.00, 25000.00, 395000.00, 'finalizada'),
('c3000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000003', 'b2000000-0000-0000-0000-000000000002', 4, '2024-07-10', '2024-07-14', 'ilimitado',  480000.00, 70000.00, 40000.00, 590000.00, 'finalizada'),
('c3000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000004', 'b2000000-0000-0000-0000-000000000006', 5, '2024-08-01', '2024-08-03', 'limitado',   120000.00, 30000.00, 0.00,     150000.00, 'finalizada'),
('c3000000-0000-0000-0000-000000000004', 'a1000000-0000-0000-0000-000000000005', 'b2000000-0000-0000-0000-000000000010', 1, '2024-08-15', '2024-08-17', 'ilimitado',  700000.00, 90000.00, 55000.00, 845000.00, 'finalizada'),
('c3000000-0000-0000-0000-000000000005', 'a1000000-0000-0000-0000-000000000006', 'b2000000-0000-0000-0000-000000000005', 2, '2024-09-01', '2024-09-02', 'limitado',   200000.00, 60000.00, 35000.00, 295000.00, 'cancelada'),
('c3000000-0000-0000-0000-000000000006', 'a1000000-0000-0000-0000-000000000007', 'b2000000-0000-0000-0000-000000000003', 7, '2024-09-10', '2024-09-14', 'limitado',   600000.00, 80000.00, 50000.00, 730000.00, 'finalizada'),
('c3000000-0000-0000-0000-000000000007', 'a1000000-0000-0000-0000-000000000010', 'b2000000-0000-0000-0000-000000000008', 1, '2024-10-01', '2024-10-03', 'ilimitado',  280000.00, 40000.00, 20000.00, 340000.00, 'confirmada'),
('c3000000-0000-0000-0000-000000000008', 'a1000000-0000-0000-0000-000000000002', 'b2000000-0000-0000-0000-000000000007', 5, '2024-10-10', '2024-10-15', 'limitado',   800000.00, 75000.00, 30000.00, 905000.00, 'pendiente'),
('c3000000-0000-0000-0000-000000000009', 'a1000000-0000-0000-0000-000000000004', 'b2000000-0000-0000-0000-000000000001', 1, '2024-11-01', '2024-11-04', 'limitado',   240000.00, 50000.00, 15000.00, 305000.00, 'en_curso'),
('c3000000-0000-0000-0000-000000000010', 'a1000000-0000-0000-0000-000000000005', 'b2000000-0000-0000-0000-000000000002', 4, '2024-11-10', '2024-11-12', 'ilimitado',  240000.00, 70000.00, 40000.00, 350000.00, 'pendiente');

-- reserva_servicio
INSERT INTO reserva_servicio (id_reserva, id_servicio, cantidad, precio_unitario) VALUES
('c3000000-0000-0000-0000-000000000001', 1, 1, 25000.00),
('c3000000-0000-0000-0000-000000000002', 3, 1, 50000.00),
('c3000000-0000-0000-0000-000000000002', 4, 1, 20000.00),
('c3000000-0000-0000-0000-000000000004', 8, 1, 15000.00),
('c3000000-0000-0000-0000-000000000004', 9, 1, 40000.00),
('c3000000-0000-0000-0000-000000000006', 5, 1, 30000.00),
('c3000000-0000-0000-0000-000000000006', 10,1, 20000.00),
('c3000000-0000-0000-0000-000000000007', 7, 1, 20000.00),
('c3000000-0000-0000-0000-000000000009', 2, 1, 15000.00),
('c3000000-0000-0000-0000-000000000001', 6, 1, 35000.00);

-- contrato
INSERT INTO contrato (id_reserva, metodo_firma, estado_firma, archivo_url, fecha_firma) VALUES
('c3000000-0000-0000-0000-000000000001', 'digital', 'firmado',   '/contratos/cnt001.pdf', NOW() - INTERVAL '90 days'),
('c3000000-0000-0000-0000-000000000002', 'digital', 'firmado',   '/contratos/cnt002.pdf', NOW() - INTERVAL '80 days'),
('c3000000-0000-0000-0000-000000000003', 'fisico',  'firmado',   '/contratos/cnt003.pdf', NOW() - INTERVAL '70 days'),
('c3000000-0000-0000-0000-000000000004', 'digital', 'firmado',   '/contratos/cnt004.pdf', NOW() - INTERVAL '60 days'),
('c3000000-0000-0000-0000-000000000005', 'digital', 'rechazado', NULL,                    NULL),
('c3000000-0000-0000-0000-000000000006', 'fisico',  'firmado',   '/contratos/cnt006.pdf', NOW() - INTERVAL '40 days'),
('c3000000-0000-0000-0000-000000000007', 'digital', 'firmado',   '/contratos/cnt007.pdf', NOW() - INTERVAL '10 days'),
('c3000000-0000-0000-0000-000000000008', 'digital', 'pendiente', NULL,                    NULL),
('c3000000-0000-0000-0000-000000000009', 'fisico',  'firmado',   '/contratos/cnt009.pdf', NOW() - INTERVAL '3 days'),
('c3000000-0000-0000-0000-000000000010', 'digital', 'pendiente', NULL,                    NULL);

-- pago
INSERT INTO pago (id_reserva, metodo_pago, valor, referencia, estado, fecha_pago) VALUES
('c3000000-0000-0000-0000-000000000001', 'PSE',      395000.00, 'PSE-REF-001', 'aprobado',  NOW() - INTERVAL '90 days'),
('c3000000-0000-0000-0000-000000000002', 'efectivo', 590000.00, 'EFE-REF-002', 'aprobado',  NOW() - INTERVAL '80 days'),
('c3000000-0000-0000-0000-000000000003', 'PSE',      150000.00, 'PSE-REF-003', 'aprobado',  NOW() - INTERVAL '70 days'),
('c3000000-0000-0000-0000-000000000004', 'PSE',      845000.00, 'PSE-REF-004', 'aprobado',  NOW() - INTERVAL '60 days'),
('c3000000-0000-0000-0000-000000000005', 'PSE',      295000.00, 'PSE-REF-005', 'rechazado', NULL),
('c3000000-0000-0000-0000-000000000006', 'efectivo', 730000.00, 'EFE-REF-006', 'aprobado',  NOW() - INTERVAL '40 days'),
('c3000000-0000-0000-0000-000000000007', 'PSE',      340000.00, 'PSE-REF-007', 'aprobado',  NOW() - INTERVAL '10 days'),
('c3000000-0000-0000-0000-000000000008', 'efectivo', 905000.00, NULL,          'pendiente', NULL),
('c3000000-0000-0000-0000-000000000009', 'PSE',      305000.00, 'PSE-REF-009', 'aprobado',  NOW() - INTERVAL '3 days'),
('c3000000-0000-0000-0000-000000000010', 'PSE',      350000.00, NULL,          'pendiente', NULL);

-- auditoria
INSERT INTO auditoria (id_usuario, accion, modulo, endpoint, aplicacion, resultado, ip_origen) VALUES
('a1000000-0000-0000-0000-000000000001', 'Registro de vehiculo',       'Vehiculos',   '/api/v1/vehiculos',      'web',   'exitoso',  '192.168.1.10'),
('a1000000-0000-0000-0000-000000000002', 'Inicio de sesion',           'Auth',        '/api/v1/auth/login',     'web',   'exitoso',  '192.168.1.11'),
('a1000000-0000-0000-0000-000000000003', 'Creacion de reserva',        'Reservas',    '/api/v1/reservas',       'web',   'exitoso',  '10.0.0.5'),
('a1000000-0000-0000-0000-000000000008', 'Inicio de sesion fallido',   'Auth',        '/api/v1/auth/login',     'web',   'fallido',  '10.10.0.1'),
('a1000000-0000-0000-0000-000000000004', 'Consulta de vehiculos',      'Vehiculos',   '/api/v1/vehiculos',      'movil', 'exitoso',  '10.0.0.8'),
('a1000000-0000-0000-0000-000000000005', 'Pago de reserva',            'Pagos',       '/api/v1/pagos',          'web',   'exitoso',  '172.16.0.3'),
('a1000000-0000-0000-0000-000000000009', 'Registro de administrador',  'Usuarios',    '/api/v1/admin/usuarios', 'web',   'exitoso',  '192.168.1.50'),
('a1000000-0000-0000-0000-000000000006', 'Subida de licencia',         'Licencias',   '/api/v1/licencias',      'web',   'exitoso',  '192.168.2.20'),
('a1000000-0000-0000-0000-000000000007', 'Cierre de sesion',           'Auth',        '/api/v1/auth/logout',    'web',   'exitoso',  '192.168.3.15'),
(NULL,                                   'Acceso como invitado',       'Catalogo',    '/api/v1/catalogo',       'web',   'exitoso',  '203.0.113.55');

-- notificacion_correo
INSERT INTO notificacion_correo (id_usuario, tipo_evento, asunto, cuerpo_html, enviado, fecha_envio) VALUES
('a1000000-0000-0000-0000-000000000002', 'activacion',    'Activa tu cuenta',              '<p>Hola, activa tu cuenta aqui.</p>',       TRUE,  NOW() - INTERVAL '10 days'),
('a1000000-0000-0000-0000-000000000003', 'reserva',       'Reserva confirmada',            '<p>Tu reserva ha sido confirmada.</p>',      TRUE,  NOW() - INTERVAL '80 days'),
('a1000000-0000-0000-0000-000000000004', 'pago',          'Pago recibido',                 '<p>Tu pago fue procesado correctamente.</p>',TRUE,  NOW() - INTERVAL '70 days'),
('a1000000-0000-0000-0000-000000000005', 'contrato',      'Contrato listo para firmar',    '<p>Descarga y firma tu contrato.</p>',       TRUE,  NOW() - INTERVAL '60 days'),
('a1000000-0000-0000-0000-000000000006', 'queja',         'Respuesta a tu queja',          '<p>Hemos respondido a tu queja.</p>',        TRUE,  NOW() - INTERVAL '5 days'),
('a1000000-0000-0000-0000-000000000007', 'mantenimiento', 'Vehiculo en mantenimiento',     '<p>El vehiculo esta en revision.</p>',       TRUE,  NOW() - INTERVAL '40 days'),
('a1000000-0000-0000-0000-000000000008', 'cuenta_bloqueada','Cuenta bloqueada',            '<p>Tu cuenta fue bloqueada por seguridad.</p>',TRUE,NOW() - INTERVAL '1 day'),
('a1000000-0000-0000-0000-000000000010', 'reserva',       'Reserva en proceso',            '<p>Tu reserva esta siendo procesada.</p>',   FALSE, NULL),
('a1000000-0000-0000-0000-000000000009', 'recuperacion',  'Recupera tu contrasena',        '<p>Sigue el enlace para cambiar tu contrasena.</p>', TRUE, NOW() - INTERVAL '15 days'),
('a1000000-0000-0000-0000-000000000002', 'cancelacion',   'Reserva cancelada',             '<p>Tu reserva fue cancelada exitosamente.</p>', TRUE, NOW() - INTERVAL '30 days');

-- log_cambio_perfil
INSERT INTO log_cambio_perfil (id_usuario, campo_modificado, valor_anterior, valor_nuevo) VALUES
('a1000000-0000-0000-0000-000000000002', 'numero_celular',   '3001000002', '3209999002'),
('a1000000-0000-0000-0000-000000000003', 'correo',           'juan.torres@mail.com', 'j.torres@correo.com'),
('a1000000-0000-0000-0000-000000000004', 'nombre_completo',  'Ana Sofia Ramirez',   'Ana S. Ramirez'),
('a1000000-0000-0000-0000-000000000005', 'idioma_preferido', 'es', 'en'),
('a1000000-0000-0000-0000-000000000006', 'numero_celular',   '3001000006', '3118880006'),
('a1000000-0000-0000-0000-000000000007', 'correo',           'sergio.hernandez@mail.com','s.hernandez@correo.com'),
('a1000000-0000-0000-0000-000000000009', 'nombre_completo',  'Diego Alejandro Ruiz','Diego A. Ruiz'),
('a1000000-0000-0000-0000-000000000010', 'idioma_preferido', 'fr', 'es'),
('a1000000-0000-0000-0000-000000000001', 'numero_celular',   '3001000001', '3105550001'),
('a1000000-0000-0000-0000-000000000002', 'idioma_preferido', 'es', 'en');

-- caso
INSERT INTO caso (id_usuario, tipo, descripcion, estado, respuesta, id_admin_resp) VALUES
('a1000000-0000-0000-0000-000000000002', 'queja',      'El vehiculo tenia el vidrio rayado al recibirlo',         'cerrado',    'Se reviso y se aplicara descuento en proxima reserva', 'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000003', 'sugerencia', 'Agregar opcion de pago con tarjeta de credito',           'cerrado',    'Se evaluara en la siguiente actualizacion del sistema',  'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000004', 'queja',      'Cobro adicional no autorizado en la factura',             'en_proceso', NULL, NULL),
('a1000000-0000-0000-0000-000000000005', 'queja',      'El GPS del vehiculo no funcionaba correctamente',         'cerrado',    'Se verifico y el GPS fue reemplazado',                  'a1000000-0000-0000-0000-000000000009'),
('a1000000-0000-0000-0000-000000000006', 'sugerencia', 'Mejorar la app movil para reservas rapidas',              'abierto',    NULL, NULL),
('a1000000-0000-0000-0000-000000000007', 'queja',      'Vehiculo entregado con menos combustible del acordado',   'cerrado',    'Se reembolso el costo del combustible faltante',        'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000010', 'sugerencia', 'Incluir vehiculos electricos en todas las sucursales',    'abierto',    NULL, NULL),
('a1000000-0000-0000-0000-000000000002', 'queja',      'Tiempo de espera muy largo en la sucursal norte',         'en_proceso', NULL, NULL),
('a1000000-0000-0000-0000-000000000003', 'sugerencia', 'Ofrecer descuentos por reservas frecuentes',              'cerrado',    'Se incluira en el programa de fidelidad',               'a1000000-0000-0000-0000-000000000009'),
('a1000000-0000-0000-0000-000000000004', 'queja',      'La pagina web falla al intentar cancelar una reserva',    'abierto',    NULL, NULL);

-- evidencia_caso
INSERT INTO evidencia_caso (id_caso, url_archivo, tipo_archivo) VALUES
(1,  '/evidencias/caso001_foto1.jpg',  'JPG'),
(1,  '/evidencias/caso001_reporte.pdf','PDF'),
(3,  '/evidencias/caso003_factura.pdf','PDF'),
(4,  '/evidencias/caso004_gps.jpg',    'JPG'),
(6,  '/evidencias/caso006_foto1.jpg',  'JPG'),
(6,  '/evidencias/caso006_foto2.jpg',  'JPG'),
(8,  '/evidencias/caso008_captura.png','PNG'),
(9,  '/evidencias/caso009_doc.pdf',    'PDF'),
(2,  '/evidencias/caso002_idea.pdf',   'PDF'),
(10, '/evidencias/caso010_error.png',  'PNG');

-- ticket_soporte
INSERT INTO ticket_soporte (id_usuario, asunto, mensaje, estado, evaluacion, id_agente) VALUES
('a1000000-0000-0000-0000-000000000002', 'No puedo iniciar sesion',          'Mi cuenta dice que esta bloqueada',               'cerrado',    5, 'a1000000-0000-0000-0000-000000000009'),
('a1000000-0000-0000-0000-000000000003', 'Error al realizar el pago',        'El pago PSE no se procesa correctamente',          'cerrado',    4, 'a1000000-0000-0000-0000-000000000009'),
('a1000000-0000-0000-0000-000000000004', 'Contrato no llega al correo',      'No he recibido el contrato para firmar',           'en_proceso', NULL, 'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000005', 'Como agrego conductor adicional',  'Deseo agregar a mi esposa como conductora',        'cerrado',    5, 'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000006', 'Error en la fecha de reserva',     'El sistema no acepta la fecha que quiero',         'abierto',    NULL, NULL),
('a1000000-0000-0000-0000-000000000007', 'Factura con datos incorrectos',    'El nombre en la factura esta equivocado',          'en_proceso', NULL, 'a1000000-0000-0000-0000-000000000009'),
('a1000000-0000-0000-0000-000000000010', 'Vehiculo no estaba disponible',    'Me cobraron pero el vehiculo no estaba disponible','cerrado',    2, 'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000002', 'Necesito cambiar mi correo',       'Quiero actualizar mi correo electronico',          'cerrado',    4, 'a1000000-0000-0000-0000-000000000009'),
('a1000000-0000-0000-0000-000000000003', 'Problema con el GPS incluido',     'El GPS no tiene mapas actualizados',               'abierto',    NULL, NULL),
('a1000000-0000-0000-0000-000000000004', 'Solicito reembolso',               'Cancele mi reserva y no veo el reembolso',         'en_proceso', NULL, 'a1000000-0000-0000-0000-000000000001');

-- mensaje_ticket
INSERT INTO mensaje_ticket (id_ticket, id_emisor, contenido) VALUES
(1, 'a1000000-0000-0000-0000-000000000002', 'Hola, mi cuenta aparece bloqueada y no puedo entrar'),
(1, 'a1000000-0000-0000-0000-000000000009', 'Hola, revisamos tu cuenta y fue desbloqueada. Intenta nuevamente'),
(2, 'a1000000-0000-0000-0000-000000000003', 'El boton de pago PSE no responde en el paso 3'),
(2, 'a1000000-0000-0000-0000-000000000009', 'Gracias por reportarlo. Ya fue corregido el error'),
(3, 'a1000000-0000-0000-0000-000000000004', 'Firme el contrato hace 2 dias y no me llega nada'),
(3, 'a1000000-0000-0000-0000-000000000001', 'Verificaremos el envio del correo. Por favor confirma tu correo actual'),
(5, 'a1000000-0000-0000-0000-000000000006', 'Intento poner la fecha 2024-12-01 y me dice que es invalida'),
(7, 'a1000000-0000-0000-0000-000000000010', 'Me cobro la reserva pero al llegar el auto no estaba disponible'),
(7, 'a1000000-0000-0000-0000-000000000001', 'Lamentamos el inconveniente. Se realizo el reembolso total'),
(10,'a1000000-0000-0000-0000-000000000004', 'Cancele hace 5 dias y el reembolso aun no aparece en mi cuenta');

-- licencia
INSERT INTO licencia (id_usuario, numero_licencia, tipo_licencia, fecha_expedicion, fecha_vencimiento, estado, url_documento, id_admin_revisor) VALUES
('a1000000-0000-0000-0000-000000000002', 'LIC-001-2020', 'B1', '2020-03-15', '2030-03-15', 'vigente',     '/licencias/lic001.pdf', 'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000003', 'LIC-002-2019', 'B1', '2019-06-20', '2029-06-20', 'vigente',     '/licencias/lic002.pdf', 'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000004', 'LIC-003-2021', 'B1', '2021-01-10', '2031-01-10', 'vigente',     '/licencias/lic003.pdf', 'a1000000-0000-0000-0000-000000000009'),
('a1000000-0000-0000-0000-000000000005', 'LIC-004-2018', 'C1', '2018-09-05', '2028-09-05', 'vigente',     '/licencias/lic004.pdf', 'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000006', 'LIC-005-2022', 'B1', '2022-04-14', '2032-04-14', 'en_revision', '/licencias/lic005.pdf', NULL),
('a1000000-0000-0000-0000-000000000007', 'LIC-006-2020', 'B1', '2020-07-22', '2030-07-22', 'vigente',     '/licencias/lic006.pdf', 'a1000000-0000-0000-0000-000000000009'),
('a1000000-0000-0000-0000-000000000008', 'LIC-007-2021', 'B1', '2021-11-30', '2031-11-30', 'rechazada',   '/licencias/lic007.pdf', 'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000010', 'LIC-008-2023', 'B1', '2023-02-18', '2033-02-18', 'vigente',     '/licencias/lic008.pdf', 'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000001', 'LIC-009-2017', 'B1', '2017-08-01', '2027-08-01', 'vigente',     '/licencias/lic009.pdf', NULL),
('a1000000-0000-0000-0000-000000000009', 'LIC-010-2019', 'C1', '2019-12-05', '2029-12-05', 'vigente',     '/licencias/lic010.pdf', NULL);

-- calificacion
INSERT INTO calificacion (id_usuario, id_vehiculo, id_reserva, puntuacion_vehiculo, puntuacion_servicio, comentario, estado_moderacion, id_moderador) VALUES
('a1000000-0000-0000-0000-000000000002', 'b2000000-0000-0000-0000-000000000001', 'c3000000-0000-0000-0000-000000000001', 5, 5, 'Excelente vehiculo, muy limpio y puntual',         'aprobado', 'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000003', 'b2000000-0000-0000-0000-000000000002', 'c3000000-0000-0000-0000-000000000002', 4, 5, 'Muy buena atencion, el SUV es comodo',             'aprobado', 'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000004', 'b2000000-0000-0000-0000-000000000006', 'c3000000-0000-0000-0000-000000000003', 4, 4, 'Buen servicio aunque el carro tenia poco gas',     'aprobado', 'a1000000-0000-0000-0000-000000000009'),
('a1000000-0000-0000-0000-000000000005', 'b2000000-0000-0000-0000-000000000010','c3000000-0000-0000-0000-000000000004',  5, 5, 'El BMW es espectacular, servicio de lujo',         'aprobado', 'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000007', 'b2000000-0000-0000-0000-000000000003', 'c3000000-0000-0000-0000-000000000006', 5, 4, 'La pick-up perfecta para el viaje de trabajo',     'aprobado', 'a1000000-0000-0000-0000-000000000009'),
('a1000000-0000-0000-0000-000000000006', 'b2000000-0000-0000-0000-000000000005', 'c3000000-0000-0000-0000-000000000005', 2, 2, 'El carro fue cancelado sin aviso previo',          'aprobado', 'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000010', 'b2000000-0000-0000-0000-000000000008', 'c3000000-0000-0000-0000-000000000007', 5, 5, 'El electrico es increible, silencioso y rapido',   'aprobado', 'a1000000-0000-0000-0000-000000000001'),
('a1000000-0000-0000-0000-000000000002', 'b2000000-0000-0000-0000-000000000001', 'c3000000-0000-0000-0000-000000000009', 5, 5, 'Segunda vez que rento este auto, sigue perfecto',  'pendiente', NULL),
('a1000000-0000-0000-0000-000000000003', 'b2000000-0000-0000-0000-000000000002', 'c3000000-0000-0000-0000-000000000002', 3, 4, 'El AC tenia un ruido extrano pero funciono bien',  'pendiente', NULL),
('a1000000-0000-0000-0000-000000000004', 'b2000000-0000-0000-0000-000000000001', 'c3000000-0000-0000-0000-000000000009', 4, 5, 'Entrega puntual, muy amables en la sucursal',      'rechazado', 'a1000000-0000-0000-0000-000000000009');

-- mantenimiento
INSERT INTO mantenimiento (id_vehiculo, tipo, descripcion, costo, responsable, observaciones, estado, fecha_programada, fecha_inicio, fecha_fin) VALUES
('b2000000-0000-0000-0000-000000000009', 'correctivo', 'Cambio de frenos traseros desgastados',        350000.00, 'Taller Central',   'Desgaste mayor al normal',          'finalizado', '2024-09-01', NOW() - INTERVAL '30 days', NOW() - INTERVAL '28 days'),
('b2000000-0000-0000-0000-000000000001', 'preventivo', 'Cambio de aceite y filtros a los 10000 km',    120000.00, 'Taller Centro',    'Mantenimiento rutinario',           'finalizado', '2024-08-15', NOW() - INTERVAL '45 days', NOW() - INTERVAL '44 days'),
('b2000000-0000-0000-0000-000000000003', 'preventivo', 'Revision general de motor y suspension',       200000.00, 'Taller Caribe',    'Sin novedades relevantes',          'finalizado', '2024-07-20', NOW() - INTERVAL '60 days', NOW() - INTERVAL '59 days'),
('b2000000-0000-0000-0000-000000000006', 'estetico',   'Pintura y pulida exterior completa',            280000.00, 'Taller Sur',       'Rayones menores en puerta derecha', 'finalizado', '2024-06-10', NOW() - INTERVAL '90 days', NOW() - INTERVAL '87 days'),
('b2000000-0000-0000-0000-000000000008', 'preventivo', 'Revision del sistema electrico y carga',       180000.00, 'Taller Electrico', 'Bateria en buen estado',            'finalizado', '2024-09-05', NOW() - INTERVAL '20 days', NOW() - INTERVAL '18 days'),
('b2000000-0000-0000-0000-000000000002', 'correctivo', 'Reparacion de fuga en aire acondicionado',     420000.00, 'Taller Medellin',  'Fuga en compresor detectada',       'en_proceso', '2024-10-10', NOW() - INTERVAL '5 days',  NULL),
('b2000000-0000-0000-0000-000000000004', 'preventivo', 'Cambio de llantas delantera',                  600000.00, 'Taller Sur',       'Desgaste uniforme esperado',        'finalizado', '2024-08-01', NOW() - INTERVAL '50 days', NOW() - INTERVAL '49 days'),
('b2000000-0000-0000-0000-000000000005', 'preventivo', 'Revision de suspension y frenos deportivos',   250000.00, 'Taller Norte',     'Frenos deportivos en buen estado',  'finalizado', '2024-07-15', NOW() - INTERVAL '70 days', NOW() - INTERVAL '69 days'),
('b2000000-0000-0000-0000-000000000007', 'estetico',   'Limpieza profunda de tapiceria interior',       150000.00, 'Detailing Cali',   'Manchas de cafe en asiento',        'pendiente',  '2024-11-01', NULL, NULL),
('b2000000-0000-0000-0000-000000000010', 'preventivo', 'Revision completa previa a contrato de lujo',  300000.00, 'Taller Ejecutivo', 'Vehiculo en perfectas condiciones', 'finalizado', '2024-09-20', NOW() - INTERVAL '15 days', NOW() - INTERVAL '14 days');

-- evidencia_mantenimiento
INSERT INTO evidencia_mantenimiento (id_mantenimiento, url_archivo, tipo_archivo) VALUES
(1,  '/mant/mant001_foto1.jpg',   'JPG'),
(1,  '/mant/mant001_reporte.pdf', 'PDF'),
(2,  '/mant/mant002_foto1.jpg',   'JPG'),
(3,  '/mant/mant003_video.mp4',   'MP4'),
(4,  '/mant/mant004_antes.jpg',   'JPG'),
(4,  '/mant/mant004_despues.jpg', 'JPG'),
(5,  '/mant/mant005_informe.pdf', 'PDF'),
(6,  '/mant/mant006_fuga.jpg',    'JPG'),
(8,  '/mant/mant008_frenos.jpg',  'JPG'),
(10, '/mant/mant010_cert.pdf',    'PDF');

-- configuracion_visual
INSERT INTO configuracion_visual (clave, valor, descripcion, id_admin) VALUES
('color_primario',    '#2563eb', 'Color principal de la marca',             'a1000000-0000-0000-0000-000000000001'),
('color_secundario',  '#1e40af', 'Color secundario de la marca',            'a1000000-0000-0000-0000-000000000001'),
('color_acento',      '#f59e0b', 'Color de acento y botones',               'a1000000-0000-0000-0000-000000000001'),
('color_fondo',       '#f8fafc', 'Color de fondo de la interfaz',           'a1000000-0000-0000-0000-000000000001'),
('color_texto',       '#111928', 'Color principal del texto',               'a1000000-0000-0000-0000-000000000001'),
('logo_url',          '/assets/logo.png',       'URL del logotipo principal',       'a1000000-0000-0000-0000-000000000009'),
('logo_oscuro_url',   '/assets/logo_dark.png',  'URL del logotipo version oscura',  'a1000000-0000-0000-0000-000000000009'),
('fuente_principal',  'Inter',                  'Fuente tipografica principal',     'a1000000-0000-0000-0000-000000000001'),
('nombre_empresa',    'RentaVehiculos S.A.S.',  'Nombre legal de la empresa',       'a1000000-0000-0000-0000-000000000001'),
('favicon_url',       '/assets/favicon.ico',    'URL del icono del sitio',          'a1000000-0000-0000-0000-000000000009');

-- historial_config_visual
INSERT INTO historial_config_visual (id_config, valor_anterior, valor_nuevo, id_admin) VALUES
(1, '#1d4ed8', '#2563eb', 'a1000000-0000-0000-0000-000000000001'),
(2, '#1e3a8a', '#1e40af', 'a1000000-0000-0000-0000-000000000001'),
(3, '#d97706', '#f59e0b', 'a1000000-0000-0000-0000-000000000001'),
(6, '/assets/logo_old.png',      '/assets/logo.png',      'a1000000-0000-0000-0000-000000000009'),
(7, '/assets/logo_dark_old.png', '/assets/logo_dark.png', 'a1000000-0000-0000-0000-000000000009'),
(1, '#2563eb', '#1a56db', 'a1000000-0000-0000-0000-000000000001'),
(1, '#1a56db', '#2563eb', 'a1000000-0000-0000-0000-000000000001'),
(4, '#f1f5f9', '#f8fafc', 'a1000000-0000-0000-0000-000000000001'),
(5, '#0f172a', '#111928', 'a1000000-0000-0000-0000-000000000001'),
(8, 'Nunito',  'Inter',   'a1000000-0000-0000-0000-000000000001');

-- log_api
INSERT INTO log_api (id_usuario, metodo_http, endpoint, version, codigo_http, ip_origen, duracion_ms) VALUES
('a1000000-0000-0000-0000-000000000002', 'POST',   '/api/v1/auth/login',      'v1', 200, '192.168.1.11', 120),
('a1000000-0000-0000-0000-000000000003', 'POST',   '/api/v1/reservas',        'v1', 201, '10.0.0.5',     340),
('a1000000-0000-0000-0000-000000000004', 'GET',    '/api/v1/vehiculos',       'v1', 200, '10.0.0.8',     80),
('a1000000-0000-0000-0000-000000000005', 'POST',   '/api/v1/pagos',           'v1', 201, '172.16.0.3',   510),
('a1000000-0000-0000-0000-000000000001', 'POST',   '/api/v1/vehiculos',       'v1', 201, '192.168.1.10', 230),
('a1000000-0000-0000-0000-000000000009', 'PUT',    '/api/v1/usuarios/a100',   'v1', 200, '192.168.1.50', 195),
('a1000000-0000-0000-0000-000000000006', 'POST',   '/api/v1/licencias',       'v1', 201, '192.168.2.20', 415),
('a1000000-0000-0000-0000-000000000008', 'POST',   '/api/v1/auth/login',      'v1', 401, '10.10.0.1',    90),
(NULL,                                   'GET',    '/api/v1/catalogo',        'v1', 200, '203.0.113.55', 65),
('a1000000-0000-0000-0000-000000000010', 'PATCH',  '/api/v1/reservas/c3007',  'v1', 200, '10.0.1.9',     180);