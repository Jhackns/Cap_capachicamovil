package pe.edu.upeu.backturismo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.upeu.backturismo.entity.Alojamientos;

public interface AlojamientosRepository extends JpaRepository<Alojamientos, Long> {
}