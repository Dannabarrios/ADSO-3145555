package com.sena.test.bill.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class BillDTO {
    private Long id;
    private LocalDateTime date;
    private BigDecimal total;
    private String status;
    private Long userId;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public LocalDateTime getDate() { return date; }
    public void setDate(LocalDateTime date) { this.date = date; }

    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
}