package pe.edu.upeu.backturismo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.upeu.backturismo.entity.Pagos;

public interface PagosRepository extends JpaRepository<Pagos, Long> {
}