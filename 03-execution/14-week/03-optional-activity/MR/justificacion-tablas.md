# Justificación Técnica — Tabla por Tabla
## Sistema de Horarios SENA — Modelo Relacional MongoDB

> Proyecto: SENA Schedule Manager | Versión: 10.0  
> 48 colecciones · 17 módulos · MongoDB · Go · React

---

## MÓDULO 1 — Seguridad y Acceso

---

### `usuario`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Identificador único generado por MongoDB. Se usa ObjectId nativo porque `usuario` es una colección interna del sistema, sin necesidad de IDs compartidos con sistemas externos. |
| `instructor_id` | ObjectId (FK) | Un usuario del sistema es generalmente un instructor. Esta FK permite vincular la cuenta de acceso con el perfil académico del instructor sin duplicar sus datos personales. Relación 1:1 opcional porque puede haber administradores sin perfil de instructor. |
| `correo` | String (PII) | Correo institucional usado como identificador de login. Marcado PII por Ley 1581. No se usa como `_id` porque puede cambiar (rotación de correos institucionales). |
| `password_hash` | String | Nunca se almacena la contraseña en texto plano. El hash se genera con bcrypt en el backend Go antes de persistir. Este campo justifica por qué `usuario` es una colección separada de `instructor`: los datos de seguridad no deben mezclarse con datos académicos. |
| `activo` | Boolean | Permite deshabilitar cuentas sin eliminarlas, preservando el `log_auditoria` asociado. Requerido por el threat model para implementar revocación de acceso. |
| `ultimo_acceso` | Date | Registro del último login. Permite detectar cuentas inactivas y cumplir políticas de seguridad (desactivar cuentas sin uso en N días). |
| `creado_en` / `actualizado_en` | Date | Campos de auditoría estándar. `creado_en` es inmutable; `actualizado_en` se actualiza en cada modificación. Requeridos por S-06 del threat model. |

**Por qué existe esta colección:** El threat model V8/V9 detectó que sin autenticación cualquier actor puede invocar cualquier endpoint (STRIDE: Spoofing). `usuario` implementa la identidad verificable del sistema.

---

### `rol`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `nombre` | String | Nombre del rol: `administrador`, `coordinador`, `instructor`, `visor`. Catálogo controlado con pocos valores que raramente cambian. |
| `descripcion` | String | Descripción de los permisos del rol. Documentación embebida que el frontend puede mostrar al administrador al asignar roles. |

**Por qué existe esta colección:** STRIDE: *Elevation of Privilege*. Sin roles, un usuario con acceso de visor puede ejecutar operaciones de escritura. La separación en colección propia (en lugar de un array en `usuario`) permite que un usuario tenga múltiples roles sin duplicar la definición de cada rol.

---

### `usuario_rol`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `usuario_id` | ObjectId (FK) | Referencia al usuario. |
| `rol_id` | ObjectId (FK) | Referencia al rol. |
| `creado_en` | Date | Auditoría de cuándo se asignó el rol. |

**Por qué existe esta colección:** La relación usuario ↔ rol es N:M. Un coordinador también puede ser instructor. Un administrador puede tener todos los roles. Sin esta tabla pivote se necesitaría un array de roles embebido en `usuario`, que no es indexable eficientemente en MongoDB para consultas del tipo "dame todos los coordinadores".

---

### `log_auditoria`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `usuario_id` | ObjectId (FK) | Quién ejecutó la operación. FK a `usuario`. |
| `coleccion` | String | Nombre de la colección afectada (ej. `"ficha"`, `"bloque_horario"`). Permite filtrar logs por entidad. |
| `documento_id` | String | ID del documento afectado. String porque puede ser cualquier ObjectId convertido. |
| `accion` | String | `"create"`, `"update"`, `"delete"`, `"cancel"`. Vocabulario controlado definido en el backend. |
| `datos_anteriores` | Object | Snapshot del documento antes de la modificación. Permite reconstruir el estado anterior. Para creaciones este campo es null. |
| `creado_en` | Date | Timestamp de la operación. Este documento es **inmutable** una vez creado. Nunca se actualiza ni elimina. |

**Por qué existe esta colección:** STRIDE: *Repudiation*. Sin logs no hay forma de rastrear quién canceló un bloque o modificó una ficha. Requerido por S-06 del threat model y por la Ley 1581 (trazabilidad de acceso a datos personales).

---

