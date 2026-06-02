# Justificación Técnica — 17 Módulos del Sistema de Horarios SENA

> Proyecto: SENA Schedule Manager  
> Versión: 10.0  
> Basado en: V6–V9 + Requisitos de reunión (audio) + Dominio real SENA  
> Base de datos: MongoDB  
> Stack: Go · React · Docker

---

## Módulo 1 — Seguridad y Acceso

**Colecciones:** `usuario`, `rol`, `usuario_rol`, `log_auditoria`, `exportacion`

### Justificación técnica

Este módulo es la base transversal de todo el sistema. Su existencia se justifica desde tres fuentes simultáneas:

**Desde el Threat Model (V8/V9 — STRIDE):**
El análisis de amenazas identificó que sin autenticación cualquier actor puede invocar cualquier endpoint. La amenaza clasificada como *Spoofing* en STRIDE establece que un sistema sin identidad verificada no puede confiar en ninguna operación. La colección `usuario` implementa la identidad; `rol` y `usuario_rol` implementan el control de acceso basado en roles (RBAC), resolviendo la amenaza de *Elevation of Privilege*.

**Desde el requisito de trazabilidad (S-06):**
El threat model detectó que sin registro de operaciones no hay forma de rastrear quién creó, modificó o canceló un bloque horario o una ficha. La colección `log_auditoria` implementa un registro inmutable de cada operación de escritura, resolviendo la amenaza de *Repudiation* en STRIDE.

**Desde la Ley 1581 de Colombia:**
La ley de protección de datos personales exige que el sistema pueda identificar qué operador procesó datos personales y cuándo. `log_auditoria` vinculado a `usuario` permite cumplir este requisito legal.

**Desde el requisito de exportaciones:**
La colección `exportacion` registra cada PDF o Excel generado, quién lo solicitó, con qué filtros y cuál fue el resultado. Sin este registro no hay trazabilidad sobre qué datos fueron extraídos del sistema.

---

## Módulo 2 — Estructura Institucional

**Colecciones:** `regional`, `centro_formacion`, `sede`

### Justificación técnica

**Desde el dominio real del SENA:**
El SENA opera bajo una estructura jerárquica definida institucionalmente: el país se divide en **Regionales**, cada regional contiene uno o varios **Centros de Formación**, y cada centro puede tener múltiples **Sedes** físicas. Esta jerarquía no es opcional ni puede simplificarse a una sola entidad, porque:

- Un instructor pertenece a una sede base específica.
- Una ficha se ejecuta en una sede específica.
- Un ambiente existe dentro de una sede.
- Los reportes y la gestión operativa se hacen por centro y por regional.

**Desde la normalización:**
Si la información de regional, centro y sede se colapsara en una sola colección o se embebiera en `instructor` o `ficha`, se violaría la Primera Forma Normal (1FN) al tener grupos repetitivos, y la Tercera Forma Normal (3FN) al tener dependencias transitivas entre atributos no clave.

**Desde la escalabilidad:**
El sistema debe poder operar en múltiples sedes simultáneamente sin colisión de datos. La estructura jerárquica en tres colecciones permite filtrar y reportar por cualquier nivel de la jerarquía institucional.

---

## Módulo 3 — Catálogos Base

**Colecciones:** `tipo_documento`, `tipo_contrato`, `tipo_ambiente`, `nivel_formacion`, `modalidad`, `jornada`

### Justificación técnica

**Desde la normalización (3FN):**
En las versiones V6 a V9, los valores de tipo de documento, tipo de contrato, tipo de ambiente, nivel de formación, modalidad y jornada se almacenaban como campos `String` libres en las colecciones que los usaban. Esto viola la Tercera Forma Normal porque estos valores son entidades con identidad propia, no atributos derivados.

Ejemplo del problema: si `instructor.tipo_contrato = "contratista"` y se decide renombrar ese valor a `"contratación por prestación de servicios"`, hay que actualizar miles de documentos. Con catálogos, se actualiza un solo documento.

**Desde la validación de datos:**
MongoDB no tiene ENUM nativo. Los catálogos como colecciones propias permiten validar en el backend que el valor referenciado existe antes de persistir cualquier documento. Esto reemplaza los ENUMs de bases de datos relacionales con el mismo efecto de integridad.

