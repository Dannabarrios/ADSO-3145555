package com.sena.test.service;

import com.sena.test.entity.User;
import java.util.List;
import java.util.Optional;

public interface IUserService {
    List<User> getAll();
    Optional<User> getById(Long id);
    User save(User user);
    User update(Long id, User user);
    void delete(Long id);
}