### `exportacion`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `usuario_id` | ObjectId (FK) | Quién solicitó la exportación. |
| `tipo` | String | `"pdf"` o `"excel"`. |
| `modulo` | String | De qué módulo se exportó (ej. `"fichas"`, `"instructores"`). |
| `filtros` | Object | Los parámetros de filtro usados (ej. `{sede_id, fecha_inicio, fecha_fin}`). Permite reproducir la exportación exacta. |
| `url_archivo` | String | URL temporal del archivo generado en el storage. |
| `estado` | String | `"generando"`, `"completado"`, `"error"`. Permite mostrar progreso al usuario. |
| `creado_en` | Date | Timestamp de la solicitud. |

**Por qué existe esta colección:** Auditoría de qué datos salieron del sistema. Requerido por Ley 1581 (saber qué datos personales fueron exportados, por quién y cuándo). También permite al administrador monitorear el uso de la funcionalidad de reportes.

---

## MÓDULO 2 — Estructura Institucional

---

### `regional`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `nombre` | String | Nombre oficial de la regional (ej. "Regional Huila"). |
| `codigo` | String | Código institucional SENA de la regional. Índice único. |
| `activo` | Boolean | Una regional puede ser desactivada sin eliminar su historial. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Primer nivel de la jerarquía institucional del SENA. Sin esta entidad no es posible generar reportes por regional ni filtrar la operación por zona geográfica. Normalización: si los datos de regional se embebieran en `centro_formacion`, se violaría 3FN porque el nombre de la regional no depende del ID del centro sino de un atributo externo.

---

### `centro_formacion`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `regional_id` | ObjectId (FK) | Referencia a la regional a la que pertenece. |
| `nombre` | String | Nombre oficial del centro. |
| `codigo` | String | Código institucional SENA del centro. |
| `activo` | Boolean | Desactivación lógica. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Segundo nivel de la jerarquía. Un centro puede tener varias sedes. Los instructores, ambientes y fichas pertenecen a un centro específico. La FK a `regional` permite agregar datos por nivel jerárquico superior.

---

### `sede`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `centro_id` | ObjectId (FK) | Referencia al centro de formación. |
| `nombre` | String | Nombre de la sede (ej. "Sede Norte"). |
| `ciudad` | String | Ciudad donde opera. |
| `direccion` | String | Dirección física. |
| `activo` | Boolean | Desactivación lógica. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Tercer nivel de la jerarquía. Es la entidad operativa: los ambientes existen en una sede, los instructores tienen una sede base, las fichas se ejecutan en una sede. Sin `sede` como entidad propia, no se puede programar horarios considerando la ubicación física.

---

## MÓDULO 3 — Catálogos Base

---

### `tipo_documento`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `codigo` | String | Código corto: `"CC"`, `"CE"`, `"TI"`, `"PA"`. |
| `nombre` | String | Nombre completo: "Cédula de Ciudadanía", "Cédula de Extranjería", etc. |

**Por qué existe esta colección:** En V6–V9 el tipo de documento era un String libre en `instructor`. Si el SENA agrega un nuevo tipo de documento (ej. permiso especial de permanencia), con catálogo se agrega un documento; sin catálogo se modifica el código. Además permite mostrar el nombre completo en la UI sin hardcodear textos.

---

### `tipo_contrato`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `nombre` | String | Ej: "Planta", "Contratista", "Hora-cátedra". |
| `descripcion` | String | Descripción de las implicaciones contractuales. |

**Por qué existe esta colección:** El tipo de contrato determina las reglas de asignación horaria (un contratista puede tener límite de horas semanales diferente al de planta). Al ser una entidad propia, el sistema puede aplicar reglas de negocio basadas en el tipo de contrato sin hardcodear lógica.

---

### `tipo_ambiente`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `nombre` | String | "Aula", "Laboratorio", "Taller", "Virtual", "Auditorio". |
| `descripcion` | String | Descripción del tipo de espacio. |

**Por qué existe esta colección:** En V9, el tipo de ambiente era un String libre en `room`. El SENA puede agregar nuevos tipos de ambiente (ej. "Ambiente Dual" para formación combinada presencial/empresa) sin despliegue de código.

---

### `nivel_formacion`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `nombre` | String | "Técnico", "Tecnólogo", "Auxiliar", "Especialización Tecnológica". |
| `descripcion` | String | Descripción del nivel según normativa SENA. |

**Por qué existe esta colección:** El nivel de formación determina la duración mínima del programa y los requisitos de entrada. Es un atributo de `programa_formacion` que puede cambiar por normativa del Ministerio de Educación sin requerir cambios en el código.

---

### `modalidad`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `nombre` | String | "Presencial", "Virtual", "A distancia", "Combinada". |
| `descripcion` | String | Descripción e implicaciones de la modalidad. |

