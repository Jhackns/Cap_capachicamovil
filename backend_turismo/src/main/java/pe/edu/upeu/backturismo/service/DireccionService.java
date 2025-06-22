package pe.edu.upeu.backturismo.service;


import pe.edu.upeu.backturismo.entity.Direccion;
import java.util.List;
import java.util.Optional;

public interface DireccionService {
    List<Direccion> findAll();
    Optional<Direccion> findById(Long id);
    Direccion save(Direccion direccion);
    void deleteById(Long id);
}