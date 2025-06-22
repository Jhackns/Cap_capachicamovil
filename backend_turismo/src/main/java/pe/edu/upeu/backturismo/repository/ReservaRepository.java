package pe.edu.upeu.backturismo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.upeu.backturismo.entity.Reserva;

public interface ReservaRepository extends JpaRepository<Reserva, Long> {
}