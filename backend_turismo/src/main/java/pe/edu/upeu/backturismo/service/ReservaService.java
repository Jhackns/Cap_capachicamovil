package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Reserva;
import java.util.List;
import java.util.Optional;

public interface ReservaService {
    List<Reserva> findAll();
    Optional<Reserva> findById(Long id);
    Reserva save(Reserva reserva);
    void deleteById(Long id);
}