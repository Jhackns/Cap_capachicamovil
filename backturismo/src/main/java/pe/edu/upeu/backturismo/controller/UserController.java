package pe.edu.upeu.backturismo.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;
import pe.edu.upeu.backturismo.model.User;
import pe.edu.upeu.backturismo.model.UserRole;
import pe.edu.upeu.backturismo.repository.UserRepository;
import pe.edu.upeu.backturismo.security.JwtUtil;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    @Operation(summary = "Register a new user", description = "Creates a new user with specified role")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "User registered successfully",
                    content = @Content(schema = @Schema(implementation = User.class))),
            @ApiResponse(responseCode = "400", description = "Invalid input or email already exists")
    })
    @PostMapping("/users/register")
    public ResponseEntity<?> register(@Valid @RequestBody User user) {
        System.out.println("Received user with rol: " + user.getRol());
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body("Email already exists");
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        
        // Si no se especifica un rol, por defecto será REGULAR
        if (user.getRol() == null) {
            System.out.println("Setting default rol: REGULAR");
            user.setRol(UserRole.REGULAR);
        } else {
            System.out.println("Using provided rol: " + user.getRol());
        }
        
        User savedUser = userRepository.save(user);
        System.out.println("Saved user with rol: " + savedUser.getRol());
        return ResponseEntity.ok(savedUser);
    }

    @Operation(summary = "Login user", description = "Authenticates user and returns JWT token")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Login successful",
                    content = @Content(schema = @Schema(implementation = Map.class))),
            @ApiResponse(responseCode = "401", description = "Invalid credentials")
    })
    @PostMapping("/users/login")
    public ResponseEntity<?> login(@RequestBody User loginUser) {
        Optional<User> user = userRepository.findByEmail(loginUser.getEmail());
        if (user.isPresent() && passwordEncoder.matches(loginUser.getPassword(), user.get().getPassword())) {
            String token = jwtUtil.generateToken(user.get().getEmail(), user.get().getRol().name());
            Map<String, Object> response = new HashMap<>();
            response.put("message", "Bienvenido, " + (user.get().getRol() == UserRole.ADMIN ? "Admin" : "Usuario"));
            response.put("token", "Bearer " + token);
            response.put("rol", user.get().getRol().name());
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.status(401).body("Invalid credentials");
    }
    
    // El endpoint de refresh token ha sido eliminado para simplificar la autenticación
}