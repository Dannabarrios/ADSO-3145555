package com.sena.test.security.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;


@Entity
@Table(name="product")
public class Product {
	
	 @Id
	    @GeneratedValue(strategy = GenerationType.IDENTITY)
	    private Long id;

	    @Column(name = "name", nullable = false)
	    private String name;

	    @Column(name = "description")
	    private String description;
	    
	    @Column(name = "price", nullable = false)
	    private BigDecimal price;

	    @Column(name = "stock")
	    private Integer stock;
	    
	    @Column(name = "available")
	    private Boolean available;

	    @ManyToOne
	    @JoinColumn(name = "category_id")
	    private Category category;
	    
	    //Getters y Setters
	    public Long getId() { return id; }
	    public void setId(Long id) { this.id = id; }

	    public String getName() { return name; }
	    public void setName(String name) { this.name = name; }

	    public String getDescription() { return description; }
	    public void setDescription(String description) { this.description = description; }

	    public BigDecimal getPrice() { return price; }
	    public void setPrice(BigDecimal price) { this.price = price; }

	    public Integer getStock() { return stock; }
	    public void setStock(Integer stock) { this.stock = stock; }

	    public Boolean getAvailable() { return available; }
	    public void setAvailable(Boolean available) { this.available = available; }

	    public Category getCategory() { return category; }
	    public void setCategory(Category category) { this.category = category; }
}
