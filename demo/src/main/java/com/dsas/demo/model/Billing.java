package main.java.com.dsas.demo.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Billing {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long billId;

    @ManyToOne
    @JoinColumn(name = "patient_id")
    private Patient patient;

    private double amount;
    private String paymentStatus; // Paid, Unpaid
    private String paymentMethod;
    private LocalDate date;
}