**Decisión de diseño — por qué colecciones y no constantes en código:**
Los valores de `tipo_ambiente`, `modalidad` y `jornada` pueden crecer (el SENA puede agregar nuevos tipos de ambiente o nuevas jornadas) sin requerir un despliegue de código. Con colecciones, un administrador agrega el nuevo valor desde la interfaz. Con constantes en código, se requiere una nueva versión del software.

Los valores de `severidad_observacion`, `estado_bloque` y `estado_ficha` **sí** son constantes en código porque son invariantes del dominio: siempre habrá exactamente tres severidades y no hay razón de negocio para que cambien.

---

## Módulo 4 — Líneas y Redes

**Colecciones:** `linea_formacion`, `area_conocimiento`, `red_conocimiento`, `linea_red`

### Justificación técnica

**Desde el dominio real del SENA:**
El SENA organiza su oferta académica en dos grandes **líneas de formación**: *Formación Titulada* (programas técnicos y tecnólogos con ficha oficial) y *Formación Complementaria* (cursos cortos abiertos). Esta distinción es estructuralmente crítica porque determina las reglas de asignación de instructores.

**Desde el requisito de la reunión (audio):**
El instructor mencionó explícitamente que un instructor técnico de formación titulada puede dar clases en cursos complementarios si su **área de conocimiento** lo cubre. Sin modelar el área de conocimiento como entidad propia vinculada tanto a competencias como a instructores, esta regla no puede validarse en código.

**Desde la normalización:**
La relación entre líneas de formación y redes de conocimiento es N:M (una línea puede tener varias redes, una red puede pertenecer a varias líneas). La colección pivote `linea_red` normaliza esta relación. Sin ella, se necesitaría un array embebido que no es indexable eficientemente en MongoDB para consultas de intersección.

**Justificación de `area_conocimiento`:**
Es la entidad que permite al motor de validación responder la pregunta: "¿Puede este instructor orientar este curso complementario?" La respuesta es sí si existe un registro en `instructor_area` con el área que corresponde a la competencia del curso. Sin esta entidad, la validación es imposible.

---

## Módulo 5 — Oferta y Programas

**Colecciones:** `programa_formacion`, `vigencia_programa`

### Justificación técnica

**Desde el requisito del audio (Problemas 2 y 3):**
El programa de formación es la entidad que cohesiona todo el dominio académico. Sin ella no es posible:
- Validar si un instructor está habilitado para orientar una competencia **en ese programa específico** (Problema 2).
- Referenciar el catálogo maestro de resultados de aprendizaje desde múltiples programas (Problema 3).

**Desde el dominio real del SENA:**
Un programa tiene un código oficial SENA, una duración en horas, un nivel de formación y una modalidad. Estos atributos no pertenecen a la ficha (que es una ejecución del programa) sino al programa en sí. La ficha puede cambiar de sede, de jornada o de fechas, pero el programa siempre tiene el mismo código y la misma estructura curricular.

**Justificación de `vigencia_programa`:**
Un programa de formación puede estar vigente, suspendido o en restructuración. Estas vigencias cambian en el tiempo y tienen fechas de inicio y fin. Almacenar el estado de vigencia directamente en `programa_formacion` no preserva el historial. Con `vigencia_programa` se puede auditar cuándo un programa estuvo vigente y cuándo fue suspendido, lo cual es un requisito de trazabilidad institucional.

---

## Módulo 6 — Programa Académico

**Colecciones:** `competencia`, `resultado_aprendizaje`, `programa_competencia`, `programa_resultado`, `ruta_formativa`, `componente_curricular`

### Justificación técnica

**Desde el Problema 2 del audio:**
En el modelo anterior (V6–V9), la competencia se almacenaba como texto libre en el campo `learning_activity` de `schedule_block`. Este diseño hace imposible validar si el instructor está habilitado para orientar esa competencia. Al crear `competencia` como colección propia con `_id`, el motor de validación puede hacer la consulta: `instructor_competencia.find({instructor_id, competencia_id, programa_id})`.

**Desde el Problema 3 del audio:**
`resultado_aprendizaje` es el catálogo maestro. "Inglés 1" existe una sola vez con su propio `_id`. La colección `programa_resultado` es la tabla pivote N:M que permite que múltiples programas referencien el mismo resultado sin duplicarlo. Antes de este diseño, Multimedia tenía su "Inglés 1" y Electrónica tenía el suyo, sin correlación.

