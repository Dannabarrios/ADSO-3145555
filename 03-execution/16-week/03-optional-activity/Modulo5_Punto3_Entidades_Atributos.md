# MÓDULO 5: PROGRAMAS DE FORMACIÓN
## Punto 3 — Entidades con Atributos Justificados

---

## ENTIDADES NIVEL CATÁLOGO (Referencias de Estructura Institucional)

### 1. **linea_tecnologica**
**Atributos:**
- `id_linea` (UUID) — Identificador único
- `codigo_linea` (VARCHAR) — Código único, obligatorio (ej: "LTE01")
- `nombre` (VARCHAR) — Nombre descriptivo, obligatorio
- `descripcion` (TEXT) — Información adicional
- `estado` (BOOLEAN) — Activo/Inactivo, por defecto TRUE

**Justificación:**
- Es el nivel más alto de la jerarquía SENA (nivel 1/6)
- Requiere código y nombre únicos para identificación institucional
- El estado permite deshabilitar sin borrar datos históricos
- Viene de **Módulo 2 (Estructura Institucional)** pero se replica aquí como referencia

---

### 2. **red_tecnologica**
**Atributos:**
- `id_red_tecnologica` (UUID) — Identificador único
- `id_linea` (UUID FK) — Referencia a linea_tecnologica (nivel 1)
- `codigo_red_tecnologica` (VARCHAR) — Código único dentro de la línea
- `nombre` (VARCHAR) — Nombre descriptivo
- `descripcion` (TEXT) — Información adicional
- `estado` (BOOLEAN) — Activo/Inactivo

**Justificación:**
- Nivel 2 de la jerarquía SENA
- Subordinada obligatoriamente a una `linea_tecnologica`
- Código único asegura identificación sin ambigüedad
- Estado permite gestión de vigencia sin pérdida de datos

---

### 3. **red_conocimiento**
**Atributos:**
- `id_red_conocimiento` (UUID) — Identificador único
- `id_red_tecnologica` (UUID FK) — Referencia a red_tecnologica (nivel 2)
- `codigo_red_conocimiento` (VARCHAR) — Código único
- `nombre` (VARCHAR) — Nombre descriptivo
- `descripcion` (TEXT) — Información adicional
- `estado` (BOOLEAN) — Activo/Inactivo

**Justificación:**
- Nivel 3 de la jerarquía SENA
- Subordinada a `red_tecnologica` (relación 1:N)
- Código único para trazabilidad en reportes curriculares
- Es el punto de entrada para programas de formación

---

### 4. **tipo_formacion**
**Atributos:**
- `id_tipo_formacion` (UUID) — Identificador único
- `codigo_tipo` (VARCHAR) — Código único (ej: "TF001")
- `nombre` (VARCHAR) — Nombre único (ej: "Titulada", "Complementaria", "EDT", "Certificación por Competencia Laboral")
- `certificado_emitido` (VARCHAR) — Tipo de certificado que se emite para este tipo
- `descripcion` (TEXT) — Información adicional
- `estado` (BOOLEAN) — Activo/Inactivo

**Justificación:**
- Catálogo maestro con ~4-5 valores fijos según SENA
- `certificado_emitido` es crítico: define qué documento legal se expide
- Nombre único evita duplicados que causen confusión curricular
- Viene de **Módulo 4 (Parametrización)** pero se replica como referencia

---

### 5. **modalidad_formacion**
**Atributos:**
- `id_modalidad` (UUID) — Identificador único
- `codigo_modalidad` (VARCHAR) — Código único (ej: "MOD01")
- `nombre` (VARCHAR) — Nombre único (ej: "Presencial", "Virtual", "Mixta", "A distancia")
- `descripcion` (TEXT) — Información adicional
- `requiere_ambiente_fisico` (BOOLEAN) — Si necesita sala, laboratorio, etc.
- `estado` (BOOLEAN) — Activo/Inactivo

