package com.sena.test.sales.entity;

import com.sena.test.security.entity.Person;
import com.sena.test.utils.AuditEntity;
import jakarta.persistence.*;
import java.util.List;

/**
 * Módulo: Sales
 * Tabla: customer
 * Cliente de la cafetería (persona que hace pedidos).
 */
@Entity
@Table(name = "customer")
public class Customer extends AuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "person_id")
    private Person person;

    @Column(name = "loyalty_points")
    private Integer loyaltyPoints = 0;

    @OneToMany(mappedBy = "customer")
    private List<Order> orders;

    // ── Getters y Setters ──────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Person getPerson() { return person; }
    public void setPerson(Person person) { this.person = person; }

    public Integer getLoyaltyPoints() { return loyaltyPoints; }
    public void setLoyaltyPoints(Integer loyaltyPoints) { this.loyaltyPoints = loyaltyPoints; }

    public List<Order> getOrders() { return orders; }
    public void setOrders(List<Order> orders) { this.orders = orders; }
}
