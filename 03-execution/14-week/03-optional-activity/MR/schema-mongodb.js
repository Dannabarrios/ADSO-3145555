// ============================================================
// SENA Schedule Manager — Script MongoDB Completo
// Versión: 10.0 | 48 colecciones | 17 módulos
// Motor: MongoDB 6.0+
// Uso: mongosh < schema.js
// ============================================================

// ============================================================
// CONFIGURACIÓN INICIAL
// ============================================================

use sena_schedule_db;

// ============================================================
// MÓDULO 1 — SEGURIDAD Y ACCESO
// ============================================================

db.createCollection("usuario", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["correo", "password_hash", "activo", "creado_en"],
      properties: {
        _id:             { bsonType: "objectId" },
        instructor_id:   { bsonType: ["objectId", "null"], description: "FK opcional a instructor" },
        correo:          { bsonType: "string", pattern: "^[^@]+@[^@]+\\.[^@]+$", description: "PII - correo institucional" },
        password_hash:   { bsonType: "string", minLength: 60, description: "Hash bcrypt, nunca texto plano" },
        activo:          { bsonType: "bool" },
        ultimo_acceso:   { bsonType: ["date", "null"] },
        creado_en:       { bsonType: "date" },
        actualizado_en:  { bsonType: "date" }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
});

db.usuario.createIndex({ correo: 1 }, { unique: true, name: "idx_usuario_correo" });
db.usuario.createIndex({ instructor_id: 1 }, { sparse: true, name: "idx_usuario_instructor" });

// ------------------------------------------------------------

db.createCollection("rol", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre"],
      properties: {
        _id:         { bsonType: "objectId" },
        nombre:      { bsonType: "string", enum: ["administrador", "coordinador", "instructor", "visor"] },
        descripcion: { bsonType: "string" }
      }
    }
  }
});

db.rol.createIndex({ nombre: 1 }, { unique: true, name: "idx_rol_nombre" });

// Datos iniciales
db.rol.insertMany([
  { nombre: "administrador", descripcion: "Acceso total al sistema" },
  { nombre: "coordinador",   descripcion: "Gestión académica y de horarios" },
  { nombre: "instructor",    descripcion: "Consulta y registro de bloques propios" },
  { nombre: "visor",         descripcion: "Solo lectura" }
]);

// ------------------------------------------------------------

db.createCollection("usuario_rol", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["usuario_id", "rol_id", "creado_en"],
      properties: {
        _id:        { bsonType: "objectId" },
        usuario_id: { bsonType: "objectId" },
        rol_id:     { bsonType: "objectId" },
        creado_en:  { bsonType: "date" }
      }
    }
  }
});

db.usuario_rol.createIndex(
  { usuario_id: 1, rol_id: 1 },
  { unique: true, name: "idx_usuario_rol_unique" }
);

// ------------------------------------------------------------

db.createCollection("log_auditoria", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["usuario_id", "coleccion", "documento_id", "accion", "creado_en"],
      properties: {
        _id:              { bsonType: "objectId" },
        usuario_id:       { bsonType: "objectId" },
        coleccion:        { bsonType: "string" },
        documento_id:     { bsonType: "string" },
        accion:           { bsonType: "string", enum: ["create", "update", "delete", "cancel"] },
        datos_anteriores: { bsonType: ["object", "null"] },
        creado_en:        { bsonType: "date" }
      }
    }
  }
});

db.log_auditoria.createIndex({ usuario_id: 1, creado_en: -1 }, { name: "idx_log_usuario_fecha" });
db.log_auditoria.createIndex({ coleccion: 1, documento_id: 1 }, { name: "idx_log_coleccion_doc" });

// ------------------------------------------------------------

db.createCollection("exportacion", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["usuario_id", "tipo", "modulo", "estado", "creado_en"],
      properties: {
        _id:         { bsonType: "objectId" },
        usuario_id:  { bsonType: "objectId" },
        tipo:        { bsonType: "string", enum: ["pdf", "excel"] },
        modulo:      { bsonType: "string" },
        filtros:     { bsonType: ["object", "null"] },
        url_archivo: { bsonType: ["string", "null"] },
        estado:      { bsonType: "string", enum: ["generando", "completado", "error"] },
        creado_en:   { bsonType: "date" }
      }
    }
  }
});

db.exportacion.createIndex({ usuario_id: 1, creado_en: -1 }, { name: "idx_exportacion_usuario" });

// ============================================================
// MÓDULO 2 — ESTRUCTURA INSTITUCIONAL
// ============================================================

db.createCollection("regional", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre", "codigo", "activo", "creado_en"],
      properties: {
        _id:       { bsonType: "objectId" },
        nombre:    { bsonType: "string" },
        codigo:    { bsonType: "string" },
        activo:    { bsonType: "bool" },
        creado_en: { bsonType: "date" }
      }
    }
  }
});

db.regional.createIndex({ codigo: 1 }, { unique: true, name: "idx_regional_codigo" });

// ------------------------------------------------------------

db.createCollection("centro_formacion", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["regional_id", "nombre", "codigo", "activo", "creado_en"],
      properties: {
        _id:         { bsonType: "objectId" },
        regional_id: { bsonType: "objectId" },
        nombre:      { bsonType: "string" },
        codigo:      { bsonType: "string" },
        activo:      { bsonType: "bool" },
        creado_en:   { bsonType: "date" }
      }
    }
  }
});

