package com.sena.test.security.service;

import java.util.List;
import java.util.Optional;

import com.sena.test.security.entity.Person;

public interface IPersonService {
    List<Person> getAll();
    Optional<Person> getById(Long id);
    Person save(Person person);
    Person update(Long id, Person person);
    void delete(Long id);
}
