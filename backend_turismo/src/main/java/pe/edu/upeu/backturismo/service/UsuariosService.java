package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Usuario;
import java.util.List;
import java.util.Optional;

public interface UsuariosService {
    List<Usuario> findAll();
    Optional<Usuario> findById(Long id);
    Usuario save(Usuario usuarios);
    void deleteById(Long id);
}