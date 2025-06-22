package pe.edu.upeu.backturismo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.upeu.backturismo.entity.Mensajes;

public interface MensajesRepository extends JpaRepository<Mensajes, Long> {
}