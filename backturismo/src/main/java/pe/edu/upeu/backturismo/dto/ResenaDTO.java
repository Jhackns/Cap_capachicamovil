package pe.edu.upeu.backturismo.dto;

import java.time.LocalDateTime;

public class ResenaDTO {
    private Long id;
    private String nombreAutor;
    private String comentario;
    private Integer puntuacion;
    private String imagenes;
    private Long emprendedorId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructor vacío
    public ResenaDTO() {}

    // Constructor con todos los campos
    public ResenaDTO(Long id, String nombreAutor, String comentario, Integer puntuacion, 
                    String imagenes, Long emprendedorId, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.nombreAutor = nombreAutor;
        this.comentario = comentario;
        this.puntuacion = puntuacion;
        this.imagenes = imagenes;
        this.emprendedorId = emprendedorId;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNombreAutor() { return nombreAutor; }
    public void setNombreAutor(String nombreAutor) { this.nombreAutor = nombreAutor; }
    public String getComentario() { return comentario; }
    public void setComentario(String comentario) { this.comentario = comentario; }
    public Integer getPuntuacion() { return puntuacion; }
    public void setPuntuacion(Integer puntuacion) { this.puntuacion = puntuacion; }
    public String getImagenes() { return imagenes; }
    public void setImagenes(String imagenes) { this.imagenes = imagenes; }
    public Long getEmprendedorId() { return emprendedorId; }
    public void setEmprendedorId(Long emprendedorId) { this.emprendedorId = emprendedorId; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
} 