**Justificación de `programa_competencia`:**
Esta es la implementación de la **malla académica** del programa. Establece qué competencias componen el plan de estudios y en qué orden. Sin esta colección, no se puede validar si una competencia pertenece al programa de la ficha que se está programando.

**Justificación de `ruta_formativa` y `componente_curricular`:**
Estos fueron identificados en la imagen de los módulos del sistema (clase final) como parte del Módulo 6. Una ruta formativa agrupa competencias en una secuencia pedagógica. Un componente curricular es la unidad mínima de contenido dentro de una competencia. Su ausencia haría el modelo incompleto para la sustentación.

---

## Módulo 7 — Instructores

**Colecciones:** `instructor`, `instructor_area`, `instructor_competencia`

### Justificación técnica

**Desde el Problema 2 del audio:**
La colección `instructor_competencia` es la más crítica del modelo. Implementa la regla de negocio: "Un instructor solo puede ser asignado si existe un registro que lo vincule a esa competencia dentro de ese programa de formación específico." Tiene tres claves foráneas (`instructor_id`, `competencia_id`, `programa_id`) y un índice único sobre esa combinación para evitar habilitaciones duplicadas. Tiene además `fecha_inicio` y `fecha_fin` porque la habilitación puede ser temporal (contratos).

**Desde la línea de formación:**
La colección `instructor_area` implementa la regla que surgió del análisis de líneas de formación: un instructor puede orientar cursos complementarios si su área de conocimiento coincide con la del curso. Esta colección es la que permite hacer esa validación cruzando `instructor_area.area_id` con `competencia.area_conocimiento_id`.

**Desde la Ley 1581 (PII):**
Los campos `numero_documento`, `correo` y `telefono` están marcados como PII. El threat model V8/V9 establece que estos campos deben tener tratamiento especial de cifrado en reposo. La separación del instructor en su propia colección con campos claramente marcados facilita aplicar políticas de cifrado selectivo en el repositorio de MongoDB.

**Desde la normalización (1FN):**
Los nombres se separan en `primer_nombre`, `segundo_nombre`, `primer_apellido`, `segundo_apellido` para cumplir 1FN. Almacenar el nombre completo como un solo String libre impide búsquedas y ordenamientos correctos por apellido.

---

## Módulo 8 — Ambientes

**Colecciones:** `ambiente`, `disponibilidad_ambiente`

### Justificación técnica

**Desde el modelo original (V6–V9):**
La colección `room` existía en todas las versiones. Se renombra a `ambiente` porque ese es el término oficial del SENA para los espacios físicos y virtuales de formación.

**Desde el Módulo 8 de la imagen (clase final):**
El módulo especifica "disponibilidad real por franja horaria y sede". Esto requiere una colección separada `disponibilidad_ambiente` que registre, para cada ambiente y cada jornada, si está disponible en una fecha específica. Sin esta colección, el sistema no puede distinguir entre un ambiente que simplemente no tiene bloques programados y un ambiente que fue marcado como no disponible por mantenimiento, reserva especial o falla técnica.

**Desde la detección de conflictos:**
El motor de horarios necesita consultar disponibilidad de ambientes antes de crear un bloque. La estructura de `disponibilidad_ambiente` con índices compuestos en `(ambiente_id, fecha, jornada_id)` permite esta consulta en O(log n) en lugar de escanear todos los bloques existentes.

---

## Módulo 9 — Fichas y Franjas Horarias

**Colecciones:** `ficha`, `bloque_horario`, `extension_ficha`

### Justificación técnica

**Desde el Problema 1 del audio:**
La colección `ficha` agrega el campo `fecha_fin_extendida`. La regla de negocio establece: una ficha con `fecha_fin` vencida no puede recibir nuevos bloques horarios, a menos que exista una extensión formal registrada. El motor de validación verifica: `if (fecha_fin < hoy && !fecha_fin_extendida) → bloquear`. La extensión no es un campo editable libremente; es el resultado de un proceso formal que crea un documento en `extension_ficha`.

