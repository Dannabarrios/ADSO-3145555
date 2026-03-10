package com.sena.test.security.entity;

import com.sena.test.utils.AuditEntity;
import jakarta.persistence.*;

/**
 * Módulo: Security
 * Tabla: view
 * Representa las vistas/pantallas dentro de cada módulo.
 */
@Entity
@Table(name = "view")
public class View extends AuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false, length = 80)
    private String name;

    @Column(name = "route", length = 120)
    private String route;

    @ManyToOne
    @JoinColumn(name = "module_id")
    private Module module;

    // ── Getters y Setters ──────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getRoute() { return route; }
    public void setRoute(String route) { this.route = route; }

    public Module getModule() { return module; }
    public void setModule(Module module) { this.module = module; }
}
