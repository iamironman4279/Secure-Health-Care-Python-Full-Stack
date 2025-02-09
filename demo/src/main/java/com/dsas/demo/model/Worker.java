package main.java.com.dsas.demo.model;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Worker {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long workerId;

    private String name;
    private String role;
    private String contactNo;
    private String email;
    private String shiftTimings;

    @ManyToOne
    @JoinColumn(name = "department_id")
    private Department assignedDepartment;
}