**Justificación:**
- Catálogo maestro (~4 valores fijos)
- `requiere_ambiente_fisico` es crítico para **Módulo 8 (Horarios)** y **Módulo 10 (Coordinación y Eventos)**: virtual no necesita sala
- Viene de **Módulo 4** pero se replica aquí como referencia
- Impacta en costos y disponibilidad de recursos

---

### 6. **tipo_competencia**
**Atributos:**
- `id_tipo_competencia` (UUID) — Identificador único
- `codigo_tipo` (VARCHAR) — Código único
- `nombre` (VARCHAR) — Nombre único (ej: "CE" = Competencia Específica, "CT" = Competencia Transversal, "CB" = Competencia Básica)
- `descripcion` (TEXT) — Información adicional
- `estado` (BOOLEAN) — Activo/Inactivo

**Justificación:**
- Catálogo maestro con 3 tipos según SENA
- Define la naturaleza curricular de cada competencia
- Nombre único evita ambigüedades en reportes

---

### 7. **tipo_resultado_aprendizaje**
**Atributos:**
- `id_tipo_resultado` (UUID) — Identificador único
- `codigo_tipo` (VARCHAR) — Código único
- `nombre` (VARCHAR) — Nombre único (ej: "RAE" = Resultado de Aprendizaje Esperado, "RAT" = Resultado de Aprendizaje en Transferencia, "RAB" = Resultado de Aprendizaje Básico)
- `descripcion` (TEXT) — Información adicional
- `estado` (BOOLEAN) — Activo/Inactivo

**Justificación:**
- Catálogo maestro con 3 subtipos de RAP
- Diferencia el contexto evaluativo y didáctico de cada RAP
- Nombre único asegura consistencia en formulación curricular

---

## ENTIDADES NIVEL PROGRAMA (Núcleo de Module 5)

### 8. **programa_formacion**
**Atributos:**
- `id_programa` (UUID) — Identificador único
- `id_red_conocimiento` (UUID FK) — Referencia a red_conocimiento (nivel 3 jerárquico)
- `id_tipo_formacion` (UUID FK) — Referencia a tipo_formacion
- `id_modalidad` (UUID FK) — Referencia a modalidad_formacion
- `codigo_programa` (VARCHAR) — Código único institucional (ej: "923401")
- `nombre` (VARCHAR) — Nombre del programa (ej: "Técnico en Desarrollo de Software")
- `version_diseno` (VARCHAR) — Control de versión curricular (ej: "2.0")
- `duracion_horas` (INTEGER) — Total de horas (validado > 0)
- `a_la_medida` (BOOLEAN) — Si es diseño customizado (por defecto FALSE)
- `vigencia_inicio` (DATE) — Fecha de inicio de oferta
- `vigencia_fin` (DATE) — Fecha de finalización (NULL = indefinida)
- `estado` (BOOLEAN) — Activo/Inactivo
- `created_at`, `updated_at` (TIMESTAMP) — Auditoría

**Justificación:**
- Entidad central de Module 5: representa cada **Programa de Formación SENA**
- `id_red_conocimiento`: cada programa pertenece a exactamente una red de conocimiento (relación 1:N)
- `id_tipo_formacion` y `id_modalidad`: definen cómo se ofrece
- `codigo_programa`: identificador institucional único (formato: 6 dígitos SENA)
- `version_diseno`: SENA versiona los currículos (1.0, 2.0, 2.1, etc.)
- `duracion_horas`: crítico para calendarización (**Módulo 8**)
- `a_la_medida`: regla de negocio: un programa "titulado" NO puede ser a_la_medida
- `vigencia_inicio`/`vigencia_fin`: ciclo de vida del programa (necesario para **Módulo 6 - Oferta**)
- Auditoría temporal: tracking de cambios curriculares

---

