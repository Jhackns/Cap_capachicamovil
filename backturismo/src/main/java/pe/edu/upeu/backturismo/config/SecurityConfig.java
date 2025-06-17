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
                        // Permitir todas las rutas públicas
                        .requestMatchers("/api/users/login", "/api/users/register", "/doc/**").permitAll()
                        // Permitir GET público para emprendedores
                        .requestMatchers(HttpMethod.GET, "/api/emprendedores").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/emprendedores/**").permitAll()
                        // Permitir operaciones CRUD para cualquier usuario autenticado
                        .requestMatchers(HttpMethod.POST, "/api/emprendedores").authenticated()
                        .requestMatchers(HttpMethod.PUT, "/api/emprendedores/**").authenticated()
                        .requestMatchers(HttpMethod.DELETE, "/api/emprendedores/**").authenticated()
                        .anyRequest().authenticated()
                )
                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
}