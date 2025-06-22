package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Usuario;
import pe.edu.upeu.backturismo.repository.UsuariosRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public abstract class UsuariosServiceImpl implements UsuarioService {
    @Autowired
    private UsuariosRepository usuariosRepository;

    @Override
    public List<Usuario> findAll() { return usuariosRepository.findAll(); }
    @Override
    public Optional<Usuario> findById(Long id) { return usuariosRepository.findById(id); }
    @Override
    public Usuario save(Usuario usuarios) { return usuariosRepository.save(usuarios); }
    @Override
    public void deleteById(Long id) { usuariosRepository.deleteById(id); }
}