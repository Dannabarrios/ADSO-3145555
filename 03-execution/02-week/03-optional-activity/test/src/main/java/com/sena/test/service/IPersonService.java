package com.sena.test.service;

import com.sena.test.entity.Person;
import java.util.List;
import java.util.Optional;

public interface IPersonService {
    List<Person> getAll();
    Optional<Person> getById(Long id);
    Person save(Person person);
    Person update(Long id, Person person);
    void delete(Long id);
}
