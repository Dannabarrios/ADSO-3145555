package com.sena.test.security.entity;

import com.sena.test.utils.AuditEntity;
import jakarta.persistence.*;
import java.util.List;

/**
 * Módulo: Security
 * Tabla: module
 * Representa los módulos del sistema (Security, Inventory, Sales, etc.)
 */
@Entity
@Table(name = "module")
public class Module extends AuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false, unique = true, length = 80)
    private String name;

    @Column(name = "description", length = 255)
    private String description;

    @Column(name = "icon", length = 80)
    private String icon;

    @Column(name = "route", length = 120)
    private String route;

    @OneToMany(mappedBy = "module")
    private List<ModuleView> moduleViews;

    // ── Getters y Setters ──────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }

    public String getRoute() { return route; }
    public void setRoute(String route) { this.route = route; }

    public List<ModuleView> getModuleViews() { return moduleViews; }
    public void setModuleViews(List<ModuleView> moduleViews) { this.moduleViews = moduleViews; }
}
