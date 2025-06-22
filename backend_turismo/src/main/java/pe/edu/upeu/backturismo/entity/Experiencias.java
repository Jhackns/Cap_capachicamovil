package pe.edu.upeu.backturismo.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.JoinColumn;
import pe.edu.upeu.backturismo.entity.Usuario;

@Entity
public class Experiencias {
    @Id
    private Long id;
    private String nombre;
    private String descripcion;
    private Double precio;
    @ManyToOne
    @JoinColumn(name = "usuario_id")
    private Usuario usuario; // Assuming experiences are linked to users

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public Double getPrecio() { return precio; }
    public void setPrecio(Double precio) { this.precio = precio; }
    public Usuario getUsuario() { return usuario; }
    public void setUsuario(Usuario usuario) { this.usuario = usuario; }
}