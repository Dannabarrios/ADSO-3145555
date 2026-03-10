package com.sena.test.security.service;

import com.sena.test.security.entity.UserRole;
import java.util.List;
import java.util.Optional;

public interface IUserRoleService {
    List<UserRole> getAll();
    Optional<UserRole> getById(Long id);
    UserRole save(UserRole userRole);
    UserRole update(Long id, UserRole userRole);
    void delete(Long id);
}