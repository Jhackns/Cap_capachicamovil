package pe.edu.upeu.backturismo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.upeu.backturismo.model.Emprendedor;
import java.util.List;

public interface EmprendedorRepository extends JpaRepository<Emprendedor, Long> {
    List<Emprendedor> findByEstadoTrue();
}