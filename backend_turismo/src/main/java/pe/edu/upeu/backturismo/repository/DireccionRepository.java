package pe.edu.upeu.backturismo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.upeu.backturismo.entity.Direccion;

public interface DireccionRepository extends JpaRepository<Direccion, Long> {
}
