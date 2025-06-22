package pe.edu.upeu.backturismo.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

@Component
public class JwtFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        // Debugging
        System.out.println("JwtFilter: Path = " + request.getRequestURI() + ", Method = " + request.getMethod());

        // Token desde header Authorization
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);

            try {
                if (jwtUtil.isTokenValid(token)) {
                    String email = jwtUtil.getEmail(token);
                    String rol = jwtUtil.getRol(token);

                    // El rol debe incluir el prefijo "ROLE_" para que funcione con hasRole()
                    SimpleGrantedAuthority authority = new SimpleGrantedAuthority("ROLE_" + rol.toUpperCase());

                    UsernamePasswordAuthenticationToken auth =
                            new UsernamePasswordAuthenticationToken(email, null, Collections.singletonList(authority));

                    SecurityContextHolder.getContext().setAuthentication(auth);
                    System.out.println("JwtFilter: Usuario autenticado - " + email + " con rol " + rol);
                }
            } catch (Exception e) {
                System.out.println("JwtFilter: Error al procesar el token: " + e.getMessage());
            }
        } else {
            System.out.println("JwtFilter: No se encontró token de autorización");
        }

        filterChain.doFilter(request, response);
    }
}