db.centro_formacion.createIndex({ codigo: 1 }, { unique: true, name: "idx_centro_codigo" });
db.centro_formacion.createIndex({ regional_id: 1 }, { name: "idx_centro_regional" });

// ------------------------------------------------------------

db.createCollection("sede", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["centro_id", "nombre", "ciudad", "activo", "creado_en"],
      properties: {
        _id:        { bsonType: "objectId" },
        centro_id:  { bsonType: "objectId" },
        nombre:     { bsonType: "string" },
        ciudad:     { bsonType: "string" },
        direccion:  { bsonType: ["string", "null"] },
        activo:     { bsonType: "bool" },
        creado_en:  { bsonType: "date" }
      }
    }
  }
});

db.sede.createIndex({ centro_id: 1 }, { name: "idx_sede_centro" });

// ============================================================
// MÓDULO 3 — CATÁLOGOS BASE
// ============================================================

db.createCollection("tipo_documento", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["codigo", "nombre"],
      properties: {
        _id:    { bsonType: "objectId" },
        codigo: { bsonType: "string" },
        nombre: { bsonType: "string" }
      }
    }
  }
});

db.tipo_documento.createIndex({ codigo: 1 }, { unique: true, name: "idx_tipodoc_codigo" });

db.tipo_documento.insertMany([
  { codigo: "CC",  nombre: "Cédula de Ciudadanía" },
  { codigo: "CE",  nombre: "Cédula de Extranjería" },
  { codigo: "TI",  nombre: "Tarjeta de Identidad" },
  { codigo: "PA",  nombre: "Pasaporte" },
  { codigo: "NIT", nombre: "NIT" }
]);

// ------------------------------------------------------------

db.createCollection("tipo_contrato", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre"],
      properties: {
        _id:         { bsonType: "objectId" },
        nombre:      { bsonType: "string" },
        descripcion: { bsonType: ["string", "null"] }
      }
    }
  }
});

db.tipo_contrato.createIndex({ nombre: 1 }, { unique: true, name: "idx_tipocontrato_nombre" });

db.tipo_contrato.insertMany([
  { nombre: "Planta",        descripcion: "Funcionario de planta del SENA" },
  { nombre: "Contratista",   descripcion: "Contratación por prestación de servicios" },
  { nombre: "Hora-cátedra",  descripcion: "Pago por hora orientada" }
]);

// ------------------------------------------------------------

db.createCollection("tipo_ambiente", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre"],
      properties: {
        _id:         { bsonType: "objectId" },
        nombre:      { bsonType: "string" },
        descripcion: { bsonType: ["string", "null"] }
      }
    }
  }
});

db.tipo_ambiente.createIndex({ nombre: 1 }, { unique: true, name: "idx_tipoambiente_nombre" });

db.tipo_ambiente.insertMany([
  { nombre: "Aula",         descripcion: "Salón de clase presencial" },
  { nombre: "Laboratorio",  descripcion: "Espacio con equipos especializados" },
  { nombre: "Taller",       descripcion: "Espacio para práctica manual" },
  { nombre: "Virtual",      descripcion: "Espacio de formación en línea" },
  { nombre: "Auditorio",    descripcion: "Espacio para eventos y presentaciones" }
]);

// ------------------------------------------------------------

db.createCollection("nivel_formacion", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre"],
      properties: {
        _id:         { bsonType: "objectId" },
        nombre:      { bsonType: "string" },
        descripcion: { bsonType: ["string", "null"] }
      }
    }
  }
});

db.nivel_formacion.createIndex({ nombre: 1 }, { unique: true, name: "idx_nivelformacion_nombre" });

db.nivel_formacion.insertMany([
  { nombre: "Técnico",                      descripcion: "Duración aproximada 12-24 meses" },
  { nombre: "Tecnólogo",                    descripcion: "Duración aproximada 24-36 meses" },
  { nombre: "Auxiliar",                     descripcion: "Duración aproximada 6-12 meses" },
  { nombre: "Especialización Tecnológica",  descripcion: "Nivel posmedia" },
  { nombre: "Operario",                     descripcion: "Nivel básico operativo" }
]);

// ------------------------------------------------------------

db.createCollection("modalidad", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre"],
      properties: {
        _id:         { bsonType: "objectId" },
        nombre:      { bsonType: "string" },
        descripcion: { bsonType: ["string", "null"] }
      }
    }
  }
});

db.modalidad.createIndex({ nombre: 1 }, { unique: true, name: "idx_modalidad_nombre" });

db.modalidad.insertMany([
  { nombre: "Presencial",    descripcion: "Asistencia física al centro" },
  { nombre: "Virtual",       descripcion: "Formación completamente en línea" },
  { nombre: "A distancia",   descripcion: "Combinación de virtual y presencial esporádico" },
  { nombre: "Combinada",     descripcion: "Mitad presencial, mitad virtual" }
]);

// ------------------------------------------------------------

db.createCollection("jornada", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre", "hora_inicio", "hora_fin"],
      properties: {
        _id:         { bsonType: "objectId" },
        nombre:      { bsonType: "string" },
        hora_inicio: { bsonType: "string", pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$" },
        hora_fin:    { bsonType: "string", pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$" }
      }
    }
  }
});