**Por qué existe esta colección:** La modalidad afecta cómo se programan los bloques (una modalidad virtual no requiere ambiente físico). Al ser una entidad propia, el motor de horarios puede aplicar reglas distintas según la modalidad del programa.

---

### `jornada`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `nombre` | String | "Mañana", "Tarde", "Noche", "Fines de semana". |
| `hora_inicio` | String | Hora de inicio de la jornada (ej. "06:00"). |
| `hora_fin` | String | Hora de fin de la jornada (ej. "12:00"). |

**Por qué existe esta colección:** La jornada define el rango horario válido para programar bloques de una ficha. Una ficha de jornada nocturna no puede tener bloques programados en horario de mañana. El motor de validación usa `jornada.hora_inicio` y `jornada.hora_fin` para validar los bloques antes de persistirlos. Con String libre esto no es posible.

---

## MÓDULO 4 — Líneas y Redes

---

### `linea_formacion`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `nombre` | String | "Formación Titulada", "Formación Complementaria". |
| `descripcion` | String | Diferencias operativas entre líneas. |

**Por qué existe esta colección:** La línea de formación es el clasificador de más alto nivel del dominio académico. Determina las reglas de asignación de instructores: en titulada se requiere habilitación exacta por competencia y programa; en complementaria se requiere coincidencia de área de conocimiento. Sin esta entidad el motor de validación no puede aplicar la regla correcta.

---

### `area_conocimiento`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `nombre` | String | Ej: "Tecnología de la Información", "Salud", "Agroindustria". |
| `descripcion` | String | Descripción del área. |

**Por qué existe esta colección:** Es la entidad que permite la regla de formación complementaria: un instructor puede orientar un curso complementario si su área coincide con la del curso. Esta validación cruza `instructor_area.area_id` con `competencia.area_conocimiento_id`. Sin `area_conocimiento` como entidad propia esta consulta no es posible.

---

### `red_conocimiento`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `nombre` | String | Nombre de la red de conocimiento SENA. |
| `descripcion` | String | Descripción de la red. |

**Por qué existe esta colección:** El SENA organiza sus programas en Redes de Conocimiento (agrupaciones temáticas a nivel nacional). Esta entidad permite alinear la oferta local con la estructura nacional del SENA y generar reportes por red de conocimiento.

---

### `linea_red`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `linea_id` | ObjectId (FK) | Referencia a `linea_formacion`. |
| `red_id` | ObjectId (FK) | Referencia a `red_conocimiento`. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** La relación línea ↔ red de conocimiento es N:M. Una línea puede agrupar varias redes y una red puede pertenecer a varias líneas. Sin esta tabla pivote se necesitaría un array embebido que no es eficientemente indexable para consultas de intersección en MongoDB.

---

## MÓDULO 5 — Oferta y Programas

---

### `programa_formacion`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `linea_formacion_id` | ObjectId (FK) | Clasifica el programa en titulada o complementaria. Determina las reglas de validación del motor. |
| `nivel_formacion_id` | ObjectId (FK) | Técnico, tecnólogo, etc. FK a catálogo. |
| `modalidad_id` | ObjectId (FK) | Presencial, virtual, etc. FK a catálogo. |
| `codigo` | String | Código oficial SENA del programa. Índice único. |
| `nombre` | String | Nombre oficial del programa. |
| `duracion_horas` | Number | Duración total en horas. Necesario para calcular el avance de la ficha. |
| `activo` | Boolean | Un programa puede ser suspendido por el SENA sin eliminar las fichas históricas. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Es la entidad que cohesiona competencias, instructores y fichas. Sin ella no es posible validar si un instructor está habilitado para una competencia *en ese programa específico* (Problema 2 del audio) ni referenciar el catálogo de resultados sin duplicarlos (Problema 3 del audio).

---

### `vigencia_programa`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `programa_id` | ObjectId (FK) | Referencia al programa. |
| `fecha_inicio` | Date | Inicio de la vigencia. |
| `fecha_fin` | Date | Fin de la vigencia. |
| `estado` | String | "vigente", "suspendido", "en_restructuracion". |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Si el estado de vigencia se almacenara en `programa_formacion`, se perdería el historial. Un programa puede haber sido suspendido y reactivado varias veces. Con esta colección hay un registro de cada periodo de vigencia, lo cual es un requisito de trazabilidad institucional para auditorías del Ministerio de Educación.

---

## MÓDULO 6 — Programa Académico

---

