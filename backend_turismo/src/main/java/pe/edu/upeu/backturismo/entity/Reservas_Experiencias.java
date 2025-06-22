package pe.edu.upeu.backturismo.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.JoinColumn;

@Entity
public class Reservas_Experiencias {
    @Id
    private Long id;
    @ManyToOne
    @JoinColumn(name = "reserva_id")
    private Reserva reserva;
    @ManyToOne
    @JoinColumn(name = "experiencia_id")
    private Experiencias experiencia;

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Reserva getReserva() { return reserva; }
    public void setReserva(Reserva reserva) { this.reserva = reserva; }
    public Experiencias getExperiencia() { return experiencia; }
    public void setExperiencia(Experiencias experiencia) { this.experiencia = experiencia; }
}