db.jornada.createIndex({ nombre: 1 }, { unique: true, name: "idx_jornada_nombre" });

db.jornada.insertMany([
  { nombre: "Mañana",           hora_inicio: "06:00", hora_fin: "12:00" },
  { nombre: "Tarde",            hora_inicio: "12:00", hora_fin: "18:00" },
  { nombre: "Noche",            hora_inicio: "18:00", hora_fin: "22:00" },
  { nombre: "Fines de semana",  hora_inicio: "07:00", hora_fin: "17:00" }
]);

// ============================================================
// MÓDULO 4 — LÍNEAS Y REDES
// ============================================================

db.createCollection("linea_formacion", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre"],
      properties: {
        _id:         { bsonType: "objectId" },
        nombre:      { bsonType: "string" },
        descripcion: { bsonType: ["string", "null"] }
      }
    }
  }
});

db.linea_formacion.createIndex({ nombre: 1 }, { unique: true, name: "idx_linea_nombre" });

db.linea_formacion.insertMany([
  { nombre: "Formación Titulada",       descripcion: "Programas con ficha oficial, aprendices matriculados" },
  { nombre: "Formación Complementaria", descripcion: "Cursos cortos, abiertos, sin ficha larga" }
]);

// ------------------------------------------------------------

db.createCollection("area_conocimiento", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre"],
      properties: {
        _id:         { bsonType: "objectId" },
        nombre:      { bsonType: "string" },
        descripcion: { bsonType: ["string", "null"] }
      }
    }
  }
});

db.area_conocimiento.createIndex({ nombre: 1 }, { unique: true, name: "idx_area_nombre" });

// ------------------------------------------------------------

db.createCollection("red_conocimiento", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre"],
      properties: {
        _id:         { bsonType: "objectId" },
        nombre:      { bsonType: "string" },
        descripcion: { bsonType: ["string", "null"] }
      }
    }
  }
});

db.red_conocimiento.createIndex({ nombre: 1 }, { unique: true, name: "idx_red_nombre" });

// ------------------------------------------------------------

db.createCollection("linea_red", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["linea_id", "red_id", "creado_en"],
      properties: {
        _id:       { bsonType: "objectId" },
        linea_id:  { bsonType: "objectId" },
        red_id:    { bsonType: "objectId" },
        creado_en: { bsonType: "date" }
      }
    }
  }
});

db.linea_red.createIndex(
  { linea_id: 1, red_id: 1 },
  { unique: true, name: "idx_linea_red_unique" }
);

// ============================================================
// MÓDULO 5 — OFERTA Y PROGRAMAS
// ============================================================

db.createCollection("programa_formacion", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["linea_formacion_id", "nivel_formacion_id", "modalidad_id", "codigo", "nombre", "activo", "creado_en"],
      properties: {
        _id:                 { bsonType: "objectId" },
        linea_formacion_id:  { bsonType: "objectId" },
        nivel_formacion_id:  { bsonType: "objectId" },
        modalidad_id:        { bsonType: "objectId" },
        codigo:              { bsonType: "string" },
        nombre:              { bsonType: "string" },
        duracion_horas:      { bsonType: ["int", "null"], minimum: 1 },
        activo:              { bsonType: "bool" },
        creado_en:           { bsonType: "date" },
        actualizado_en:      { bsonType: ["date", "null"] }
      }
    }
  }
});

db.programa_formacion.createIndex({ codigo: 1 }, { unique: true, name: "idx_programa_codigo" });
db.programa_formacion.createIndex({ linea_formacion_id: 1 }, { name: "idx_programa_linea" });

// ------------------------------------------------------------

db.createCollection("vigencia_programa", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["programa_id", "fecha_inicio", "estado", "creado_en"],
      properties: {
        _id:          { bsonType: "objectId" },
        programa_id:  { bsonType: "objectId" },
        fecha_inicio: { bsonType: "date" },
        fecha_fin:    { bsonType: ["date", "null"] },
        estado:       { bsonType: "string", enum: ["vigente", "suspendido", "en_restructuracion"] },
        creado_en:    { bsonType: "date" }
      }
    }
  }
});

db.vigencia_programa.createIndex({ programa_id: 1, estado: 1 }, { name: "idx_vigencia_programa_estado" });

// ============================================================
// MÓDULO 6 — PROGRAMA ACADÉMICO
// ============================================================

db.createCollection("competencia", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["area_conocimiento_id", "codigo", "nombre", "activo", "creado_en"],
      properties: {
        _id:                  { bsonType: "objectId" },
        area_conocimiento_id: { bsonType: "objectId" },
        codigo:               { bsonType: "string" },
        nombre:               { bsonType: "string" },
        descripcion:          { bsonType: ["string", "null"] },
        horas:                { bsonType: ["int", "null"], minimum: 1 },
        activo:               { bsonType: "bool" },
        creado_en:            { bsonType: "date" }
      }
    }
  }
});

db.competencia.createIndex({ codigo: 1 }, { unique: true, name: "idx_competencia_codigo" });
db.competencia.createIndex({ area_conocimiento_id: 1 }, { name: "idx_competencia_area" });

