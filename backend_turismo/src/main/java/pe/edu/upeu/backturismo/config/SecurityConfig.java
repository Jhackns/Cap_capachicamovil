package pe.edu.upeu.backturismo.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import pe.edu.upeu.backturismo.security.JwtFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtFilter jwtFilter;

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth

                        // 🟢 PÚBLICAS: no requieren autenticación
                        .requestMatchers("/api/auth/login", "/api/auth/register", "/api/auth/roles", "/api/auth/init-roles", "/doc/**").permitAll()
                        .requestMatchers("/api/admin/roles/init").permitAll() // Inicialización de roles
                        .requestMatchers(HttpMethod.GET, "/api/emprendedores/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/alojamientos/**").permitAll()

                        // 🟡 USER, EMPRENDEDOR o ADMIN: CRUD sobre sus alojamientos
                        .requestMatchers(HttpMethod.POST, "/api/alojamientos").hasAnyRole("REGULAR", "EMPRENDEDOR", "ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/alojamientos/**").hasAnyRole("REGULAR", "EMPRENDEDOR", "ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/alojamientos/**").hasAnyRole("REGULAR", "EMPRENDEDOR", "ADMIN")

                        // 🟡 EMPRENDEDOR o ADMIN: gestionar su emprendedor
                        .requestMatchers(HttpMethod.POST, "/api/emprendedores").hasAnyRole("EMPRENDEDOR", "ADMIN")
                        .requestMatchers(HttpMethod.PUT, "/api/emprendedores/**").hasAnyRole("EMPRENDEDOR", "ADMIN")
                        .requestMatchers(HttpMethod.DELETE, "/api/emprendedores/**").hasAnyRole("EMPRENDEDOR", "ADMIN")

                        // 🔴 SOLO ADMIN: gestión completa de usuarios y roles
                        .requestMatchers("/api/admin/**").hasRole("ADMIN")

                        // 🔴 SOLO ADMIN: ver todas las reservas (si existe endpoint /todas)
                        .requestMatchers(HttpMethod.GET, "/api/reservas/todas").hasRole("ADMIN")

                        // 🟡 USER, EMPRENDEDOR o ADMIN: hacer/ver sus reservas
                        .requestMatchers(HttpMethod.POST, "/api/reservas").hasAnyRole("REGULAR", "EMPRENDEDOR", "ADMIN")
                        .requestMatchers(HttpMethod.GET, "/api/reservas/**").hasAnyRole("REGULAR", "EMPRENDEDOR", "ADMIN")

                        // 🔐 Cualquier otra ruta requiere autenticación
                        .anyRequest().authenticated()
                )
                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