**Justificación de `extension_ficha` como colección separada:**
Si la extensión se almacenara como un campo en `ficha`, se perdería el historial. Si una ficha se extiende tres veces, hay que saber cuándo fue cada extensión, cuál fue la fecha anterior, cuál la nueva, y quién la aprobó. Esto es un requisito de auditoría institucional. Cada extensión es un documento inmutable en `extension_ficha`.

**Desde el diseño de `bloque_horario`:**
Se agrega `competencia_id` que en V6–V9 era el campo de texto libre `learning_activity`. Este cambio es lo que hace posible la validación del Problema 2: el motor puede cruzar `bloque_horario.competencia_id` con `instructor_competencia` para verificar la habilitación antes de persistir el bloque.

---

## Módulo 10 — Aprendices

**Colecciones:** `aprendiz`, `ficha_aprendiz`, `historial_aprendiz`

### Justificación técnica

**Desde la integridad del dominio:**
En el SENA una ficha sin aprendices no tiene razón de existir. Si no se modela al aprendiz, el sistema describe un horario sin saber para quién es. Esto hace los reportes incompletos e impide detectar un tipo adicional de conflicto: un aprendiz matriculado en dos fichas activas con bloques simultáneos.

**Desde el Módulo 10 de la imagen (clase final):**
El módulo especifica "matrícula en fichas, historial básico y relación con la programación". Estos tres elementos requieren tres colecciones: `aprendiz` (perfil), `ficha_aprendiz` (matrícula N:M), `historial_aprendiz` (trazabilidad de eventos como retiro, traslado, reintegro).

**Desde las exportaciones:**
Un reporte de horario sin la lista de aprendices de la ficha es un reporte incompleto. La colección `ficha_aprendiz` es la que permite generar el listado completo de asistentes para cualquier bloque horario.

**Desde la Ley 1581 (PII):**
`numero_documento` y `correo` del aprendiz son datos personales sensibles. Al tener al aprendiz en su propia colección, se puede aplicar cifrado selectivo a esos campos sin afectar el rendimiento de las consultas de horarios.

---

## Módulo 11 — Motor de Horarios

**Colecciones:** `conflicto_horario` (comparte `bloque_horario` con Módulo 9)

### Justificación técnica

**Desde el objetivo principal del sistema:**
El motor de horarios es el núcleo funcional del proyecto. Su KPI principal en el PRD es reducir de 4 horas a menos de 30 minutos el tiempo de creación de un horario semanal. Esto se logra automatizando la detección de cruces.

**Justificación de `conflicto_horario`:**
Cuando el motor detecta un cruce (instructor asignado a dos lugares al mismo tiempo, ambiente ocupado, ficha con dos bloques simultáneos), este conflicto debe quedar registrado. No es suficiente rechazar la operación y ya. El coordinador necesita ver el historial de conflictos detectados, cuáles fueron resueltos y cómo. `conflicto_horario` almacena los dos bloques en colisión (`bloque_a_id`, `bloque_b_id`), el tipo de conflicto y si fue resuelto.

**Las cuatro validaciones del motor (MotorValidacion):**
1. Instructor libre en esa franja horaria.
2. Ambiente libre en esa franja horaria.
3. Ficha sin bloque simultáneo.
4. **Ficha vigente** (nueva — Problema 1 del audio).
5. **Instructor habilitado** para esa competencia en ese programa (nueva — Problema 2 del audio).

---

## Módulo 12 — Observaciones e Incidencias

**Colecciones:** `observacion`, `incidencia`

### Justificación técnica

**Desde el modelo original (V6–V9):**
La colección `observation` existía en todas las versiones. Se renombra a `observacion` por consistencia en español.

**Justificación de separar `observacion` de `incidencia`:**
Son entidades conceptualmente distintas. Una **observación** es una nota informativa sobre un bloque (ej. "el instructor llegó tarde", "el ambiente tenía falla técnica"). Una **incidencia** es un evento que requiere seguimiento y resolución (ej. "bloqueo por conflicto de horario", "reprogramación solicitada por coordinador", "ambiente inhabilitado"). Las incidencias tienen estado (abierta, en proceso, resuelta) y actor responsable. Las observaciones son inmutables una vez creadas.

**Desde el Módulo 12 de la imagen (clase final):**
El módulo especifica "conflictos, bloqueos, reprogramaciones y seguimiento de situaciones especiales". Este nivel de detalle requiere la colección `incidencia` con campos de tipo, estado y actor, que la colección `observacion` sola no puede soportar.

