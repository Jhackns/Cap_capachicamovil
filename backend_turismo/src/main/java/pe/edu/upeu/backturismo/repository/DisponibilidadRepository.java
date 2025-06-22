package pe.edu.upeu.backturismo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.upeu.backturismo.entity.Disponibilidad;

public interface DisponibilidadRepository extends JpaRepository<Disponibilidad, Long> {
}