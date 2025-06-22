package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Disponibilidad;
import java.util.List;
import java.util.Optional;

public interface DisponibilidadService {
    List<Disponibilidad> findAll();
    Optional<Disponibilidad> findById(Long id);
    Disponibilidad save(Disponibilidad disponibilidad);
    void deleteById(Long id);
}