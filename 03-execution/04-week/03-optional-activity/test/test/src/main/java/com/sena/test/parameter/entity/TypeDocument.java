package com.sena.test.parameter.entity;

import com.sena.test.utils.AuditEntity;
import jakarta.persistence.*;

/**
 * Módulo: Parameter
 * Tabla: type_document
 * Tipos de documento: CC, TI, CE, Pasaporte, etc.
 */
@Entity
@Table(name = "type_document")
public class TypeDocument extends AuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", nullable = false, unique = true, length = 10)
    private String code;

    @Column(name = "name", nullable = false, length = 80)
    private String name;

    @Column(name = "description", length = 255)
    private String description;

    // ── Getters y Setters ──────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