// ------------------------------------------------------------

db.createCollection("resultado_aprendizaje", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["competencia_id", "codigo", "nombre", "activo", "creado_en"],
      properties: {
        _id:            { bsonType: "objectId" },
        competencia_id: { bsonType: "objectId" },
        codigo:         { bsonType: "string" },
        nombre:         { bsonType: "string" },
        descripcion:    { bsonType: ["string", "null"] },
        activo:         { bsonType: "bool" },
        creado_en:      { bsonType: "date" }
      }
    }
  }
});

db.resultado_aprendizaje.createIndex({ codigo: 1 }, { unique: true, name: "idx_resultado_codigo" });
db.resultado_aprendizaje.createIndex({ competencia_id: 1 }, { name: "idx_resultado_competencia" });

// ------------------------------------------------------------

db.createCollection("programa_competencia", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["programa_id", "competencia_id", "creado_en"],
      properties: {
        _id:            { bsonType: "objectId" },
        programa_id:    { bsonType: "objectId" },
        competencia_id: { bsonType: "objectId" },
        orden:          { bsonType: ["int", "null"] },
        creado_en:      { bsonType: "date" }
      }
    }
  }
});

db.programa_competencia.createIndex(
  { programa_id: 1, competencia_id: 1 },
  { unique: true, name: "idx_prog_comp_unique" }
);

// ------------------------------------------------------------

db.createCollection("programa_resultado", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["programa_id", "resultado_id", "creado_en"],
      properties: {
        _id:          { bsonType: "objectId" },
        programa_id:  { bsonType: "objectId" },
        resultado_id: { bsonType: "objectId" },
        creado_en:    { bsonType: "date" }
      }
    }
  }
});

db.programa_resultado.createIndex(
  { programa_id: 1, resultado_id: 1 },
  { unique: true, name: "idx_prog_result_unique" }
);

// ------------------------------------------------------------

db.createCollection("ruta_formativa", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["programa_id", "nombre", "activo", "creado_en"],
      properties: {
        _id:         { bsonType: "objectId" },
        programa_id: { bsonType: "objectId" },
        nombre:      { bsonType: "string" },
        descripcion: { bsonType: ["string", "null"] },
        activo:      { bsonType: "bool" },
        creado_en:   { bsonType: "date" }
      }
    }
  }
});

db.ruta_formativa.createIndex({ programa_id: 1 }, { name: "idx_ruta_programa" });

// ------------------------------------------------------------

db.createCollection("componente_curricular", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["competencia_id", "nombre", "activo", "creado_en"],
      properties: {
        _id:            { bsonType: "objectId" },
        competencia_id: { bsonType: "objectId" },
        nombre:         { bsonType: "string" },
        tipo:           { bsonType: ["string", "null"], enum: ["teorico", "practico", "proyecto", null] },
        activo:         { bsonType: "bool" },
        creado_en:      { bsonType: "date" }
      }
    }
  }
});

db.componente_curricular.createIndex({ competencia_id: 1 }, { name: "idx_comp_curr_competencia" });

// ============================================================
// MÓDULO 7 — INSTRUCTORES
// ============================================================

db.createCollection("instructor", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["sede_id", "tipo_documento_id", "tipo_contrato_id", "numero_documento", "primer_nombre", "primer_apellido", "correo", "activo", "creado_en"],
      properties: {
        _id:                 { bsonType: "objectId" },
        sede_id:             { bsonType: "objectId" },
        tipo_documento_id:   { bsonType: "objectId" },
        tipo_contrato_id:    { bsonType: "objectId" },
        numero_documento:    { bsonType: "string", description: "PII - Ley 1581" },
        primer_nombre:       { bsonType: "string" },
        segundo_nombre:      { bsonType: ["string", "null"] },
        primer_apellido:     { bsonType: "string" },
        segundo_apellido:    { bsonType: ["string", "null"] },
        correo:              { bsonType: "string", description: "PII - Ley 1581" },
        telefono:            { bsonType: ["string", "null"], description: "PII - Ley 1581" },
        activo:              { bsonType: "bool" },
        creado_en:           { bsonType: "date" },
        actualizado_en:      { bsonType: ["date", "null"] }
      }
    }
  }
});

db.instructor.createIndex({ numero_documento: 1 }, { unique: true, name: "idx_instructor_documento" });
db.instructor.createIndex({ correo: 1 }, { unique: true, name: "idx_instructor_correo" });
db.instructor.createIndex({ sede_id: 1 }, { name: "idx_instructor_sede" });

// ------------------------------------------------------------

db.createCollection("instructor_area", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["instructor_id", "area_id", "creado_en"],
      properties: {
        _id:           { bsonType: "objectId" },
        instructor_id: { bsonType: "objectId" },
        area_id:       { bsonType: "objectId" },
        creado_en:     { bsonType: "date" }
      }
    }
  }
});

db.instructor_area.createIndex(
  { instructor_id: 1, area_id: 1 },
  { unique: true, name: "idx_instructor_area_unique" }
);

// ------------------------------------------------------------

