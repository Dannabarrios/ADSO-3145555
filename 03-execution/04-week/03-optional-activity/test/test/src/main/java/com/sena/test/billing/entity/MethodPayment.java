package com.sena.test.billing.entity;

import com.sena.test.utils.AuditEntity;
import jakarta.persistence.*;

/**
 * Módulo: Billing
 * Tabla: method_payment
 * Métodos de pago disponibles: Efectivo, Nequi, Daviplata, etc.
 */
@Entity
@Table(name = "method_payment")
public class MethodPayment extends AuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false, unique = true, length = 60)
    private String name;

    @Column(name = "description", length = 255)
    private String description;

    // ── Getters y Setters ──────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
