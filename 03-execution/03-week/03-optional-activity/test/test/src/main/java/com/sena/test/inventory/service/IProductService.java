package com.sena.test.inventory.service;

import com.sena.test.inventory.entity.Product;
import java.util.List;
import java.util.Optional;

public interface IProductService {
    List<Product> getAll();
    Optional<Product> getById(Long id);
    Product save(Product product);
    Product update(Long id, Product product);
    void delete(Long id);
}