package pe.edu.upeu.backturismo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Entity
@Table(name = "alojamientos")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Alojamiento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "anfitrion_id", nullable = false)
    private Usuario anfitrion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "categoria_id", nullable = false)
    private CategoriaAlojamiento categoria;

    @Column(nullable = false, length = 255)
    private String titulo;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String descripcion;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_propiedad", nullable = false, length = 50)
    private TipoPropiedad tipoPropiedad;

    // Ubicación
    @Column(length = 100)
    private String departamento = "Puno";

    @Column(length = 100)
    private String provincia = "Puno";

    @Column(length = 100)
    private String distrito = "Capachica";

    @Column(length = 100)
    private String comunidad;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String direccion;

    @Column(nullable = false, precision = 10, scale = 8)
    private BigDecimal latitud;

    @Column(nullable = false, precision = 11, scale = 8)
    private BigDecimal longitud;

    // Capacidad
    @Column(name = "max_huespedes", nullable = false)
    private Integer maxHuespedes = 1;

    @Column(name = "num_habitaciones", nullable = false)
    private Integer numHabitaciones = 1;

    @Column(name = "num_camas", nullable = false)
    private Integer numCamas = 1;

    @Column(name = "num_banos", nullable = false, precision = 3, scale = 1)
    private BigDecimal numBanos = BigDecimal.ONE;

    // Precios
    @Column(name = "precio_noche", nullable = false, precision = 10, scale = 2)
    private BigDecimal precioNoche;

    @Column(name = "precio_limpieza", precision = 10, scale = 2)
    private BigDecimal precioLimpieza = BigDecimal.ZERO;

    @Column(name = "precio_servicio", precision = 10, scale = 2)
    private BigDecimal precioServicio = BigDecimal.ZERO;

    @Column(name = "descuento_semanal", precision = 5, scale = 2)
    private BigDecimal descuentoSemanal = BigDecimal.ZERO;

    @Column(name = "descuento_mensual", precision = 5, scale = 2)
    private BigDecimal descuentoMensual = BigDecimal.ZERO;

    // Políticas
    @Enumerated(EnumType.STRING)
    @Column(name = "politica_cancelacion", length = 50)
    private PoliticaCancelacion politicaCancelacion = PoliticaCancelacion.FLEXIBLE;

    @Column(name = "checkin_desde")
    private LocalTime checkinDesde = LocalTime.of(15, 0);

    @Column(name = "checkin_hasta")
    private LocalTime checkinHasta = LocalTime.of(22, 0);

    @Column(name = "checkout_hasta")
    private LocalTime checkoutHasta = LocalTime.of(11, 0);

    @Column(name = "estancia_minima")
    private Integer estanciaMinima = 1;

    @Column(name = "estancia_maxima")
    private Integer estanciaMaxima = 365;

    // Reglas
    @Column(name = "permite_mascotas", columnDefinition = "BOOLEAN DEFAULT FALSE")
    private Boolean permiteMascotas = false;

    @Column(name = "permite_fumar", columnDefinition = "BOOLEAN DEFAULT FALSE")
    private Boolean permiteFumar = false;

    @Column(name = "permite_fiestas", columnDefinition = "BOOLEAN DEFAULT FALSE")
    private Boolean permiteFiestas = false;

    @Column(name = "permite_ninos", columnDefinition = "BOOLEAN DEFAULT TRUE")
    private Boolean permiteNinos = true;

    // Status
    @Column(columnDefinition = "BOOLEAN DEFAULT TRUE")
    private Boolean activo = true;

    @Column(columnDefinition = "BOOLEAN DEFAULT FALSE")
    private Boolean verificado = false;

    @Column(columnDefinition = "BOOLEAN DEFAULT TRUE")
    private Boolean disponible = true;

    // Metadatos
    @Column(name = "created_at")
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    @UpdateTimestamp
    private LocalDateTime updatedAt;

    @Column(name = "fecha_primera_reserva")
    private LocalDateTime fechaPrimeraReserva;

    // Relaciones
    @OneToMany(mappedBy = "alojamiento", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<AlojamientoServicio> servicios;

    @OneToMany(mappedBy = "alojamiento", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<FotoAlojamiento> fotos;

    @OneToMany(mappedBy = "alojamiento", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Disponibilidad> disponibilidades;

    @OneToMany(mappedBy = "alojamiento", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Reserva> reservas;

    @OneToMany(mappedBy = "alojamiento", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Favoritos> favoritos;
    @ManyToOne
    @JoinColumn(name = "emprendedor_id", nullable = false)
    private Emprendedor emprendedor;
    // Enums
    public enum TipoPropiedad {
        CASA_COMPLETA("casa_completa"),
        HABITACION_PRIVADA("habitacion_privada"),
        HABITACION_COMPARTIDA("habitacion_compartida");

        private final String valor;

        TipoPropiedad(String valor) {
            this.valor = valor;
        }

        public String getValor() {
            return valor;
        }
    }

    public enum PoliticaCancelacion {
        FLEXIBLE("flexible"),
        MODERADA("moderada"),
        ESTRICTA("estricta");

        private final String valor;

        PoliticaCancelacion(String valor) {
            this.valor = valor;
        }

        public String getValor() {
            return valor;
        }
    }

    // Métodos de utilidad
    public String getUbicacionCompleta() {
        StringBuilder ubicacion = new StringBuilder();
        if (comunidad != null) ubicacion.append(comunidad).append(", ");
        ubicacion.append(distrito).append(", ").append(provincia).append(", ").append(departamento);
        return ubicacion.toString();
    }

    public BigDecimal getPrecioTotal() {
        return precioNoche.add(precioLimpieza).add(precioServicio);
    }

    public boolean isDisponible() {
        return activo && disponible && verificado;
    }
}