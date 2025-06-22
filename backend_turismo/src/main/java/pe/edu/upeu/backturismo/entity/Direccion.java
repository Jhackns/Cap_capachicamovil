package pe.edu.upeu.backturismo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "direcciones")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Direccion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    private TipoDireccion tipo;

    @Column(length = 100)
    private String departamento = "Puno";

    @Column(length = 100)
    private String provincia = "Puno";

    @Column(length = 100)
    private String distrito = "Capachica";

    @Column(name = "direccion_completa", nullable = false, columnDefinition = "TEXT")
    private String direccionCompleta;

    @Column(columnDefinition = "TEXT")
    private String referencia;

    @Column(precision = 10, scale = 8)
    private BigDecimal latitud;

    @Column(precision = 11, scale = 8)
    private BigDecimal longitud;

    @Column(name = "es_principal", columnDefinition = "BOOLEAN DEFAULT FALSE")
    private Boolean esPrincipal = false;

    @Column(name = "created_at")
    @CreationTimestamp
    private LocalDateTime createdAt;

    // Enum para tipo de dirección
    public enum TipoDireccion {
        PRINCIPAL("principal"),
        SECUNDARIA("secundaria");

        private final String valor;

        TipoDireccion(String valor) {
            this.valor = valor;
        }

        public String getValor() {
            return valor;
        }
    }

    // Método de utilidad
    public String getDireccionCompleta() {
        StringBuilder direccion = new StringBuilder();
        if (direccionCompleta != null) direccion.append(direccionCompleta);
        if (distrito != null) direccion.append(", ").append(distrito);
        if (provincia != null) direccion.append(", ").append(provincia);
        if (departamento != null) direccion.append(", ").append(departamento);
        return direccion.toString();
    }
}