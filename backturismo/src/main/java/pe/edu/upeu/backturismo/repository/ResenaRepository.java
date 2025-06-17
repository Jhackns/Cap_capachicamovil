package pe.edu.upeu.backturismo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.upeu.backturismo.model.Resena;
import java.util.List;

public interface ResenaRepository extends JpaRepository<Resena, Long> {
    List<Resena> findByEmprendedorId(Long emprendedorId);
    void deleteByEmprendedorIdAndId(Long emprendedorId, Long id);
} 