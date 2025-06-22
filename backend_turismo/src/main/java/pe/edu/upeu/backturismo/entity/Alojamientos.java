package pe.edu.upeu.backturismo.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.JoinColumn;

@Entity
public class Alojamientos {
    @Id
    private Long id;
    private String nombre;
    private String descripcion;
    @ManyToOne
    @JoinColumn(name = "categoria_id")
    private CategoriaAlojamiento categoria;
    // Add other fields as needed (e.g., precio, ubicación)

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public CategoriaAlojamiento getCategoria() { return categoria; }
    public void setCategoria(CategoriaAlojamiento categoria) { this.categoria = categoria; }
}
