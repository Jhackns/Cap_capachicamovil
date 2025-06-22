package pe.edu.upeu.backturismo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.upeu.backturismo.entity.Usuario;

public interface UsuariosRepository extends JpaRepository<Usuario, Long> {
}