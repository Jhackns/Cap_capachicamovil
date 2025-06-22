package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Servicio;
import java.util.List;
import java.util.Optional;

public interface ServicioService {
    List<Servicio> findAll();
    Optional<Servicio> findById(Long id);
    Servicio save(Servicio servicio);
    void deleteById(Long id);
}