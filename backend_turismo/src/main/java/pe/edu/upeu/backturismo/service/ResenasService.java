package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Resenas;

import java.util.List;
import java.util.Optional;

public interface ResenasService {
    List<Resenas> findAll();
    Optional<Resenas> findById(Long id);
    Resenas save(Resenas reseñas);
    void deleteById(Long id);
}