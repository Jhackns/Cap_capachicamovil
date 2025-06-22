package pe.edu.upeu.backturismo.repository;

import pe.edu.upeu.backturismo.entity.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    // Buscar usuario por email para login
    Usuario findByEmail(String email);

    // Verificar si existe un usuario con ese email para registro
    boolean existsByEmail(String email);
}