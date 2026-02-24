package com.sena.test.service;

import com.sena.test.entity.Role;
import java.util.List;
import java.util.Optional;

public interface IRoleService {
    List<Role> getAll();
    Optional<Role> getById(Long id);
    Role save(Role role);
    Role update(Long id, Role role);
    void delete(Long id);
}