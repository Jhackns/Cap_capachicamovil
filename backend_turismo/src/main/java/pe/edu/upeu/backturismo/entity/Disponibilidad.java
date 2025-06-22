package pe.edu.upeu.backturismo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "disponibilidad",
        uniqueConstraints = @UniqueConstraint(columnNames = {"alojamiento_id", "fecha"}))
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Disponibilidad {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "alojamiento_id", nullable = false)
    private Alojamiento alojamiento;

    @Column(nullable = false)
    private LocalDate fecha;

    @Column(columnDefinition = "BOOLEAN DEFAULT TRUE")
    private Boolean disponible = true;

    @Column(name = "precio_especial", precision = 10, scale = 2)
    private BigDecimal precioEspecial;

    @Column(name = "minimo_noches")
    private Integer minimoNoches = 1;

    @Enumerated(EnumType.STRING)
    @Column(name = "bloqueado_por", length = 50)
    private MotivoBoloqueo bloqueadoPor;

    @Column(columnDefinition = "TEXT")
    private String notas;

    @Column(name = "created_at")
    @CreationTimestamp
    private LocalDateTime createdAt;

    // Enum para motivos de bloqueo
    public enum MotivoBoloqueo {
        ANFITRION("anfitrion"),
        MANTENIMIENTO("mantenimiento"),
        RESERVA("reserva");

        private final String valor;

        MotivoBoloqueo(String valor) {
            this.valor = valor;
        }

        public String getValor() {
            return valor;
        }
    }

    // Constructor de utilidad
    public Disponibilidad(Alojamiento alojamiento, LocalDate fecha, Boolean disponible) {
        this.alojamiento = alojamiento;
        this.fecha = fecha;
        this.disponible = disponible;
        this.minimoNoches = 1;
    }

    // Método de utilidad
    public BigDecimal getPrecioFinal() {
        return precioEspecial != null ? precioEspecial : alojamiento.getPrecioNoche();
    }
}