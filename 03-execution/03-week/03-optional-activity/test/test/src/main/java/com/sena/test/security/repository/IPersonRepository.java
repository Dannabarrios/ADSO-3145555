package com.sena.test.security.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.sena.test.security.entity.Person;

@Repository
public interface IPersonRepository extends JpaRepository<Person, Long> {
}
