package main.java.com.dsas.demo.service;

import main.java.com.dsas.demo.model.Billing;
import main.java.com.dsas.demo.repository.BillingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class BillingService {

    @Autowired
    private BillingRepository billingRepository;

    public List<Billing> getAllBills() {
        return billingRepository.findAll();
    }

    public Billing getBillById(Long id) {
        return billingRepository.findById(id).orElse(null);
    }

    public Billing saveBill(Billing billing) {
        return billingRepository.save(billing);
    }

    public void deleteBill(Long id) {
        billingRepository.deleteById(id);
    }
}
