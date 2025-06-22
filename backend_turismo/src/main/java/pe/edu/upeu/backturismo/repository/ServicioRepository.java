package pe.edu.upeu.backturismo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.upeu.backturismo.entity.Servicio;

public interface ServicioRepository extends JpaRepository<Servicio, Long> {
}