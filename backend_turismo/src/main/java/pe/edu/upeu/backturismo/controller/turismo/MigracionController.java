package pe.edu.upeu.backturismo.controller.turismo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pe.edu.upeu.backturismo.auth.service.RolService;
import pe.edu.upeu.backturismo.service.UsuarioService;

import java.util.Map;

@RestController
@RequestMapping("/api/migracion")
public class MigracionController {

    @Autowired
    private RolService rolService;

    @Autowired
    private UsuarioService usuarioService;

    @PostMapping("/setup")
    public ResponseEntity<?> setupMigracion() {
        try {
            // Inicializar roles
            rolService.initializeRoles();

            return ResponseEntity.ok(Map.of(
                "message", "Migración completada exitosamente",
                "roles_creados", true,
                "next_step", "Ejecutar /api/init/setup para crear el usuario admin"
            ));

        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error en la migración: " + e.getMessage()));
        }
    }

    @GetMapping("/status")
    public ResponseEntity<?> getMigracionStatus() {
        try {
            boolean rolesExist = rolService.existsByNombre("admin") && 
                               rolService.existsByNombre("regular") && 
                               rolService.existsByNombre("emprendedor");

            return ResponseEntity.ok(Map.of(
                "migracion_completada", rolesExist,
                "roles_creados", rolesExist,
                "message", rolesExist ? "Migración completada" : "Migración pendiente"
            ));

        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al verificar estado: " + e.getMessage()));
        }
    }
} 
