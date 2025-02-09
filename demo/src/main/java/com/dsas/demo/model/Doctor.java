package main.java.com.dsas.demo.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Doctor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long doctorId;

    private String name;
    private String specialization;
    private String contactNo;
    private String email;
    private int experience;
    private String availableSlots;

    @ManyToOne
    @JoinColumn(name = "department_id")
    private Department department;  // Linking doctor to a department
}
