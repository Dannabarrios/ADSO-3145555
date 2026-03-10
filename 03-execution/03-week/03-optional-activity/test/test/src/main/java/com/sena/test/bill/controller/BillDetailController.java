package com.sena.test.bill.controller;

import com.sena.test.bill.entity.BillDetail;
import com.sena.test.bill.service.IBillDetailService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/billdetail")
public class BillDetailController {

    @Autowired
    private IBillDetailService billDetailService;

    @GetMapping
    public ResponseEntity<List<BillDetail>> getAll() {
        return ResponseEntity.ok(billDetailService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<BillDetail> getById(@PathVariable Long id) {
        return billDetailService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<BillDetail> save(@RequestBody BillDetail billDetail) {
        return ResponseEntity.ok(billDetailService.save(billDetail));
    }

    @PutMapping("/{id}")
    public ResponseEntity<BillDetail> update(@PathVariable Long id, @RequestBody BillDetail billDetail) {
        return ResponseEntity.ok(billDetailService.update(id, billDetail));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        billDetailService.delete(id);
        return ResponseEntity.noContent().build();
    }
}