### `competencia`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. Su existencia como ObjectId propio es lo que hace posible la validación del Problema 2. |
| `area_conocimiento_id` | ObjectId (FK) | Clasifica la competencia en un área. Necesario para la validación de formación complementaria. |
| `codigo` | String | Código oficial SENA de la competencia. |
| `nombre` | String | Nombre oficial. |
| `horas` | Number | Horas asignadas. Necesario para calcular carga horaria del instructor. |
| `activo` | Boolean | Desactivación lógica. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** En V6–V9 era el campo de texto libre `learning_activity` en `schedule_block`. Sin `_id` propio no se puede hacer la consulta de habilitación del instructor. Este es el cambio más crítico del modelo respecto a las versiones anteriores.

---

### `resultado_aprendizaje`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria del catálogo maestro. |
| `competencia_id` | ObjectId (FK) | El resultado pertenece a una competencia. |
| `codigo` | String | Código oficial. |
| `nombre` | String | Ej: "Inglés 1". Existe una sola vez. |
| `descripcion` | String | Descripción del resultado. |
| `activo` | Boolean | Desactivación lógica. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Catálogo maestro derivado del Problema 3 del audio. "Inglés 1" existía duplicado en cada programa. Con esta colección existe una sola vez y los programas lo referencian via `programa_resultado`. Cumple 3FN: el nombre y descripción dependen únicamente del `_id` del resultado, no del programa.

---

### `programa_competencia`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `programa_id` | ObjectId (FK) | Referencia al programa. |
| `competencia_id` | ObjectId (FK) | Referencia a la competencia. |
| `orden` | Number | Orden de la competencia en la malla académica. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Implementa la malla académica del programa (N:M). Sin esta colección no se puede saber qué competencias componen un programa, lo que hace imposible validar si el bloque horario que se está creando corresponde a una competencia del programa de la ficha.

---

### `programa_resultado`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `programa_id` | ObjectId (FK) | Referencia al programa. |
| `resultado_id` | ObjectId (FK) | Referencia al catálogo maestro. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Tabla pivote N:M que implementa la solución al Problema 3 del audio. Un programa referencia los resultados del catálogo maestro sin copiarlos. Múltiples programas pueden referenciar el mismo "Inglés 1" sin duplicar el documento.

---

### `ruta_formativa`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `programa_id` | ObjectId (FK) | Referencia al programa. |
| `nombre` | String | Nombre de la ruta. |
| `descripcion` | String | Descripción pedagógica. |
| `activo` | Boolean | Desactivación lógica. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Una ruta formativa agrupa competencias en una secuencia pedagógica específica dentro del programa. Aparece en el Módulo 6 de la imagen de la clase final como componente curricular del programa académico.

---

### `componente_curricular`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `competencia_id` | ObjectId (FK) | Competencia a la que pertenece. |
| `nombre` | String | Nombre del componente. |
| `tipo` | String | Tipo de componente: "teórico", "práctico", "proyecto". |
| `activo` | Boolean | Desactivación lógica. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Un componente curricular es la unidad mínima de contenido dentro de una competencia. Permite planificar el horario a nivel de componente, no solo de competencia. Requerido por el Módulo 6 de la imagen de la clase final.

---

## MÓDULO 7 — Instructores

---

### `instructor`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `sede_id` | ObjectId (FK) | Sede base del instructor. Necesario para filtrar instructores disponibles por sede. |
| `tipo_documento_id` | ObjectId (FK) | FK a catálogo. Normalización 3FN. |
| `tipo_contrato_id` | ObjectId (FK) | FK a catálogo. Permite aplicar reglas según tipo de contrato. |
| `numero_documento` | String (PII) | Documento de identidad. Marcado PII por Ley 1581. Índice único para evitar duplicados. |
| `primer_nombre` | String | Separado de apellido para normalización 1FN y búsquedas por apellido. |
| `primer_apellido` | String | Ídem. |
| `correo` | String (PII) | Correo institucional. PII por Ley 1581. |
| `telefono` | String (PII) | Teléfono de contacto. PII por Ley 1581. |
| `activo` | Boolean | Desactivación lógica sin perder historial de bloques. |
| `creado_en` / `actualizado_en` | Date | Auditoría estándar. |

**Por qué existe esta colección:** Entidad central del dominio. La separación de los datos personales en su propia colección permite aplicar cifrado selectivo a los campos PII sin afectar el rendimiento de las consultas de horarios.

---

### `instructor_area`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `instructor_id` | ObjectId (FK) | Referencia al instructor. |
| `area_id` | ObjectId (FK) | Referencia al área de conocimiento. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Implementa la regla de formación complementaria: un instructor puede orientar un curso complementario si tiene registrada el área de conocimiento correspondiente. Es una relación N:M porque un instructor puede tener múltiples áreas y un área puede tener múltiples instructores.

