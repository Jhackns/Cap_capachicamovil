package pe.edu.upeu.backturismo.auth.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pe.edu.upeu.backturismo.auth.entity.Rol;
import pe.edu.upeu.backturismo.auth.repository.RolRepository;

import java.util.List;
import java.util.Optional;

@Service
public class RolServiceImpl implements RolService {

    @Autowired
    private RolRepository rolRepository;

    @Override
    public List<Rol> findAll() {
        return rolRepository.findAll();
    }

    @Override
    public Optional<Rol> findById(Long id) {
        return rolRepository.findById(id);
    }

    @Override
    public Optional<Rol> findByNombre(String nombre) {
        return rolRepository.findByNombre(nombre);
    }

    @Override
    public Rol save(Rol rol) {
        return rolRepository.save(rol);
    }

    @Override
    public void deleteById(Long id) {
        rolRepository.deleteById(id);
    }

    @Override
    public boolean existsByNombre(String nombre) {
        return rolRepository.existsByNombre(nombre);
    }

    @Override
    public void initializeRoles() {
        // Crear rol ADMIN si no existe
        if (!existsByNombre("admin")) {
            Rol adminRol = new Rol("admin", "Administrador", "Rol con acceso completo al sistema");
            save(adminRol);
        }

        // Crear rol REGULAR si no existe
        if (!existsByNombre("regular")) {
            Rol regularRol = new Rol("regular", "Usuario Regular", "Usuario con acceso básico al sistema");
            save(regularRol);
        }

        // Crear rol EMPRENDEDOR si no existe
        if (!existsByNombre("emprendedor")) {
            Rol emprendedorRol = new Rol("emprendedor", "Emprendedor", "Usuario que puede gestionar sus servicios y alojamientos");
            save(emprendedorRol);
        }
    }
} 