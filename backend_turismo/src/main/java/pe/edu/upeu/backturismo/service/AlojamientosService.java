package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Alojamientos;
import java.util.List;
import java.util.Optional;

public interface AlojamientosService {
    List<Alojamientos> findAll();
    Optional<Alojamientos> findById(Long id);
    Alojamientos save(Alojamientos alojamientos);
    void deleteById(Long id);
}