---

### `instructor_competencia`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `instructor_id` | ObjectId (FK) | Instructor habilitado. |
| `competencia_id` | ObjectId (FK) | Competencia para la que está habilitado. |
| `programa_id` | ObjectId (FK) | Programa específico en el que aplica la habilitación. La combinación de los tres campos es única. |
| `fecha_inicio` | Date | Desde cuándo está habilitado. Puede coincidir con el inicio del contrato. |
| `fecha_fin` | Date | Hasta cuándo. Null si la habilitación es indefinida. |
| `activo` | Boolean | Permite desactivar una habilitación sin eliminar el historial. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Es la colección más crítica del modelo. Implementa directamente la regla del Problema 2 del audio: la habilitación es específica para una combinación instructor + competencia + programa. La combinación única de los tres ObjectIds tiene un índice compuesto que garantiza que no puede existir más de un registro activo para la misma combinación.

---

## MÓDULO 8 — Ambientes

---

### `ambiente`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `sede_id` | ObjectId (FK) | El ambiente pertenece a una sede física. |
| `tipo_ambiente_id` | ObjectId (FK) | FK a catálogo. Permite filtrar ambientes por tipo al programar. |
| `codigo` | String | Código institucional del ambiente. Índice único por sede. |
| `nombre` | String | Nombre descriptivo. |
| `capacidad` | Number | Aforo máximo. El motor puede validar que el número de aprendices no supere la capacidad. |
| `activo` | Boolean | Desactivación lógica. Un ambiente en mantenimiento se desactiva sin perder historial. |
| `creado_en` / `actualizado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Entidad central del dominio. En V6–V9 existía como `room`. Se renombra a `ambiente` por ser el término oficial SENA. Se agrega `sede_id` para soportar multi-sede y `tipo_ambiente_id` para clasificación normalizada.

---

### `disponibilidad_ambiente`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `ambiente_id` | ObjectId (FK) | Referencia al ambiente. |
| `jornada_id` | ObjectId (FK) | Jornada para la que aplica la disponibilidad. |
| `fecha` | Date | Fecha específica. |
| `disponible` | Boolean | True si disponible, False si bloqueado por mantenimiento, reserva, etc. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** El Módulo 8 de la imagen especifica "disponibilidad real por franja horaria y sede". Un ambiente sin bloques programados no es lo mismo que un ambiente disponible. Esta colección registra bloqueos explícitos (mantenimiento, reservas institucionales, fallas técnicas) que el motor de horarios debe respetar al asignar ambientes.

---

## MÓDULO 9 — Fichas y Franjas Horarias

---

### `ficha`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `programa_id` | ObjectId (FK) | El programa al que pertenece la ficha. Necesario para validar competencias. |
| `sede_id` | ObjectId (FK) | Sede donde se ejecuta la ficha. |
| `jornada_id` | ObjectId (FK) | Jornada de la ficha. El motor valida que los bloques estén dentro de este rango. |
| `numero` | String | Número oficial de ficha SENA. Índice único. |
| `fecha_inicio` | Date | Fecha de inicio. |
| `fecha_fin` | Date | Fecha de fin original. |
| `fecha_fin_extendida` | Date | Fecha de fin después de una extensión formal. Null si no ha sido extendida. La regla es: si `fecha_fin < hoy` y este campo es null, la ficha está vencida y no acepta nuevos bloques. |
| `estado` | String | "en_ejecucion", "terminada", "cancelada". Constante en código. |
| `activo` | Boolean | Desactivación lógica. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** En V6–V9 existía como `training_group`. Se renombra a `ficha` por ser el término oficial SENA. El campo `fecha_fin_extendida` implementa directamente la regla del Problema 1 del audio.

---

### `bloque_horario`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `ficha_id` | ObjectId (FK) | La ficha a la que pertenece el bloque. El motor verifica vigencia de la ficha antes de crear el bloque. |
| `ambiente_id` | ObjectId (FK) | El ambiente asignado. El motor verifica disponibilidad. |
| `instructor_id` | ObjectId (FK) | El instructor asignado. El motor verifica que esté libre y habilitado. |
| `competencia_id` | ObjectId (FK) | La competencia que se orienta. **Campo nuevo vs V6–V9.** Permite la validación de habilitación del instructor. En V9 era texto libre `learning_activity`. |
| `resultado_id` | ObjectId (FK) | Resultado de aprendizaje específico. Opcional: no todos los bloques orientan un resultado específico. |
| `fecha` | Date | Fecha del bloque. |
| `hora_inicio` / `hora_fin` | String | Horario del bloque. El motor verifica que estén dentro de la jornada de la ficha. |
| `estado` | String | "programado", "cancelado", "ejecutado". Constante en código. |
| `creado_en` / `actualizado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Es el núcleo operativo del sistema. El cambio más importante respecto a V9 es la adición de `competencia_id`, que convierte lo que era texto libre no validable en una referencia que el motor puede usar para verificar la habilitación del instructor.

