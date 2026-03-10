package com.sena.test.inventory.entity;

import com.sena.test.utils.AuditEntity;
import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Módulo: Inventory
 * Tabla: inventory
 * Control de stock actual de cada producto.
 */
@Entity
@Table(name = "inventory")
public class Inventory extends AuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "stock", nullable = false)
    private Integer stock = 0;

    @Column(name = "min_stock")
    private Integer minStock = 5;

    @Column(name = "max_stock")
    private Integer maxStock = 100;

    @Column(name = "last_updated")
    private LocalDateTime lastUpdated;

    @PrePersist
    @PreUpdate
    protected void onUpdate() {
        this.lastUpdated = LocalDateTime.now();
    }

    // ── Getters y Setters ──────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }

    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }

    public Integer getMinStock() { return minStock; }
    public void setMinStock(Integer minStock) { this.minStock = minStock; }

    public Integer getMaxStock() { return maxStock; }
    public void setMaxStock(Integer maxStock) { this.maxStock = maxStock; }

    public LocalDateTime getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(LocalDateTime lastUpdated) { this.lastUpdated = lastUpdated; }
}
