package pe.edu.upeu.backturismo.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "emprendedores")
public class Emprendedor {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Nombre is required")
    @Size(max = 100, message = "Nombre must be less than 100 characters")
    @Column(nullable = false)
    private String nombre;

    @NotBlank(message = "Tipo de servicio is required")
    @Column(name = "tipo_servicio", nullable = false)
    private String tipoServicio;

    @NotBlank(message = "Descripción is required")
    @Column(nullable = false)
    private String descripcion;

    @NotBlank(message = "Ubicación is required")
    @Column(nullable = false)
    private String ubicacion;

    @NotBlank(message = "Teléfono is required")
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "Invalid phone number")
    @Column(nullable = false)
    private String telefono;

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    @Column(nullable = false)
    private String email;

    @NotBlank(message = "Horario de atención is required")
    @Column(name = "horario_atencion", nullable = false)
    private String horarioAtencion;

    @NotBlank(message = "Precio rango is required")
    @Column(name = "precio_rango", nullable = false)
    private String precioRango;

    @NotBlank(message = "Categoría is required")
    @Column(nullable = false)
    private String categoria;

    @Column
    private String imagenes;

    @Column(nullable = false)
    private boolean estado = true;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getTipoServicio() { return tipoServicio; }
    public void setTipoServicio(String tipoServicio) { this.tipoServicio = tipoServicio; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public String getUbicacion() { return ubicacion; }
    public void setUbicacion(String ubicacion) { this.ubicacion = ubicacion; }
    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getHorarioAtencion() { return horarioAtencion; }
    public void setHorarioAtencion(String horarioAtencion) { this.horarioAtencion = horarioAtencion; }
    public String getPrecioRango() { return precioRango; }
    public void setPrecioRango(String precioRango) { this.precioRango = precioRango; }
    public String getCategoria() { return categoria; }
    public void setCategoria(String categoria) { this.categoria = categoria; }
    public String getImagenes() { return imagenes; }
    public void setImagenes(String imagenes) { this.imagenes = imagenes; }
    public boolean isEstado() { return estado; }
    public void setEstado(boolean estado) { this.estado = estado; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}