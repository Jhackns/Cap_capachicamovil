package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.AlojamientoServicio;
import java.util.List;
import java.util.Optional;

public interface AlojamientoServicioService {
    List<AlojamientoServicio> findAll();
    Optional<AlojamientoServicio> findById(Long id);
    AlojamientoServicio save(AlojamientoServicio alojamientoServicio);
    void deleteById(Long id);
}