### 9. **competencia**
**Atributos:**
- `id_competencia` (UUID) — Identificador único
- `id_tipo_competencia` (UUID FK) — Referencia a tipo_competencia (CE, CT, CB)
- `codigo_competencia` (VARCHAR) — Código único institucional
- `nombre` (VARCHAR) — Descripción de la competencia
- `descripcion` (TEXT) — Detalles adicionales
- `horas_totales` (INTEGER) — Horas base de la competencia (validado > 0)
- `estado` (BOOLEAN) — Activo/Inactivo
- `created_at`, `updated_at` (TIMESTAMP) — Auditoría

**Justificación:**
- **Catálogo maestro** de competencias SENA (nivel 5 jerárquico)
- `id_tipo_competencia`: cada competencia es CE, CT o CB
- `codigo_competencia`: identificador único institucional
- `horas_totales`: horas estándar (puede variar por programa en `programa_competencia`)
- No tiene FK a programa directamente: la relación es M:N a través de `programa_competencia`
- Auditoría: competencias pueden cambiar de definición con el tiempo

---

### 10. **programa_competencia**
**Atributos:**
- `id_programa_competencia` (UUID) — Identificador único
- `id_programa` (UUID FK) — Referencia a programa_formacion
- `id_competencia` (UUID FK) — Referencia a competencia
- `orden_malla` (SMALLINT) — Secuencia en la malla curricular (ej: 1, 2, 3...)
- `horas_en_programa` (INTEGER) — Horas específicas en este programa (puede diferir de `horas_totales`)
- `estado` (BOOLEAN) — Activo/Inactivo
- **UNIQUE constraints:**
  - `(id_programa, id_competencia)` — Una competencia aparece una sola vez por programa
  - `(id_programa, orden_malla)` — Cada orden es único por programa

**Justificación:**
- Tabla de **asociación M:N** entre `programa_formacion` y `competencia`
- `orden_malla`: define el flujo de aprendizaje (secuencialidad curricular)
- `horas_en_programa`: la MISMA competencia puede tener 120h en un programa y 80h en otro
- UNIQUE constraints previenen duplicados y desorden en la malla
- Impacta directamente en:
  - **Módulo 7 (Actores)**: instructores autorizados por competencia
  - **Módulo 8 (Horarios)**: bloques de tiempo por competencia
  - **Módulo 9 (Proyectos Formativos)**: proyectos integran competencias

---

### 11. **resultado_aprendizaje**
**Atributos:**
- `id_resultado` (UUID) — Identificador único
- `id_tipo_resultado` (UUID FK) — Referencia a tipo_resultado_aprendizaje (RAE, RAT, RAB)
- `codigo_resultado` (VARCHAR) — Código único institucional
- `nombre` (VARCHAR) — Descripción del RAP (enunciado de resultado esperado)
- `descripcion` (TEXT) — Criterios de evaluación, evidencias, etc.
- `estado` (BOOLEAN) — Activo/Inactivo
- `created_at`, `updated_at` (TIMESTAMP) — Auditoría

**Justificación:**
- **Catálogo maestro** de Resultados de Aprendizaje (nivel 6 jerárquico)
- `id_tipo_resultado`: diferencia RAE (resultado esperado), RAT (transferencia), RAB (básico)
- `codigo_resultado`: código único (ej: "RAE201")
- `nombre`: enunciado del resultado (ej: "Integra características de seguridad en la aplicación")
- `descripcion`: criterios de evaluación específicos
- No tiene FK a competencia: relación es M:N a través de `competencia_resultado`
- Auditoría: formulación de RAPs puede mejorarse

---

### 12. **competencia_resultado**
**Atributos:**
- `id_competencia_resultado` (UUID) — Identificador único
- `id_competencia` (UUID FK) — Referencia a competencia
- `id_resultado` (UUID FK) — Referencia a resultado_aprendizaje
- `orden_resultado` (SMALLINT) — Secuencia de RAPs dentro de la competencia
- `horas_resultado` (INTEGER) — Horas dedicadas a este RAP (validado > 0)
- `estado` (BOOLEAN) — Activo/Inactivo
- **UNIQUE constraints:**
  - `(id_competencia, id_resultado)` — Un RAP aparece una sola vez por competencia
  - `(id_competencia, orden_resultado)` — Cada orden es único

