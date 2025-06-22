package pe.edu.upeu.backturismo.admin.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;
import pe.edu.upeu.backturismo.auth.entity.Rol;
import pe.edu.upeu.backturismo.auth.service.RolService;
import pe.edu.upeu.backturismo.entity.Usuario;
import pe.edu.upeu.backturismo.service.UsuarioService;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/admin/usuarios")
public class UsuarioAdminController {

    @Autowired
    private UsuarioService usuarioService;

    @Autowired
    private RolService rolService;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    // LISTAR TODOS LOS USUARIOS
    @GetMapping
    public ResponseEntity<?> getAllUsuarios() {
        try {
            List<Usuario> usuarios = usuarioService.findAll();
            // Ocultar contraseñas
            usuarios.forEach(u -> u.setPassword(null));
            return ResponseEntity.ok(usuarios);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al obtener usuarios: " + e.getMessage()));
        }
    }

    // OBTENER USUARIO POR ID
    @GetMapping("/{id}")
    public ResponseEntity<?> getUsuarioById(@PathVariable Long id) {
        try {
            Optional<Usuario> usuario = usuarioService.findById(id);
            if (usuario.isPresent()) {
                usuario.get().setPassword(null);
                return ResponseEntity.ok(usuario.get());
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al obtener usuario: " + e.getMessage()));
        }
    }

    // CREAR USUARIO (ADMIN)
    @PostMapping
    public ResponseEntity<?> createUsuario(@RequestBody Map<String, Object> userData) {
        try {
            String email = (String) userData.get("email");
            String password = (String) userData.get("password");
            String rolNombre = (String) userData.get("rol");
            String nombre = (String) userData.get("nombre");
            String apellido = (String) userData.get("apellido");

            if (usuarioService.existsByEmail(email)) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "El email ya está registrado"));
            }

            Rol rol = rolService.findByNombre(rolNombre)
                    .orElseThrow(() -> new RuntimeException("Rol '" + rolNombre + "' no encontrado"));

            Usuario usuario = new Usuario();
            usuario.setEmail(email);
            usuario.setPassword(passwordEncoder.encode(password));
            usuario.setRol(rol);
            usuario.setNombre(nombre);
            usuario.setApellido(apellido);

            Usuario savedUsuario = usuarioService.save(usuario);
            savedUsuario.setPassword(null);

            return ResponseEntity.ok(savedUsuario);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al crear usuario: " + e.getMessage()));
        }
    }

    // ACTUALIZAR USUARIO
    @PutMapping("/{id}")
    public ResponseEntity<?> updateUsuario(@PathVariable Long id, @RequestBody Map<String, Object> userData) {
        try {
            Optional<Usuario> usuarioOpt = usuarioService.findById(id);
            if (usuarioOpt.isPresent()) {
                Usuario existingUsuario = usuarioOpt.get();

                if (userData.get("email") != null) {
                    existingUsuario.setEmail((String) userData.get("email"));
                }
                if (userData.get("password") != null) {
                    existingUsuario.setPassword(passwordEncoder.encode((String) userData.get("password")));
                }
                if (userData.get("rol") != null) {
                    Rol rol = rolService.findByNombre((String) userData.get("rol"))
                            .orElseThrow(() -> new RuntimeException("Rol no encontrado"));
                    existingUsuario.setRol(rol);
                }
                if (userData.get("nombre") != null) {
                    existingUsuario.setNombre((String) userData.get("nombre"));
                }
                if (userData.get("apellido") != null) {
                    existingUsuario.setApellido((String) userData.get("apellido"));
                }

                Usuario updatedUsuario = usuarioService.save(existingUsuario);
                updatedUsuario.setPassword(null);
                return ResponseEntity.ok(updatedUsuario);
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al actualizar usuario: " + e.getMessage()));
        }
    }

    // ELIMINAR USUARIO
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUsuario(@PathVariable Long id) {
        try {
            if (usuarioService.findById(id).isPresent()) {
                usuarioService.deleteById(id);
                return ResponseEntity.ok().build();
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al eliminar usuario: " + e.getMessage()));
        }
    }
} 