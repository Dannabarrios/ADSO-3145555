package com.sena.test.security.service;

import java.util.List;
import java.util.Optional;

import com.sena.test.security.entity.User;

public interface IUserService {
    List<User> getAll();
    Optional<User> getById(Long id);
    User save(User user);
    User update(Long id, User user);
    void delete(Long id);
}