**Justificación:**
- Tabla de **asociación M:N** entre `competencia` y `resultado_aprendizaje`
- `orden_resultado`: define el orden de logro dentro de la competencia
- `horas_resultado`: horas específicas para evaluar este RAP (suma de todos = `horas_en_programa`)
- UNIQUE constraints previenen duplicados
- Impacta en:
  - **Módulo 8 (Horarios)**: temporalidad de RAPs
  - **Módulo 9 (Proyectos)**: proyectos están alineados a RAPs específicos
  - **Módulo 6 (Oferta)**: visibilidad de RAPs en catálogos públicos

---

## RESUMEN DE RELACIONES ENTRE ENTIDADES

```
linea_tecnologica (1) ← → (N) red_tecnologica
red_tecnologica (1) ← → (N) red_conocimiento
red_conocimiento (1) ← → (N) programa_formacion

tipo_formacion (1) ← → (N) programa_formacion
modalidad_formacion (1) ← → (N) programa_formacion

tipo_competencia (1) ← → (N) competencia
competencia (1) ← → (N) programa_competencia (N) ← → (1) programa_formacion

tipo_resultado_aprendizaje (1) ← → (N) resultado_aprendizaje
resultado_aprendizaje (1) ← → (N) competencia_resultado (N) ← → (1) competencia
```

---

## DEPENDENCIAS CON OTROS MÓDULOS

| Entrada (Depende de) | Salida (Proporciona a) |
|---|---|
| **Módulo 2**: Estructura institucional (red tecnológica, red conocimiento) | **Módulo 6**: Oferta y Programas (catálogos) |
| **Módulo 4**: Tipos de formación, modalidades | **Módulo 7**: Actores (instructores por competencia) |
| — | **Módulo 8**: Horarios (malla, competencias, horas) |
| — | **Módulo 9**: Proyectos Formativos (competencias, RAPs) |
| — | **Módulo 10**: Coordinación y Eventos (programas vigentes) |

---

## REGLAS DE NEGOCIO IMPLEMENTADAS

1. ✅ `duracion_horas > 0` — Un programa debe tener mínimo 1 hora
2. ✅ `horas_totales > 0` (competencia) — Una competencia sin horas no es evaluable
3. ✅ `horas_resultado > 0` — Un RAP debe tener tiempo asignado
4. ✅ `orden_malla > 0` — La secuencia inicia en 1
5. ✅ `vigencia_fin >= vigencia_inicio` — Validación de fechas
6. ✅ `codigo_*` UNIQUE — Evita duplicados en identificación
7. ✅ `nombre` UNIQUE (tipo_formacion, modalidad_formacion, tipo_competencia, tipo_resultado) — Catálogos sin duplicados
8. ✅ `(id_programa, id_competencia)` UNIQUE — Una competencia por programa
9. ✅ `(id_programa, orden_malla)` UNIQUE — Orden único en malla
10. ✅ `(id_competencia, id_resultado)` UNIQUE — Un RAP por competencia
11. ✅ `(id_competencia, orden_resultado)` UNIQUE — Orden único en RAPs
12. ⚠️ **No titulada puede ser a_la_medida** — Debe validarse en app/API (no es CHECK SQL directo)

---

## OBSERVACIONES FINALES

- **Todos los IDs** son UUID (no secuenciales): mejor para microservicios y distribuido
- **Códigos** son VARCHAR (no UUID): mantienen los códigos SENA de 6 dígitos o similar
- **Estados y auditoría**: permiten soft-delete y trazabilidad sin perder historia
- **FKs y UNIQUE constraints**: garantizan integridad referencial y unicidad
- **M:N con atributos**: `programa_competencia` y `competencia_resultado` no son solo conectores: llevan data crítica (horas, orden, estado)