---

## Módulo 13 — Proyectos Formativos

**Colecciones:** `proyecto_formativo`, `hito_proyecto`, `revision_proyecto`

### Justificación técnica

**Desde el Módulo 13 de la imagen (clase final):**
Este módulo no existía en ninguna versión anterior (V6–V9). La imagen lo describe como "gestión de proyectos formativos de técnicos y tecnólogos, trazabilidad, hitos, revisión y posible enfoque de investigación". Apareció en la clase final como un módulo a agregar.

**Desde el dominio SENA:**
Los programas técnicos y tecnólogos del SENA tienen como requisito de grado la presentación de un **Proyecto Formativo** (también llamado Proyecto de Aprendizaje por Resultados). Este proyecto tiene fases, entregables e instructores revisores. Sin este módulo, el sistema no puede registrar ni hacer seguimiento de este componente académico obligatorio.

**Justificación de las tres colecciones:**
- `proyecto_formativo`: el proyecto como unidad principal con título, descripción, estado y fechas.
- `hito_proyecto`: los entregables o fases con fecha límite y estado de cumplimiento.
- `revision_proyecto`: el registro de cada revisión hecha por un instructor con comentario, calificación y estado de aprobación.

Esta estructura en tres colecciones permite trazabilidad completa desde la creación del proyecto hasta su aprobación final.

---

## Módulo 14 — Coordinación y Evaluación

**Colecciones:** `asignacion_coordinacion`, `evaluacion_espacio`

### Justificación técnica

**Desde el Módulo 14 de la imagen (clase final):**
Este módulo tampoco existía en V6–V9. La imagen lo describe como "permite que coordinación asigne horas o espacios para revisar y calificar proyectos sin afectar otros espacios académicos".

**El problema que resuelve:**
Cuando un coordinador necesita un ambiente para hacer revisiones de proyectos formativos o evaluaciones especiales, debe reservarlo sin interferir con los bloques de clase regulares. El motor de horarios no puede distinguir entre un bloque de clase y una asignación de coordinación si ambos usan la misma colección. `asignacion_coordinacion` es una colección separada que el motor consulta antes de asignar cualquier ambiente.

**Justificación de `evaluacion_espacio`:**
Cada asignación de coordinación genera una evaluación del espacio utilizado. Esta evaluación incluye calificación, observaciones y estado de aprobación. Es un registro de auditoría que permite mejorar la gestión de ambientes con base en el uso real.

---

## Módulo 15 — Notificaciones y Trazabilidad

**Colecciones:** `notificacion` (comparte `log_auditoria` con Módulo 1)

### Justificación técnica

**Desde el Módulo 15 de la imagen (clase final):**
El módulo especifica "comunica eventos relevantes y conserva historial de cambios, revisiones y decisiones del sistema".

**Justificación de `notificacion`:**
Los actores del sistema (coordinadores, instructores) necesitan ser notificados cuando ocurren eventos relevantes: un bloque fue cancelado, una ficha fue extendida, un conflicto fue detectado, una revisión de proyecto fue completada. Sin notificaciones, los actores deben consultar activamente el sistema para enterarse de cambios. Con `notificacion`, el sistema empuja la información a los actores correspondientes.

**Relación con `log_auditoria`:**
`log_auditoria` (Módulo 1) registra qué cambió, quién lo cambió y cuándo. `notificacion` comunica ese evento al actor afectado. Son complementarios: la auditoría es para el sistema y los administradores; la notificación es para el usuario final.

---

## Módulo 16 — Reportes y Exportaciones *(propuesto)*

**Colecciones:** `reporte_configuracion` (comparte `exportacion` con Módulo 1)

### Justificación técnica

**Por qué se propone como módulo independiente:**
Los 15 módulos originales no tienen ninguno dedicado a reportes y estadísticas. Sin embargo, el KPI central del PRD es "reducir de 4 horas a 30 minutos la creación de horarios". Sin reportes no se puede medir ese KPI. Un sistema de gestión institucional sin capacidad de exportación de reportes no cumple los requisitos de entrega a coordinadores y directivos del SENA.

