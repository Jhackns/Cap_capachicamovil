package pe.edu.upeu.backturismo.auth.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;
import pe.edu.upeu.backturismo.auth.entity.Rol;
import pe.edu.upeu.backturismo.auth.service.RolService;
import pe.edu.upeu.backturismo.entity.Usuario;
import pe.edu.upeu.backturismo.service.UsuarioService;
import pe.edu.upeu.backturismo.security.JwtUtil;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UsuarioService usuarioService;

    @Autowired
    private RolService rolService;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    // INICIALIZAR ROLES BÁSICOS
    @PostMapping("/init-roles")
    public ResponseEntity<?> initializeRoles() {
        try {
            rolService.initializeRoles();
            return ResponseEntity.ok(Map.of(
                "message", "Roles inicializados correctamente",
                "roles_creados", true
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al inicializar roles: " + e.getMessage()));
        }
    }

    // REGISTRO DE USUARIOS
    @PostMapping("/register")
    public ResponseEntity<?> registerUsuario(@RequestBody Map<String, Object> registerData) {
        try {
            String email = (String) registerData.get("email");
            String password = (String) registerData.get("password");
            String rolNombre = (String) registerData.get("rol");
            String nombre = (String) registerData.get("nombre");
            String apellido = (String) registerData.get("apellido");

            // Validaciones
            if (email == null || email.isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "El email es requerido"));
            }

            if (password == null || password.isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "La contraseña es requerida"));
            }

            if (nombre == null || nombre.isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "El nombre es requerido"));
            }

            if (apellido == null || apellido.isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "El apellido es requerido"));
            }

            if (usuarioService.existsByEmail(email)) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "El email ya está registrado"));
            }

            // Obtener rol (por defecto "regular" si no se especifica)
            final String finalRolNombre = (rolNombre == null || rolNombre.isEmpty()) ? "regular" : rolNombre;

            // Buscar el rol y manejar el error específicamente
            Optional<Rol> rolOpt = rolService.findByNombre(finalRolNombre);
            if (rolOpt.isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "El rol '" + finalRolNombre + "' no existe. Roles disponibles: admin, regular, emprendedor"));
            }
            
            Rol rol = rolOpt.get();

            // Crear usuario
            Usuario usuario = new Usuario();
            usuario.setEmail(email);
            usuario.setPassword(passwordEncoder.encode(password));
            usuario.setRol(rol);
            usuario.setNombre(nombre);
            usuario.setApellido(apellido);

            Usuario savedUsuario = usuarioService.save(usuario);
            savedUsuario.setPassword(null); // Ocultar contraseña en la respuesta

            // Generar token
            String token = jwtUtil.generateToken(savedUsuario.getEmail(), savedUsuario.getRol().getNombre());

            Map<String, Object> response = new HashMap<>();
            response.put("message", "¡Bienvenido " + savedUsuario.getNombre() + "!");
            response.put("rol", savedUsuario.getRol().getTitulo());
            response.put("token", token);
            response.put("usuario", Map.of(
                "id", savedUsuario.getId(),
                "email", savedUsuario.getEmail(),
                "nombre", savedUsuario.getNombre(),
                "apellido", savedUsuario.getApellido(),
                "rol", savedUsuario.getRol().getNombre()
            ));

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al registrar usuario: " + e.getMessage()));
        }
    }

    // LOGIN DE USUARIOS
    @PostMapping("/login")
    public ResponseEntity<?> loginUsuario(@RequestBody Map<String, String> loginData) {
        try {
            System.out.println("AuthController: Iniciando login...");
            System.out.println("AuthController: Login data recibida: " + loginData);
            
            String email = loginData.get("email");
            String password = loginData.get("password");

            System.out.println("AuthController: Email = " + email);
            System.out.println("AuthController: Password = " + (password != null ? "***" : "null"));

            if (email == null || password == null) {
                System.out.println("AuthController: Error - Email o password son null");
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Email y contraseña son requeridos"));
            }

            Usuario usuario = usuarioService.findByEmail(email);
            System.out.println("AuthController: Usuario encontrado = " + (usuario != null ? usuario.getEmail() : "null"));
            
            if (usuario == null || !passwordEncoder.matches(password, usuario.getPassword())) {
                System.out.println("AuthController: Error - Credenciales inválidas");
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Credenciales inválidas"));
            }

            String token = jwtUtil.generateToken(usuario.getEmail(), usuario.getRol().getNombre());
            System.out.println("AuthController: Token generado exitosamente");

            Map<String, Object> response = new HashMap<>();
            response.put("message", "¡Bienvenido de vuelta " + usuario.getNombre() + "!");
            response.put("rol", usuario.getRol().getTitulo());
            response.put("token", token);
            response.put("usuario", Map.of(
                "id", usuario.getId(),
                "email", usuario.getEmail(),
                "nombre", usuario.getNombre(),
                "apellido", usuario.getApellido(),
                "rol", usuario.getRol().getNombre()
            ));

            System.out.println("AuthController: Login exitoso para " + email);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            System.out.println("AuthController: Error en login: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al iniciar sesión: " + e.getMessage()));
        }
    }

    // OBTENER ROLES DISPONIBLES
    @GetMapping("/roles")
    public ResponseEntity<?> getRoles() {
        try {
            return ResponseEntity.ok(rolService.findAll());
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Error al obtener roles: " + e.getMessage()));
        }
    }
} 