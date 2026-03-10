package com.sena.test.security.entity;

import com.sena.test.parameter.entity.TypeDocument;
import com.sena.test.utils.AuditEntity;
import jakarta.persistence.*;

/**
 * Módulo: Security (actualizada)
 * Tabla: person
 * CAMBIO: ahora incluye type_document_id y document_number + auditoría
 */
@Entity
@Table(name = "person")
public class Person extends AuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "first_name", nullable = false, length = 80)
    private String firstName;

    @Column(name = "last_name", nullable = false, length = 80)
    private String lastName;

    @Column(name = "email", nullable = false, unique = true, length = 120)
    private String email;

    @Column(name = "phone", length = 20)
    private String phone;

    // ── Cambio: relación con TypeDocument ───────────────────
    @ManyToOne
    @JoinColumn(name = "type_document_id")
    private TypeDocument typeDocument;

    @Column(name = "document_number", nullable = false, unique = true, length = 30)
    private String documentNumber;

    // ── Getters y Setters ──────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public TypeDocument getTypeDocument() { return typeDocument; }
    public void setTypeDocument(TypeDocument typeDocument) { this.typeDocument = typeDocument; }

    public String getDocumentNumber() { return documentNumber; }
    public void setDocumentNumber(String documentNumber) { this.documentNumber = documentNumber; }
}
