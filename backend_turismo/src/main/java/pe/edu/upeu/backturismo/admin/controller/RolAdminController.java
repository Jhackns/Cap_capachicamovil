package pe.edu.upeu.backturismo.admin.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.edu.upeu.backturismo.auth.entity.Rol;
import pe.edu.upeu.backturismo.auth.service.RolService;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/admin/roles")
public class RolAdminController {

    @Autowired
    private RolService rolService;

    // LISTAR TODOS LOS ROLES
    @GetMapping
    public ResponseEntity<?> getAllRoles() {
        try {
            List<Rol> roles = rolService.findAll();
            return ResponseEntity.ok(roles);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al obtener roles: " + e.getMessage()));
        }
    }

    // OBTENER ROL POR ID
    @GetMapping("/{id}")
    public ResponseEntity<?> getRolById(@PathVariable Long id) {
        try {
            Optional<Rol> rol = rolService.findById(id);
            if (rol.isPresent()) {
                return ResponseEntity.ok(rol.get());
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al obtener rol: " + e.getMessage()));
        }
    }

    // OBTENER ROL POR NOMBRE
    @GetMapping("/nombre/{nombre}")
    public ResponseEntity<?> getRolByNombre(@PathVariable String nombre) {
        try {
            Optional<Rol> rol = rolService.findByNombre(nombre);
            if (rol.isPresent()) {
                return ResponseEntity.ok(rol.get());
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al obtener rol: " + e.getMessage()));
        }
    }

    // CREAR NUEVO ROL
    @PostMapping
    public ResponseEntity<?> createRol(@RequestBody Rol rol) {
        try {
            if (rolService.existsByNombre(rol.getNombre())) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Ya existe un rol con ese nombre"));
            }

            Rol savedRol = rolService.save(rol);
            return ResponseEntity.ok(savedRol);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al crear rol: " + e.getMessage()));
        }
    }

    // ACTUALIZAR ROL
    @PutMapping("/{id}")
    public ResponseEntity<?> updateRol(@PathVariable Long id, @RequestBody Rol rolDetails) {
        try {
            Optional<Rol> rolOpt = rolService.findById(id);
            if (rolOpt.isPresent()) {
                Rol existingRol = rolOpt.get();

                if (rolDetails.getNombre() != null) {
                    existingRol.setNombre(rolDetails.getNombre());
                }
                if (rolDetails.getTitulo() != null) {
                    existingRol.setTitulo(rolDetails.getTitulo());
                }
                if (rolDetails.getDescripcion() != null) {
                    existingRol.setDescripcion(rolDetails.getDescripcion());
                }

                Rol updatedRol = rolService.save(existingRol);
                return ResponseEntity.ok(updatedRol);
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al actualizar rol: " + e.getMessage()));
        }
    }

    // ELIMINAR ROL
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteRol(@PathVariable Long id) {
        try {
            if (rolService.findById(id).isPresent()) {
                rolService.deleteById(id);
                return ResponseEntity.ok().build();
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al eliminar rol: " + e.getMessage()));
        }
    }

    // INICIALIZAR ROLES BÁSICOS
    @PostMapping("/init")
    public ResponseEntity<?> initializeRoles() {
        try {
            rolService.initializeRoles();
            return ResponseEntity.ok(Map.of(
                "message", "Roles básicos inicializados correctamente",
                "roles_creados", true
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al inicializar roles: " + e.getMessage()));
        }
    }
} 