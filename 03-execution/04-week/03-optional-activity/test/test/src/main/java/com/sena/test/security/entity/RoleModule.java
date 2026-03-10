package com.sena.test.security.entity;

import com.sena.test.utils.AuditEntity;
import jakarta.persistence.*;

/**
 * Módulo: Security
 * Tabla: role_module
 * Relación N:M entre Role y Module.
 * Define qué módulos puede ver cada rol.
 */
@Entity
@Table(name = "role_module",
       uniqueConstraints = @UniqueConstraint(columnNames = {"role_id", "module_id"}))
public class RoleModule extends AuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "role_id", nullable = false)
    private Role role;

    @ManyToOne
    @JoinColumn(name = "module_id", nullable = false)
    private Module module;

    // ── Getters y Setters ──────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }

    public Module getModule() { return module; }
    public void setModule(Module module) { this.module = module; }
}
