package com.sena.test.billing.entity;

import com.sena.test.utils.AuditEntity;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Módulo: Billing
 * Tabla: payment
 * Registro del pago de una factura con un método de pago.
 */
@Entity
@Table(name = "payment")
public class Payment extends AuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "invoice_id", nullable = false)
    private Invoice invoice;

    @ManyToOne
    @JoinColumn(name = "method_payment_id", nullable = false)
    private MethodPayment methodPayment;

    @Column(name = "amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal amount;

    @Column(name = "payment_date")
    private LocalDateTime paymentDate;

    @Column(name = "reference", length = 80)
    private String reference;

    @PrePersist
    protected void onCreate() {
        this.paymentDate = LocalDateTime.now();
    }

    // ── Getters y Setters ──────────────────────────────────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Invoice getInvoice() { return invoice; }
    public void setInvoice(Invoice invoice) { this.invoice = invoice; }

    public MethodPayment getMethodPayment() { return methodPayment; }
    public void setMethodPayment(MethodPayment methodPayment) { this.methodPayment = methodPayment; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public LocalDateTime getPaymentDate() { return paymentDate; }
    public void setPaymentDate(LocalDateTime paymentDate) { this.paymentDate = paymentDate; }

    public String getReference() { return reference; }
    public void setReference(String reference) { this.reference = reference; }
}
