package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Favoritos;
import java.util.List;
import java.util.Optional;

public interface FavoritosService {
    List<Favoritos> findAll();
    Optional<Favoritos> findById(Long id);
    Favoritos save(Favoritos favoritos);
    void deleteById(Long id);
}