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
        // No aplicar filtro en endpoints públicos
        String path = request.getServletPath();
        
        // Imprimir para depuración detallada
        System.out.println("JwtFilter: Path = " + path + ", Method = " + request.getMethod());
        System.out.println("JwtFilter: Headers = " + request.getHeaderNames());
        System.out.println("JwtFilter: Authorization = " + request.getHeader("Authorization"));
        System.out.println("JwtFilter: Content-Type = " + request.getHeader("Content-Type"));
        
        // Rutas públicas que no requieren autenticación
        if (path.equals("/api/login") || path.equals("/api/register") || 
            path.startsWith("/doc/") || 
            (path.startsWith("/api/emprendedores") && request.getMethod().equals("GET"))) {
            System.out.println("JwtFilter: Ruta pública, permitiendo acceso sin token: " + path);
            filterChain.doFilter(request, response);
            return;
        }
        
        System.out.println("JwtFilter: Ruta protegida, verificando token: " + path);

        String authHeader = request.getHeader("Authorization");
        String token = null;
        String username = null;
        String rol = null;

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            token = authHeader.substring(7);
            if (jwtUtil.isTokenValid(token)) {
                username = jwtUtil.getEmail(token);
                rol = jwtUtil.getRol(token);
                // Imprimir información para depuración
                System.out.println("Token válido para usuario: " + username + " con rol: " + rol);
                
                // Crear autoridad con el formato correcto para Spring Security
                UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(
                        username, null, Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + rol)));
                SecurityContextHolder.getContext().setAuthentication(auth);
            } else {
                // Si el token no es válido, no autenticar
                // Pero permitir que la solicitud continúe para que los controladores puedan manejar la autorización
                System.out.println("Token inválido");
            }
        }
        
        filterChain.doFilter(request, response);
    }
}