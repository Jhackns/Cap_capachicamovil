package pe.edu.upeu.backturismo.repository;
import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.upeu.backturismo.entity.Alojamiento;

public interface AlojamientoRepository extends JpaRepository<Alojamiento, Long> {
}
