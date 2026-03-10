package com.sena.test.bill.service.impl;

import com.sena.test.bill.entity.BillDetail;
import com.sena.test.bill.repository.IBillDetailRepository;
import com.sena.test.bill.service.IBillDetailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class BillDetailService implements IBillDetailService {

    @Autowired
    private IBillDetailRepository billDetailRepository;

    @Override
    public List<BillDetail> getAll() {
        return billDetailRepository.findAll();
    }

    @Override
    public Optional<BillDetail> getById(Long id) {
        return billDetailRepository.findById(id);
    }

    @Override
    public BillDetail save(BillDetail billDetail) {
        return billDetailRepository.save(billDetail);
    }

    @Override
    public BillDetail update(Long id, BillDetail billDetail) {
        billDetail.setId(id);
        return billDetailRepository.save(billDetail);
    }

    @Override
    public void delete(Long id) {
        billDetailRepository.deleteById(id);
    }
}