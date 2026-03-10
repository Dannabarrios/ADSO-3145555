package com.sena.test.inventory.service;

import com.sena.test.inventory.entity.Category;
import java.util.List;
import java.util.Optional;

public interface ICategoryService {
    List<Category> getAll();
    Optional<Category> getById(Long id);
    Category save(Category category);
    Category update(Long id, Category category);
    void delete(Long id);
}