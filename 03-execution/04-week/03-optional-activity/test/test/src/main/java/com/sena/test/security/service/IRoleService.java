package com.sena.test.security.service;

import java.util.List;
import java.util.Optional;

import com.sena.test.security.entity.Role;

public interface IRoleService {
    List<Role> getAll();
    Optional<Role> getById(Long id);
    Role save(Role role);
    Role update(Long id, Role role);
    void delete(Long id);
}