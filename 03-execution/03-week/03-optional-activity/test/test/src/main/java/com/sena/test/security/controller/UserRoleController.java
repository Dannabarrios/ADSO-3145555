package com.sena.test.security.controller;

import com.sena.test.security.entity.UserRole;
import com.sena.test.security.service.IUserRoleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/userrole")
public class UserRoleController {

    @Autowired
    private IUserRoleService userRoleService;

    @GetMapping
    public ResponseEntity<List<UserRole>> getAll() {
        return ResponseEntity.ok(userRoleService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserRole> getById(@PathVariable Long id) {
        return userRoleService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<UserRole> save(@RequestBody UserRole userRole) {
        return ResponseEntity.ok(userRoleService.save(userRole));
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserRole> update(@PathVariable Long id, @RequestBody UserRole userRole) {
        return ResponseEntity.ok(userRoleService.update(id, userRole));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        userRoleService.delete(id);
        return ResponseEntity.noContent().build();
    }
}