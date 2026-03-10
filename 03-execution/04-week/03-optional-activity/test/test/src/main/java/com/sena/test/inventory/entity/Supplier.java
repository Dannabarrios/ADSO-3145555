package com.sena.test.inventory.entity;

import com.sena.test.utils.AuditEntity;
import jakarta.persistence.*;

/**
 * Módulo: Inventory
 * Tabla: supplier
 * Proveedores de productos para la cafetería.
 */
@Entity
@Table(name = "supplier")
public class Supplier extends AuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false, length = 120)
    private String name;

    @Column(name = "email", length = 120)
    private String email;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "address", length = 255)
    private String address;

    @Column(name = "nit", unique = true, length = 30)
    private String nit;

    // ── Getters y Setters ──────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getNit() { return nit; }
    public void setNit(String nit) { this.nit = nit; }
}