**Justificación de `reporte_configuracion`:**
Esta colección almacena las plantillas de reportes disponibles en el sistema: qué módulo reporta, qué tipo de salida genera (PDF o Excel), qué campos incluye. Permite que un administrador configure nuevos reportes sin necesidad de modificar el código. Esto sigue el principio Open/Closed de SOLID: abierto para extensión, cerrado para modificación.

**Relación con `exportacion` (Módulo 1):**
`exportacion` registra cada instancia de exportación (quién, cuándo, qué filtros, qué URL de archivo). `reporte_configuracion` define las plantillas disponibles. La separación permite auditar no solo qué se exportó sino también qué configuración de reporte se usó.

---

## Módulo 17 — Asistente IA con Contexto *(propuesto)*

**Colecciones:** `fragmento_documento`, `consulta_ia`

### Justificación técnica

**Desde el requisito del instructor (clase):**
El instructor mencionó explícitamente la necesidad de "un espacio para la IA que no le envíe todo el repositorio sino que tenga contexto". Este es el patrón de ingeniería conocido como **RAG (Retrieval-Augmented Generation)**.

**El problema técnico que resuelve:**
Un modelo de IA tiene un límite de tokens en su ventana de contexto. Si se envía todo el repositorio de documentación (30+ archivos MD), el modelo se satura, da respuestas genéricas o se corta. El patrón RAG divide los documentos en fragmentos pequeños, los indexa semánticamente, y cuando se hace una pregunta recupera solo los fragmentos más relevantes para construir el prompt.

**Justificación de `fragmento_documento`:**
Almacena la metadata de cada fragmento: de qué archivo proviene, el texto del fragmento y el `vector_id` que apunta al vector en el servicio externo de búsqueda semántica (Qdrant o similar). Los vectores numéricos no se almacenan en MongoDB porque MongoDB no tiene búsqueda semántica eficiente sobre arrays de 1536 dimensiones. MongoDB gestiona la metadata; el servicio de vectores gestiona la búsqueda semántica.

**Justificación de `consulta_ia`:**
Almacena el historial de preguntas y respuestas del asistente, los fragmentos que se usaron para responder y los tokens consumidos. Esto permite auditar el uso del módulo, detectar preguntas frecuentes para mejorar la documentación, y controlar costos de API.

**Por qué va en MongoDB y no solo en el servicio externo:**
Los fragmentos tienen metadata (a qué módulo pertenecen, si están activos, cuándo se indexaron) que necesita ser consultable desde el backend Go. El historial de consultas es parte del log de auditoría del sistema. Estas dos colecciones son el puente entre el sistema de horarios y el servicio de IA externo.

---

## Resumen de fuentes por módulo

| Módulo | Fuente principal |
|---|---|
| 1. Seguridad y Acceso | Threat Model V8/V9 (STRIDE) + Ley 1581 |
| 2. Estructura Institucional | Dominio real SENA + Normalización 3FN |
| 3. Catálogos Base | Normalización 3FN + Mantenibilidad sin despliegue |
| 4. Líneas y Redes | Audio (instrucción complementaria) + Dominio SENA |
| 5. Oferta y Programas | Audio Problemas 2 y 3 + Dominio SENA |
| 6. Programa Académico | Audio Problemas 2 y 3 + Imagen clase final |
| 7. Instructores | Audio Problema 2 + Ley 1581 (PII) + Normalización 1FN |
| 8. Ambientes | PRD V6–V9 + Imagen clase final (disponibilidad real) |
| 9. Fichas y Franjas | Audio Problema 1 + PRD V6–V9 |
| 10. Aprendices | Dominio SENA + Exportaciones + Ley 1581 |
| 11. Motor de Horarios | PRD KPI + Audio Problemas 1 y 2 |
| 12. Observaciones e Incidencias | PRD V6–V9 + Imagen clase final (separación conceptual) |
| 13. Proyectos Formativos | Imagen clase final + Dominio SENA (requisito de grado) |
| 14. Coordinación y Evaluación | Imagen clase final + Dominio SENA |
| 15. Notificaciones y Trazabilidad | Imagen clase final + Threat Model (Repudiation) |
| 16. Reportes y Exportaciones *(propuesto)* | PRD KPI + Necesidad institucional |
| 17. Asistente IA *(propuesto)* | Requisito del instructor en clase + Patrón RAG |
