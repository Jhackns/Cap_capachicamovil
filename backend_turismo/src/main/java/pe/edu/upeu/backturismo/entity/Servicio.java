package pe.edu.upeu.backturismo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Entity
@Table(name = "servicios")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Servicio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String nombre;

    @Column(columnDefinition = "TEXT")
    private String descripcion;

    @Column(length = 100)
    private String icono;

    @Enumerated(EnumType.STRING)
    @Column(length = 50)
    private CategoriaServicio categoria;

    @Column(columnDefinition = "BOOLEAN DEFAULT TRUE")
    private Boolean activo = true;

    // Relaciones
    @OneToMany(mappedBy = "servicio", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<AlojamientoServicio> alojamientoServicios;

    // Enum para categorías de servicios
    public enum CategoriaServicio {
        BASICO("basico"),
        ENTRETENIMIENTO("entretenimiento"),
        FAMILIAR("familiar"),
        ACCESIBILIDAD("accesibilidad"),
        CULTURAL("cultural");

        private final String valor;

        CategoriaServicio(String valor) {
            this.valor = valor;
        }

        public String getValor() {
            return valor;
        }
    }

    // Constructor de utilidad
    public Servicio(String nombre, CategoriaServicio categoria) {
        this.nombre = nombre;
        this.categoria = categoria;
        this.activo = true;
    }
}