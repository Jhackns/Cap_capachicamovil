package pe.edu.upeu.backturismo.repository;

import pe.edu.upeu.backturismo.entity.Emprendedor;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EmprendedorRepository extends JpaRepository<Emprendedor, Long> {
}