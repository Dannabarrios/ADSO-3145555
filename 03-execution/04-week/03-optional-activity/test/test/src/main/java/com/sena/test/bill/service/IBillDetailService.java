package com.sena.test.bill.service;

import com.sena.test.bill.entity.BillDetail;
import java.util.List;
import java.util.Optional;

public interface IBillDetailService {
    List<BillDetail> getAll();
    Optional<BillDetail> getById(Long id);
    BillDetail save(BillDetail billDetail);
    BillDetail update(Long id, BillDetail billDetail);
    void delete(Long id);
}