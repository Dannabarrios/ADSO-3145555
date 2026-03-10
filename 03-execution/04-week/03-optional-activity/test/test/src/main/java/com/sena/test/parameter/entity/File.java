package com.sena.test.parameter.entity;

import com.sena.test.utils.AuditEntity;
import jakarta.persistence.*;

/**
 * Módulo: Parameter
 * Tabla: file
 * Archivos subidos asociados a personas (fotos, documentos).
 */
@Entity
@Table(name = "file")
public class File extends AuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false, length = 120)
    private String name;

    @Column(name = "path", nullable = false, length = 255)
    private String path;

    @Column(name = "mime_type", length = 80)
    private String mimeType;

    @Column(name = "size_kb")
    private Integer sizeKb;

    @ManyToOne
    @JoinColumn(name = "person_id")
    private Person person;

    // ── Getters y Setters ──────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getPath() { return path; }
    public void setPath(String path) { this.path = path; }

    public String getMimeType() { return mimeType; }
    public void setMimeType(String mimeType) { this.mimeType = mimeType; }

    public Integer getSizeKb() { return sizeKb; }
    public void setSizeKb(Integer sizeKb) { this.sizeKb = sizeKb; }

    public Person getPerson() { return person; }
    public void setPerson(Person person) { this.person = person; }
}
