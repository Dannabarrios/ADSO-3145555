package com.sena.test.bill.service.impl;

import com.sena.test.bill.entity.Bill;
import com.sena.test.bill.repository.IBillRepository;
import com.sena.test.bill.service.IBillService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class BillService implements IBillService {

    @Autowired
    private IBillRepository billRepository;

    @Override
    public List<Bill> getAll() {
        return billRepository.findAll();
    }

    @Override
    public Optional<Bill> getById(Long id) {
        return billRepository.findById(id);
    }

    @Override
    public Bill save(Bill bill) {
        return billRepository.save(bill);
    }

    @Override
    public Bill update(Long id, Bill bill) {
        bill.setId(id);
        return billRepository.save(bill);
    }

    @Override
    public void delete(Long id) {
        billRepository.deleteById(id);
    }
}