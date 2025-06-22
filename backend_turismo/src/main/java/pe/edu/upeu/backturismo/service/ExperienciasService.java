package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Experiencias;
import java.util.List;
import java.util.Optional;

public interface ExperienciasService {
    List<Experiencias> findAll();
    Optional<Experiencias> findById(Long id);
    Experiencias save(Experiencias experiencias);
    void deleteById(Long id);
}