db.createCollection("instructor_competencia", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["instructor_id", "competencia_id", "programa_id", "fecha_inicio", "activo", "creado_en"],
      properties: {
        _id:            { bsonType: "objectId" },
        instructor_id:  { bsonType: "objectId" },
        competencia_id: { bsonType: "objectId" },
        programa_id:    { bsonType: "objectId" },
        fecha_inicio:   { bsonType: "date" },
        fecha_fin:      { bsonType: ["date", "null"] },
        activo:         { bsonType: "bool" },
        creado_en:      { bsonType: "date" }
      }
    }
  }
});

// Índice único: un instructor no puede tener dos habilitaciones activas para la misma competencia en el mismo programa
db.instructor_competencia.createIndex(
  { instructor_id: 1, competencia_id: 1, programa_id: 1 },
  { unique: true, name: "idx_inst_comp_prog_unique" }
);
db.instructor_competencia.createIndex({ instructor_id: 1, activo: 1 }, { name: "idx_inst_comp_activo" });

// ============================================================
// MÓDULO 8 — AMBIENTES
// ============================================================

db.createCollection("ambiente", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["sede_id", "tipo_ambiente_id", "codigo", "nombre", "activo", "creado_en"],
      properties: {
        _id:              { bsonType: "objectId" },
        sede_id:          { bsonType: "objectId" },
        tipo_ambiente_id: { bsonType: "objectId" },
        codigo:           { bsonType: "string" },
        nombre:           { bsonType: "string" },
        capacidad:        { bsonType: ["int", "null"], minimum: 1 },
        ubicacion:        { bsonType: ["string", "null"] },
        activo:           { bsonType: "bool" },
        creado_en:        { bsonType: "date" },
        actualizado_en:   { bsonType: ["date", "null"] }
      }
    }
  }
});

db.ambiente.createIndex({ sede_id: 1, codigo: 1 }, { unique: true, name: "idx_ambiente_sede_codigo" });
db.ambiente.createIndex({ tipo_ambiente_id: 1 }, { name: "idx_ambiente_tipo" });

// ------------------------------------------------------------

db.createCollection("disponibilidad_ambiente", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["ambiente_id", "jornada_id", "fecha", "disponible", "creado_en"],
      properties: {
        _id:         { bsonType: "objectId" },
        ambiente_id: { bsonType: "objectId" },
        jornada_id:  { bsonType: "objectId" },
        fecha:       { bsonType: "date" },
        disponible:  { bsonType: "bool" },
        creado_en:   { bsonType: "date" }
      }
    }
  }
});

db.disponibilidad_ambiente.createIndex(
  { ambiente_id: 1, fecha: 1, jornada_id: 1 },
  { unique: true, name: "idx_disp_amb_fecha_jornada" }
);

// ============================================================
// MÓDULO 9 — FICHAS Y FRANJAS HORARIAS
// ============================================================

db.createCollection("ficha", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["programa_id", "sede_id", "jornada_id", "numero", "fecha_inicio", "fecha_fin", "activo", "creado_en"],
      properties: {
        _id:                  { bsonType: "objectId" },
        programa_id:          { bsonType: "objectId" },
        sede_id:              { bsonType: "objectId" },
        jornada_id:           { bsonType: "objectId" },
        numero:               { bsonType: "string" },
        fecha_inicio:         { bsonType: "date" },
        fecha_fin:            { bsonType: "date" },
        fecha_fin_extendida:  { bsonType: ["date", "null"] },
        estado:               { bsonType: "string", enum: ["en_ejecucion", "terminada", "cancelada", "suspendida"] },
        activo:               { bsonType: "bool" },
        creado_en:            { bsonType: "date" },
        actualizado_en:       { bsonType: ["date", "null"] }
      }
    }
  }
});

db.ficha.createIndex({ numero: 1 }, { unique: true, name: "idx_ficha_numero" });
db.ficha.createIndex({ programa_id: 1 }, { name: "idx_ficha_programa" });
db.ficha.createIndex({ sede_id: 1, estado: 1 }, { name: "idx_ficha_sede_estado" });
db.ficha.createIndex({ fecha_fin: 1 }, { name: "idx_ficha_fecha_fin" });

// ------------------------------------------------------------

db.createCollection("bloque_horario", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["ficha_id", "ambiente_id", "instructor_id", "competencia_id", "fecha", "hora_inicio", "hora_fin", "estado", "creado_en"],
      properties: {
        _id:            { bsonType: "objectId" },
        ficha_id:       { bsonType: "objectId" },
        ambiente_id:    { bsonType: "objectId" },
        instructor_id:  { bsonType: "objectId" },
        competencia_id: { bsonType: "objectId" },
        resultado_id:   { bsonType: ["objectId", "null"] },
        fecha:          { bsonType: "date" },
        hora_inicio:    { bsonType: "string", pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$" },
        hora_fin:       { bsonType: "string", pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$" },
        estado:         { bsonType: "string", enum: ["programado", "cancelado", "ejecutado", "reprogramado"] },
        creado_en:      { bsonType: "date" },
        actualizado_en: { bsonType: ["date", "null"] }
      }
    }
  }
});

