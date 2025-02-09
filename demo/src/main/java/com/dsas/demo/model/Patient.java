package main.java.com.dsas.demo.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Patient {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long patientId;
    
    private String name;
    private int age;
    private String gender;
    private String contactNo;
    private String email;
    private String address;
    private String medicalHistory;
    private String insuranceDetails;
}
