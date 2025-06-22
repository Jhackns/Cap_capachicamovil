package pe.edu.upeu.backturismo.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.JoinColumn;
import pe.edu.upeu.backturismo.entity.Usuario;

@Entity
public class Mensajes{
    @Id
    private Long id;
    private String contenido;
    private java.time.LocalDateTime fecha;
    @ManyToOne
    @JoinColumn(name = "emisor_id")
    private Usuario emisor;
    @ManyToOne
    @JoinColumn(name = "receptor_id")
    private Usuario receptor;

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getContenido() { return contenido; }
    public void setContenido(String contenido) { this.contenido = contenido; }
    public java.time.LocalDateTime getFecha() { return fecha; }
    public void setFecha(java.time.LocalDateTime fecha) { this.fecha = fecha; }
    public Usuario getEmisor() { return emisor; }
    public void setEmisor(Usuario emisor) { this.emisor = emisor; }
    public Usuario getReceptor() { return receptor; }
    public void setReceptor(Usuario receptor) { this.receptor = receptor; }
}