// Índices críticos para detección de conflictos (motor de horarios)
db.bloque_horario.createIndex(
  { instructor_id: 1, fecha: 1, hora_inicio: 1, hora_fin: 1 },
  { name: "idx_bloque_instructor_fecha" }
);
db.bloque_horario.createIndex(
  { ambiente_id: 1, fecha: 1, hora_inicio: 1, hora_fin: 1 },
  { name: "idx_bloque_ambiente_fecha" }
);
db.bloque_horario.createIndex(
  { ficha_id: 1, fecha: 1 },
  { name: "idx_bloque_ficha_fecha" }
);
db.bloque_horario.createIndex({ competencia_id: 1 }, { name: "idx_bloque_competencia" });

// ------------------------------------------------------------

db.createCollection("extension_ficha", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["ficha_id", "fecha_fin_anterior", "fecha_fin_nueva", "motivo", "aprobado_por", "creado_en"],
      properties: {
        _id:                 { bsonType: "objectId" },
        ficha_id:            { bsonType: "objectId" },
        fecha_fin_anterior:  { bsonType: "date" },
        fecha_fin_nueva:     { bsonType: "date" },
        motivo:              { bsonType: "string" },
        aprobado_por:        { bsonType: "string" },
        creado_en:           { bsonType: "date" }
      }
    }
  }
});

db.extension_ficha.createIndex({ ficha_id: 1, creado_en: -1 }, { name: "idx_extension_ficha" });

// ============================================================
// MÓDULO 10 — APRENDICES
// ============================================================

db.createCollection("aprendiz", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["tipo_documento_id", "numero_documento", "primer_nombre", "primer_apellido", "activo", "creado_en"],
      properties: {
        _id:               { bsonType: "objectId" },
        tipo_documento_id: { bsonType: "objectId" },
        numero_documento:  { bsonType: "string", description: "PII - Ley 1581" },
        primer_nombre:     { bsonType: "string" },
        segundo_nombre:    { bsonType: ["string", "null"] },
        primer_apellido:   { bsonType: "string" },
        segundo_apellido:  { bsonType: ["string", "null"] },
        correo:            { bsonType: ["string", "null"], description: "PII - Ley 1581" },
        activo:            { bsonType: "bool" },
        creado_en:         { bsonType: "date" },
        actualizado_en:    { bsonType: ["date", "null"] }
      }
    }
  }
});

db.aprendiz.createIndex({ numero_documento: 1 }, { unique: true, name: "idx_aprendiz_documento" });
db.aprendiz.createIndex({ primer_apellido: 1, primer_nombre: 1 }, { name: "idx_aprendiz_nombre" });

// ------------------------------------------------------------

db.createCollection("ficha_aprendiz", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["ficha_id", "aprendiz_id", "fecha_matricula", "estado"],
      properties: {
        _id:             { bsonType: "objectId" },
        ficha_id:        { bsonType: "objectId" },
        aprendiz_id:     { bsonType: "objectId" },
        fecha_matricula: { bsonType: "date" },
        estado:          { bsonType: "string", enum: ["activo", "retirado", "trasladado", "graduado"] }
      }
    }
  }
});

db.ficha_aprendiz.createIndex(
  { ficha_id: 1, aprendiz_id: 1 },
  { unique: true, name: "idx_ficha_aprendiz_unique" }
);
db.ficha_aprendiz.createIndex({ aprendiz_id: 1, estado: 1 }, { name: "idx_ficha_aprendiz_estado" });

// ------------------------------------------------------------

db.createCollection("historial_aprendiz", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["aprendiz_id", "evento", "fecha", "creado_en"],
      properties: {
        _id:         { bsonType: "objectId" },
        aprendiz_id: { bsonType: "objectId" },
        evento:      { bsonType: "string", enum: ["matricula", "retiro", "traslado", "reintegro", "graduacion"] },
        descripcion: { bsonType: ["string", "null"] },
        fecha:       { bsonType: "date" },
        creado_en:   { bsonType: "date" }
      }
    }
  }
});

db.historial_aprendiz.createIndex({ aprendiz_id: 1, fecha: -1 }, { name: "idx_historial_aprendiz_fecha" });

// ============================================================
// MÓDULO 11 — MOTOR DE HORARIOS
// ============================================================

db.createCollection("conflicto_horario", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["bloque_a_id", "bloque_b_id", "tipo", "resuelto", "creado_en"],
      properties: {
        _id:          { bsonType: "objectId" },
        bloque_a_id:  { bsonType: "objectId" },
        bloque_b_id:  { bsonType: "objectId" },
        tipo:         { bsonType: "string", enum: ["instructor_duplicado", "ambiente_ocupado", "ficha_solapada", "vigencia_vencida", "instructor_no_habilitado"] },
        descripcion:  { bsonType: ["string", "null"] },
        resuelto:     { bsonType: "bool" },
        creado_en:    { bsonType: "date" }
      }
    }
  }
});

db.conflicto_horario.createIndex({ resuelto: 1, creado_en: -1 }, { name: "idx_conflicto_resuelto_fecha" });
db.conflicto_horario.createIndex({ bloque_a_id: 1 }, { name: "idx_conflicto_bloque_a" });
db.conflicto_horario.createIndex({ bloque_b_id: 1 }, { name: "idx_conflicto_bloque_b" });

// ============================================================
// MÓDULO 12 — OBSERVACIONES E INCIDENCIAS
// ============================================================

