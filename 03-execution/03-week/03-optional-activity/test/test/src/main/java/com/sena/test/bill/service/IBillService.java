package com.sena.test.bill.service;

import com.sena.test.bill.entity.Bill;
import java.util.List;
import java.util.Optional;

public interface IBillService {
    List<Bill> getAll();
    Optional<Bill> getById(Long id);
    Bill save(Bill bill);
    Bill update(Long id, Bill bill);
    void delete(Long id);
}