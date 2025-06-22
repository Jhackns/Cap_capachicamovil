package pe.edu.upeu.backturismo.auth.service;

import pe.edu.upeu.backturismo.auth.entity.Rol;
import java.util.List;
import java.util.Optional;

public interface RolService {
    List<Rol> findAll();
    Optional<Rol> findById(Long id);
    Optional<Rol> findByNombre(String nombre);
    Rol save(Rol rol);
    void deleteById(Long id);
    boolean existsByNombre(String nombre);
    void initializeRoles();
} 