db.createCollection("observacion", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["bloque_id", "autor", "texto", "severidad", "creado_en"],
      properties: {
        _id:           { bsonType: "objectId" },
        bloque_id:     { bsonType: "objectId" },
        instructor_id: { bsonType: ["objectId", "null"] },
        autor:         { bsonType: "string", description: "PII - Ley 1581" },
        texto:         { bsonType: "string" },
        severidad:     { bsonType: "string", enum: ["info", "advertencia", "critica"] },
        creado_en:     { bsonType: "date" }
      }
    }
  }
});

db.observacion.createIndex({ bloque_id: 1 }, { name: "idx_observacion_bloque" });
db.observacion.createIndex({ severidad: 1, creado_en: -1 }, { name: "idx_observacion_severidad" });

// ------------------------------------------------------------

db.createCollection("incidencia", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["bloque_id", "usuario_id", "tipo", "estado", "creado_en"],
      properties: {
        _id:            { bsonType: "objectId" },
        bloque_id:      { bsonType: "objectId" },
        usuario_id:     { bsonType: "objectId" },
        tipo:           { bsonType: "string", enum: ["conflicto", "bloqueo", "reprogramacion", "cancelacion", "otro"] },
        descripcion:    { bsonType: ["string", "null"] },
        estado:         { bsonType: "string", enum: ["abierta", "en_proceso", "resuelta"] },
        creado_en:      { bsonType: "date" },
        actualizado_en: { bsonType: ["date", "null"] }
      }
    }
  }
});

db.incidencia.createIndex({ bloque_id: 1 }, { name: "idx_incidencia_bloque" });
db.incidencia.createIndex({ estado: 1, creado_en: -1 }, { name: "idx_incidencia_estado" });

// ============================================================
// MÓDULO 13 — PROYECTOS FORMATIVOS
// ============================================================

db.createCollection("proyecto_formativo", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["ficha_id", "instructor_id", "titulo", "estado", "creado_en"],
      properties: {
        _id:           { bsonType: "objectId" },
        ficha_id:      { bsonType: "objectId" },
        instructor_id: { bsonType: "objectId" },
        titulo:        { bsonType: "string" },
        descripcion:   { bsonType: ["string", "null"] },
        estado:        { bsonType: "string", enum: ["formulacion", "ejecucion", "evaluacion", "aprobado", "rechazado"] },
        fecha_inicio:  { bsonType: ["date", "null"] },
        fecha_fin:     { bsonType: ["date", "null"] },
        creado_en:     { bsonType: "date" }
      }
    }
  }
});

db.proyecto_formativo.createIndex({ ficha_id: 1 }, { name: "idx_proyecto_ficha" });
db.proyecto_formativo.createIndex({ instructor_id: 1, estado: 1 }, { name: "idx_proyecto_instructor_estado" });

// ------------------------------------------------------------

db.createCollection("hito_proyecto", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["proyecto_id", "nombre", "fecha_limite", "cumplido", "creado_en"],
      properties: {
        _id:          { bsonType: "objectId" },
        proyecto_id:  { bsonType: "objectId" },
        nombre:       { bsonType: "string" },
        fecha_limite: { bsonType: "date" },
        cumplido:     { bsonType: "bool" },
        creado_en:    { bsonType: "date" }
      }
    }
  }
});

db.hito_proyecto.createIndex({ proyecto_id: 1 }, { name: "idx_hito_proyecto" });
db.hito_proyecto.createIndex({ fecha_limite: 1, cumplido: 1 }, { name: "idx_hito_vencimiento" });

// ------------------------------------------------------------

db.createCollection("revision_proyecto", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["proyecto_id", "instructor_id", "estado", "creado_en"],
      properties: {
        _id:           { bsonType: "objectId" },
        proyecto_id:   { bsonType: "objectId" },
        instructor_id: { bsonType: "objectId" },
        comentario:    { bsonType: ["string", "null"] },
        calificacion:  { bsonType: ["double", "null"], minimum: 0, maximum: 5 },
        estado:        { bsonType: "string", enum: ["pendiente", "aprobado", "rechazado"] },
        creado_en:     { bsonType: "date" }
      }
    }
  }
});

db.revision_proyecto.createIndex({ proyecto_id: 1, creado_en: -1 }, { name: "idx_revision_proyecto_fecha" });

// ============================================================
// MÓDULO 14 — COORDINACIÓN Y EVALUACIÓN
// ============================================================

db.createCollection("asignacion_coordinacion", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["usuario_id", "ambiente_id", "fecha", "hora_inicio", "hora_fin", "creado_en"],
      properties: {
        _id:         { bsonType: "objectId" },
        usuario_id:  { bsonType: "objectId" },
        ambiente_id: { bsonType: "objectId" },
        fecha:       { bsonType: "date" },
        hora_inicio: { bsonType: "string", pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$" },
        hora_fin:    { bsonType: "string", pattern: "^([01]?[0-9]|2[0-3]):[0-5][0-9]$" },
        proposito:   { bsonType: ["string", "null"] },
        creado_en:   { bsonType: "date" }
      }
    }
  }
});

db.asignacion_coordinacion.createIndex(
  { ambiente_id: 1, fecha: 1, hora_inicio: 1, hora_fin: 1 },
  { name: "idx_asignacion_ambiente_fecha" }
);

// ------------------------------------------------------------

