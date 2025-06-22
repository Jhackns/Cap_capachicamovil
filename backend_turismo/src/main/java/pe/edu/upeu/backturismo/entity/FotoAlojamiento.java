package pe.edu.upeu.backturismo.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "fotos_alojamiento")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FotoAlojamiento {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "alojamiento_id", nullable = false)
    private Alojamiento alojamiento;

    @Column(name = "url_foto", nullable = false, columnDefinition = "TEXT")
    private String urlFoto;

    @Column(columnDefinition = "TEXT")
    private String descripcion;

    @Column(name = "es_principal", columnDefinition = "BOOLEAN DEFAULT FALSE")
    private Boolean esPrincipal = false;

    @Column(columnDefinition = "INTEGER DEFAULT 0")
    private Integer orden = 0;

    @Column(columnDefinition = "BOOLEAN DEFAULT TRUE")
    private Boolean activo = true;

    @Column(name = "uploaded_at")
    @CreationTimestamp
    private LocalDateTime uploadedAt;

    // Constructor de utilidad
    public FotoAlojamiento(Alojamiento alojamiento, String urlFoto, Boolean esPrincipal) {
        this.alojamiento = alojamiento;
        this.urlFoto = urlFoto;
        this.esPrincipal = esPrincipal;
        this.activo = true;
        this.orden = 0;
    }
}