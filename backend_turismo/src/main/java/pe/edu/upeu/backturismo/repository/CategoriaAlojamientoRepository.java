package pe.edu.upeu.backturismo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.upeu.backturismo.entity.CategoriaAlojamiento;

public interface CategoriaAlojamientoRepository extends JpaRepository<CategoriaAlojamiento, Long> {
}