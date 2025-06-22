package pe.edu.upeu.backturismo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "alojamiento_servicios",
        uniqueConstraints = @UniqueConstraint(columnNames = {"alojamiento_id", "servicio_id"}))
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AlojamientoServicio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "alojamiento_id", nullable = false)
    private Alojamiento alojamiento;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servicio_id", nullable = false)
    private Servicio servicio;

    @Column(columnDefinition = "BOOLEAN DEFAULT TRUE")
    private Boolean disponible = true;

    // Constructor de utilidad
    public AlojamientoServicio(Alojamiento alojamiento, Servicio servicio) {
        this.alojamiento = alojamiento;
        this.servicio = servicio;
        this.disponible = true;
    }
}