---

### `extension_ficha`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `ficha_id` | ObjectId (FK) | Ficha que fue extendida. |
| `fecha_fin_anterior` | Date | Fecha de fin antes de la extensión. Snapshot inmutable. |
| `fecha_fin_nueva` | Date | Nueva fecha de fin aprobada. |
| `motivo` | String | Justificación formal de la extensión. |
| `aprobado_por` | String | Nombre del coordinador que aprobó. |
| `creado_en` | Date | Timestamp de la extensión. Inmutable. |

**Por qué existe esta colección:** Implementa la solución al Problema 1 del audio. No es un campo editable en `ficha` porque se perdería el historial. Si una ficha se extiende tres veces, hay tres documentos aquí con la traza completa de cada extensión. Documento inmutable: una vez creado no se modifica.

---

## MÓDULO 10 — Aprendices

---

### `aprendiz`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `tipo_documento_id` | ObjectId (FK) | FK a catálogo. |
| `numero_documento` | String (PII) | Documento de identidad. PII por Ley 1581. Índice único. |
| `primer_nombre` | String | 1FN: separado del apellido. |
| `primer_apellido` | String | 1FN. |
| `correo` | String (PII) | Correo institucional SENA. PII. |
| `activo` | Boolean | Desactivación lógica. |
| `creado_en` / `actualizado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Una ficha sin aprendices no tiene sentido institucional. Esta colección permite generar listas de asistentes, detectar conflictos de matrícula (aprendiz en dos fichas simultáneas) y cumplir con reportes institucionales que requieren información del grupo.

---

### `ficha_aprendiz`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `ficha_id` | ObjectId (FK) | Referencia a la ficha. |
| `aprendiz_id` | ObjectId (FK) | Referencia al aprendiz. |
| `fecha_matricula` | Date | Fecha de matrícula oficial. |
| `estado` | String | "activo", "retirado", "trasladado". |

**Por qué existe esta colección:** La relación ficha ↔ aprendiz es N:M. Un aprendiz puede estar en varias fichas (traslado de programa) y una ficha tiene muchos aprendices. Los atributos `fecha_matricula` y `estado` pertenecen a la relación, no a ninguna de las dos entidades, lo que justifica la tabla pivote.

---

### `historial_aprendiz`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `aprendiz_id` | ObjectId (FK) | Referencia al aprendiz. |
| `evento` | String | Tipo de evento: "matricula", "retiro", "traslado", "reintegro". |
| `descripcion` | String | Descripción detallada del evento. |
| `fecha` | Date | Fecha del evento. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** El Módulo 10 especifica "historial básico". Los cambios de estado de un aprendiz (retiro, traslado, reintegro) son eventos con fecha que deben preservarse. Si se almacenaran solo en `ficha_aprendiz.estado`, se perdería el historial de los estados anteriores.

---

## MÓDULO 11 — Motor de Horarios

---

### `conflicto_horario`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `bloque_a_id` | ObjectId (FK) | Primer bloque en conflicto. |
| `bloque_b_id` | ObjectId (FK) | Segundo bloque en conflicto. |
| `tipo` | String | "instructor_duplicado", "ambiente_ocupado", "ficha_solapada". |
| `descripcion` | String | Descripción del conflicto. |
| `resuelto` | Boolean | Estado de resolución. |
| `creado_en` | Date | Timestamp de detección. |

**Por qué existe esta colección:** Cuando el motor detecta un cruce, no es suficiente rechazar la operación. El coordinador necesita ver el historial de conflictos detectados para entender patrones y mejorar la planificación. Esta colección es el registro de auditoría del motor de validación.

---

## MÓDULO 12 — Observaciones e Incidencias

---

### `observacion`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `bloque_id` | ObjectId (FK) | Bloque al que pertenece la observación. |
| `instructor_id` | ObjectId (FK) | Instructor que hace la observación (opcional). |
| `autor` | String (PII) | Nombre del autor. PII porque puede ser un coordinador sin cuenta en el sistema. |
| `texto` | String | Contenido de la observación. |
| `severidad` | String | "info", "advertencia", "critica". Constante en código. |
| `creado_en` | Date | Inmutable. Una observación no se edita. |

**Por qué existe esta colección:** Existía en V6–V9 como `observation`. Se mantiene con el mismo propósito: registrar notas sobre bloques ejecutados. Es inmutable: una observación no se edita ni se elimina, solo se agrega.

---

### `incidencia`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `bloque_id` | ObjectId (FK) | Bloque relacionado con la incidencia. |
| `usuario_id` | ObjectId (FK) | Usuario que registra la incidencia. |
| `tipo` | String | "conflicto", "bloqueo", "reprogramacion", "cancelacion". |
| `descripcion` | String | Detalle de la incidencia. |
| `estado` | String | "abierta", "en_proceso", "resuelta". |
| `creado_en` / `actualizado_en` | Date | Auditoría. |

**Por qué existe esta colección separada de `observacion`:** Una observación es informativa e inmutable. Una incidencia requiere seguimiento y tiene ciclo de vida (estado que cambia). Mezclar ambos conceptos en una colección haría necesario manejar lógica condicional en el código según el tipo de registro, violando el principio de responsabilidad única.

---

## MÓDULO 13 — Proyectos Formativos

---

### `proyecto_formativo`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `ficha_id` | ObjectId (FK) | La ficha cuyo grupo desarrolla el proyecto. |
| `instructor_id` | ObjectId (FK) | Instructor tutor del proyecto. |
| `titulo` | String | Título del proyecto. |
| `descripcion` | String | Descripción del proyecto. |
| `estado` | String | "formulacion", "ejecucion", "evaluacion", "aprobado". |
| `fecha_inicio` / `fecha_fin` | Date | Rango de ejecución. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Requisito de grado obligatorio en programas técnicos y tecnólogos del SENA. Sin este módulo el sistema no puede dar seguimiento a este componente académico crítico.

---

### `hito_proyecto`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `proyecto_id` | ObjectId (FK) | Proyecto al que pertenece el hito. |
| `nombre` | String | Nombre del hito/entregable. |
| `fecha_limite` | Date | Fecha de entrega. |
| `cumplido` | Boolean | Estado de cumplimiento. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Un proyecto tiene múltiples entregables con fechas límite distintas. Si los hitos se embebieran en `proyecto_formativo` como array, no serían consultables individualmente para reportes de seguimiento ni para alertas de vencimiento.

---

### `revision_proyecto`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `proyecto_id` | ObjectId (FK) | Proyecto revisado. |
| `instructor_id` | ObjectId (FK) | Instructor que revisa. |
| `comentario` | String | Retroalimentación del instructor. |
| `calificacion` | Number | Calificación numérica. |
| `estado` | String | "pendiente", "aprobado", "rechazado". |
| `creado_en` | Date | Inmutable. |

**Por qué existe esta colección:** Un proyecto puede tener múltiples revisiones antes de ser aprobado. El historial de revisiones con comentarios y calificaciones es un requisito de trazabilidad académica. Si se almacenara solo la última revisión en `proyecto_formativo`, se perdería el historial de correcciones.

---

## MÓDULO 14 — Coordinación y Evaluación

---

### `asignacion_coordinacion`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `usuario_id` | ObjectId (FK) | Coordinador que hace la asignación. |
| `ambiente_id` | ObjectId (FK) | Ambiente reservado. |
| `fecha` | Date | Fecha de la asignación. |
| `hora_inicio` / `hora_fin` | String | Franja horaria. |
| `proposito` | String | Descripción del propósito de la asignación. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Permite a la coordinación reservar ambientes para revisiones y evaluaciones sin interferir con los bloques de clase. Al ser una colección separada, el motor de horarios la consulta junto con `bloque_horario` para determinar si un ambiente está disponible, sin mezclar lógicas de negocio distintas.

---

### `evaluacion_espacio`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `asignacion_id` | ObjectId (FK) | Asignación que se evalúa. |
| `usuario_id` | ObjectId (FK) | Usuario que evalúa. |
| `calificacion` | Number | Calificación del espacio. |
| `observacion` | String | Comentarios. |
| `aprobado` | Boolean | Resultado de la evaluación. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Permite calificar el uso del espacio en cada asignación de coordinación. Genera datos para mejorar la gestión de ambientes basada en evaluaciones reales de uso.

---

## MÓDULO 15 — Notificaciones y Trazabilidad

---

### `notificacion`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `usuario_id` | ObjectId (FK) | Usuario destinatario. |
| `tipo` | String | Tipo de notificación: "conflicto", "extension", "cancelacion", "revision". |
| `titulo` | String | Título corto para mostrar en la UI. |
| `mensaje` | String | Contenido completo de la notificación. |
| `leido` | Boolean | Estado de lectura. |
| `creado_en` | Date | Timestamp de creación. |
| `leido_en` | Date | Timestamp de cuando fue leída. Null si no ha sido leída. |

**Por qué existe esta colección:** Sin notificaciones los actores del sistema deben consultar activamente para enterarse de cambios. Con esta colección el sistema puede empujar alertas a coordinadores e instructores cuando ocurren eventos relevantes (conflicto detectado, ficha próxima a vencer, proyecto pendiente de revisión).

---

## MÓDULO 16 — Reportes y Exportaciones *(propuesto)*

---

### `reporte_configuracion`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `nombre` | String | Nombre del reporte (ej. "Horario semanal por ficha"). |
| `tipo` | String | "pdf" o "excel". |
| `modulo` | String | Módulo del que extrae datos. |
| `activo` | Boolean | Permite desactivar reportes sin eliminarlos. |
| `creado_en` | Date | Auditoría. |

**Por qué existe esta colección:** Define las plantillas de reporte disponibles en el sistema. Siguiendo el principio Open/Closed, un administrador puede agregar nuevas plantillas sin modificar el código. Es la diferencia entre un sistema configurable y uno hardcodeado.

---

## MÓDULO 17 — Asistente IA con Contexto *(propuesto)*

---

### `fragmento_documento`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `nombre_archivo` | String | Nombre del archivo MD del que proviene. |
| `texto` | String | Contenido del fragmento (500-1000 tokens). |
| `vector_id` | String | ID del vector en el servicio externo (Qdrant). Los vectores de 1536 dimensiones no se almacenan en MongoDB por limitaciones de búsqueda semántica. |
| `modulo_referencia` | String | A qué módulo del sistema pertenece el contenido. |
| `activo` | Boolean | Permite desactivar fragmentos obsoletos sin eliminarlos. |
| `creado_en` | Date | Timestamp de indexación. |

**Por qué existe esta colección:** Almacena la metadata de los fragmentos indexados para el patrón RAG. La separación entre metadata (MongoDB) y vectores (servicio externo) es una decisión de arquitectura: MongoDB gestiona quién, qué y de dónde; el servicio de vectores gestiona la búsqueda semántica eficiente.

---

### `consulta_ia`

| Campo | Tipo | Justificación |
|---|---|---|
| `_id` | ObjectId | Clave primaria. |
| `usuario_id` | ObjectId (FK) | Usuario que hizo la consulta. |
| `pregunta` | String | Pregunta original del usuario. |
| `respuesta` | String | Respuesta generada por el modelo. |
| `fragmentos_usados` | Array | IDs de los fragmentos que se usaron para construir el contexto. |
| `modelo` | String | Nombre del modelo de IA usado. |
| `tokens_usados` | Number | Tokens consumidos. Para control de costos. |
| `creado_en` | Date | Timestamp de la consulta. |

**Por qué existe esta colección:** Historial de uso del asistente IA. Permite auditar qué preguntas se hacen frecuentemente (para mejorar la documentación), controlar costos de API, y detectar consultas que el sistema no puede responder correctamente (para mejorar la indexación).

---

## Resumen estadístico

| Módulo | Colecciones | Campos PII | Pivotes N:M |
|---|---|---|---|
| 1. Seguridad y Acceso | 5 | 1 | 1 |
| 2. Estructura Institucional | 3 | 0 | 0 |
| 3. Catálogos Base | 6 | 0 | 0 |
| 4. Líneas y Redes | 4 | 0 | 1 |
| 5. Oferta y Programas | 2 | 0 | 0 |
| 6. Programa Académico | 6 | 0 | 2 |
| 7. Instructores | 3 | 3 | 2 |
| 8. Ambientes | 2 | 0 | 0 |
| 9. Fichas y Franjas | 3 | 0 | 0 |
| 10. Aprendices | 3 | 2 | 1 |
| 11. Motor de Horarios | 1 | 0 | 0 |
| 12. Observaciones e Incidencias | 2 | 1 | 0 |
| 13. Proyectos Formativos | 3 | 0 | 0 |
| 14. Coordinación y Evaluación | 2 | 0 | 0 |
| 15. Notificaciones y Trazabilidad | 1 | 0 | 0 |
| 16. Reportes *(propuesto)* | 1 | 0 | 0 |
| 17. Asistente IA *(propuesto)* | 2 | 0 | 0 |
| **Total** | **48** | **7** | **7** |
