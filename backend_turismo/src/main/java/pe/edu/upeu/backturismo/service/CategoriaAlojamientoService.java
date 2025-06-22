package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.CategoriaAlojamiento;
import java.util.List;
import java.util.Optional;

public interface CategoriaAlojamientoService {
    List<CategoriaAlojamiento> findAll();
    Optional<CategoriaAlojamiento> findById(Long id);
    CategoriaAlojamiento save(CategoriaAlojamiento categoría);
    void deleteById(Long id);
}