db.createCollection("evaluacion_espacio", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["asignacion_id", "usuario_id", "aprobado", "creado_en"],
      properties: {
        _id:           { bsonType: "objectId" },
        asignacion_id: { bsonType: "objectId" },
        usuario_id:    { bsonType: "objectId" },
        calificacion:  { bsonType: ["double", "null"], minimum: 0, maximum: 5 },
        observacion:   { bsonType: ["string", "null"] },
        aprobado:      { bsonType: "bool" },
        creado_en:     { bsonType: "date" }
      }
    }
  }
});

db.evaluacion_espacio.createIndex({ asignacion_id: 1 }, { name: "idx_eval_asignacion" });

// ============================================================
// MÓDULO 15 — NOTIFICACIONES Y TRAZABILIDAD
// ============================================================

db.createCollection("notificacion", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["usuario_id", "tipo", "titulo", "mensaje", "leido", "creado_en"],
      properties: {
        _id:         { bsonType: "objectId" },
        usuario_id:  { bsonType: "objectId" },
        tipo:        { bsonType: "string", enum: ["conflicto", "extension", "cancelacion", "revision", "vencimiento", "sistema"] },
        titulo:      { bsonType: "string" },
        mensaje:     { bsonType: "string" },
        leido:       { bsonType: "bool" },
        creado_en:   { bsonType: "date" },
        leido_en:    { bsonType: ["date", "null"] }
      }
    }
  }
});

db.notificacion.createIndex({ usuario_id: 1, leido: 1, creado_en: -1 }, { name: "idx_notificacion_usuario_leido" });

// ============================================================
// MÓDULO 16 — REPORTES Y EXPORTACIONES (propuesto)
// ============================================================

db.createCollection("reporte_configuracion", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre", "tipo", "modulo", "activo", "creado_en"],
      properties: {
        _id:       { bsonType: "objectId" },
        nombre:    { bsonType: "string" },
        tipo:      { bsonType: "string", enum: ["pdf", "excel"] },
        modulo:    { bsonType: "string" },
        activo:    { bsonType: "bool" },
        creado_en: { bsonType: "date" }
      }
    }
  }
});

db.reporte_configuracion.createIndex({ modulo: 1, tipo: 1 }, { name: "idx_reporte_modulo_tipo" });

// Datos iniciales de reportes base
db.reporte_configuracion.insertMany([
  { nombre: "Horario semanal por ficha",      tipo: "pdf",   modulo: "ficha",      activo: true, creado_en: new Date() },
  { nombre: "Listado de instructores",        tipo: "excel", modulo: "instructor", activo: true, creado_en: new Date() },
  { nombre: "Ocupación de ambientes",         tipo: "excel", modulo: "ambiente",   activo: true, creado_en: new Date() },
  { nombre: "Conflictos detectados",          tipo: "pdf",   modulo: "conflicto",  activo: true, creado_en: new Date() },
  { nombre: "Proyectos formativos activos",   tipo: "excel", modulo: "proyecto",   activo: true, creado_en: new Date() }
]);

// ============================================================
// MÓDULO 17 — ASISTENTE IA CON CONTEXTO (propuesto)
// ============================================================

db.createCollection("fragmento_documento", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre_archivo", "texto", "activo", "creado_en"],
      properties: {
        _id:               { bsonType: "objectId" },
        nombre_archivo:    { bsonType: "string" },
        texto:             { bsonType: "string" },
        vector_id:         { bsonType: ["string", "null"], description: "ID en servicio externo Qdrant" },
        modulo_referencia: { bsonType: ["string", "null"] },
        activo:            { bsonType: "bool" },
        creado_en:         { bsonType: "date" }
      }
    }
  }
});

db.fragmento_documento.createIndex({ nombre_archivo: 1 }, { name: "idx_fragmento_archivo" });
db.fragmento_documento.createIndex({ modulo_referencia: 1, activo: 1 }, { name: "idx_fragmento_modulo" });

// ------------------------------------------------------------

db.createCollection("consulta_ia", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["usuario_id", "pregunta", "respuesta", "modelo", "creado_en"],
      properties: {
        _id:               { bsonType: "objectId" },
        usuario_id:        { bsonType: "objectId" },
        pregunta:          { bsonType: "string" },
        respuesta:         { bsonType: "string" },
        fragmentos_usados: { bsonType: ["array", "null"] },
        modelo:            { bsonType: "string" },
        tokens_usados:     { bsonType: ["int", "null"], minimum: 0 },
        creado_en:         { bsonType: "date" }
      }
    }
  }
});

db.consulta_ia.createIndex({ usuario_id: 1, creado_en: -1 }, { name: "idx_consulta_ia_usuario" });

// ============================================================
// VERIFICACIÓN FINAL
// ============================================================

print("\n========================================");
print("SENA Schedule Manager — Schema creado");
print("========================================");

const colecciones = db.getCollectionNames();
print("Total colecciones: " + colecciones.length);
print("\nColecciones creadas:");
colecciones.sort().forEach(c => print("  ✓ " + c));

print("\nÍndices por colección:");
colecciones.sort().forEach(c => {
  const indices = db.getCollection(c).getIndexes();
  print("  " + c + ": " + indices.length + " índice(s)");
});

print("\nScript completado exitosamente.");
