package com.sena.test.security.service.impl;

import com.sena.test.security.entity.UserRole;
import com.sena.test.security.repository.IUserRoleRepository;
import com.sena.test.security.service.IUserRoleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class UserRoleService implements IUserRoleService {

    @Autowired
    private IUserRoleRepository userRoleRepository;

    @Override
    public List<UserRole> getAll() {
        return userRoleRepository.findAll();
    }

    @Override
    public Optional<UserRole> getById(Long id) {
        return userRoleRepository.findById(id);
    }

    @Override
    public UserRole save(UserRole userRole) {
        return userRoleRepository.save(userRole);
    }

    @Override
    public UserRole update(Long id, UserRole userRole) {
        userRole.setId(id);
        return userRoleRepository.save(userRole);
    }

    @Override
    public void delete(Long id) {
        userRoleRepository.deleteById(id);
    }
}