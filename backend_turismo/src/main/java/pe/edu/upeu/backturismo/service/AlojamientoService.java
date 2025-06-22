package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Alojamiento;
import java.util.List;
import java.util.Optional;

public interface AlojamientoService {
    List<Alojamiento> findAll();
    Optional<Alojamiento> findById(Long id);
    Alojamiento save(Alojamiento alojamiento);
    void deleteById(Long id);
}