package pe.edu.upeu.backturismo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.upeu.backturismo.entity.Favoritos;

public interface FavoritosRepository extends JpaRepository<Favoritos, Long> {
}