package com.sena.test.security.entity;

import com.sena.test.utils.AuditEntity;
import jakarta.persistence.*;

/**
 * Módulo: Security
 * Tabla: module_view
 * Relación N:M entre Module y View.
 * Define qué vistas pertenecen a cada módulo.
 */
@Entity
@Table(name = "module_view",
       uniqueConstraints = @UniqueConstraint(columnNames = {"module_id", "view_id"}))
public class ModuleView extends AuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "module_id", nullable = false)
    private Module module;

    @ManyToOne
    @JoinColumn(name = "view_id", nullable = false)
    private View view;

    // ── Getters y Setters ──────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Module getModule() { return module; }
    public void setModule(Module module) { this.module = module; }

    public View getView() { return view; }
    public void setView(View view) { this.view = view; }
}
