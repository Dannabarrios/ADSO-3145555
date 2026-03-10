package com.sena.test.bill.controller;

import com.sena.test.bill.entity.Bill;
import com.sena.test.bill.service.IBillService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/bill")
public class BillController {

    @Autowired
    private IBillService billService;

    @GetMapping
    public ResponseEntity<List<Bill>> getAll() {
        return ResponseEntity.ok(billService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Bill> getById(@PathVariable Long id) {
        return billService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Bill> save(@RequestBody Bill bill) {
        return ResponseEntity.ok(billService.save(bill));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Bill> update(@PathVariable Long id, @RequestBody Bill bill) {
        return ResponseEntity.ok(billService.update(id, bill));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        billService.delete(id);
        return ResponseEntity.noContent().build();
    }
}