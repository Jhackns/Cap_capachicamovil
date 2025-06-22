package pe.edu.upeu.backturismo.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import pe.edu.upeu.backturismo.auth.entity.Rol;
import pe.edu.upeu.backturismo.auth.service.RolService;
import pe.edu.upeu.backturismo.entity.Usuario;

@Service
public class SystemInitService implements CommandLineRunner {

    @Autowired
    private RolService rolService;

    @Autowired
    private UsuarioService usuarioService;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        System.out.println("🚀 Inicializando sistema...");
        
        // Inicializar roles
        initializeRoles();
        
        // Inicializar usuario admin
        initializeAdminUser();
        
        System.out.println("✅ Sistema inicializado correctamente");
    }

    private void initializeRoles() {
        System.out.println("📋 Inicializando roles...");
        
        // Crear rol ADMIN si no existe
        if (!rolService.existsByNombre("admin")) {
            Rol adminRol = new Rol("admin", "Administrador", "Rol con acceso completo al sistema");
            rolService.save(adminRol);
            System.out.println("✅ Rol 'admin' creado");
        } else {
            System.out.println("ℹ️ Rol 'admin' ya existe");
        }

        // Crear rol REGULAR si no existe
        if (!rolService.existsByNombre("regular")) {
            Rol regularRol = new Rol("regular", "Usuario Regular", "Usuario con acceso básico al sistema");
            rolService.save(regularRol);
            System.out.println("✅ Rol 'regular' creado");
        } else {
            System.out.println("ℹ️ Rol 'regular' ya existe");
        }

        // Crear rol EMPRENDEDOR si no existe
        if (!rolService.existsByNombre("emprendedor")) {
            Rol emprendedorRol = new Rol("emprendedor", "Emprendedor", "Usuario que puede gestionar sus servicios y alojamientos");
            rolService.save(emprendedorRol);
            System.out.println("✅ Rol 'emprendedor' creado");
        } else {
            System.out.println("ℹ️ Rol 'emprendedor' ya existe");
        }
    }

    private void initializeAdminUser() {
        System.out.println("👤 Inicializando usuario administrador...");
        
        String adminEmail = "admin@example.com";
        
        // Verificar si el usuario admin ya existe
        if (usuarioService.existsByEmail(adminEmail)) {
            System.out.println("ℹ️ Usuario admin ya existe");
            return;
        }

        try {
            // Obtener el rol admin por nombre
            Rol adminRol = rolService.findByNombre("admin")
                    .orElseThrow(() -> new RuntimeException("Rol admin no encontrado"));

            System.out.println("🔍 Rol admin encontrado con ID: " + adminRol.getId());

            // Crear usuario administrador con las credenciales especificadas
            Usuario admin = new Usuario();
            admin.setEmail(adminEmail);
            admin.setPassword(passwordEncoder.encode("password123"));
            admin.setRol(adminRol); // Usar la relación Rol directamente
            admin.setNombre("Admin");
            admin.setApellido("User");
            admin.setActivo(true); // Establecer como activo por defecto

            Usuario savedAdmin = usuarioService.save(admin);
            System.out.println("✅ Usuario admin creado con ID: " + savedAdmin.getId());
            System.out.println("📧 Email: " + adminEmail);
            System.out.println("🔑 Contraseña: password123");
            System.out.println("⚠️ IMPORTANTE: Cambia la contraseña después del primer login");
            
        } catch (Exception e) {
            System.err.println("❌ Error al crear usuario admin: " + e.getMessage());
            e.printStackTrace();
        }
    }
} 