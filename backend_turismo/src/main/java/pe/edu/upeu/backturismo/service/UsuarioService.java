package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Usuario;
import java.util.List;
import java.util.Optional;

public interface UsuarioService {
    // Métodos CRUD existentes
    List<Usuario> findAll();
    Optional<Usuario> findById(Long id);
    Usuario save(Usuario usuario);
    void deleteById(Long id);

    // Métodos para autenticación
    Usuario findByEmail(String email);
    boolean existsByEmail(String email);
}