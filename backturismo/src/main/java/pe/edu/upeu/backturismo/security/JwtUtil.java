package pe.edu.upeu.backturismo.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;

@Component
public class JwtUtil {
    private final String SECRET_KEY = "your-very-secure-secret-key-123456789012345678901234567890";
    private final long TOKEN_EXPIRATION = 1000 * 60 * 60 * 24 * 7; // 7 días para mayor duración
    private final SecretKey key = Keys.hmacShaKeyFor(SECRET_KEY.getBytes());

    /**
     * Genera un token JWT
     * @param email Email del usuario
     * @param rol Rol del usuario
     * @return Token JWT
     */
    public String generateToken(String email, String rol) {
        return Jwts.builder()
                .subject(email)
                .claim("rol", rol)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + TOKEN_EXPIRATION))
                .signWith(key)
                .compact();
    }

    /**
     * Obtiene los claims de un token
     * @param token Token JWT
     * @return Claims del token
     */
    public Claims getClaims(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(key)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (JwtException e) {
            throw new RuntimeException("Invalid JWT token: " + e.getMessage());
        }
    }

    /**
     * Obtiene el email del token
     * @param token Token JWT
     * @return Email del usuario
     */
    public String getEmail(String token) {
        try {
            return getClaims(token).getSubject();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Obtiene el rol del token
     * @param token Token JWT
     * @return Rol del usuario
     */
    public String getRol(String token) {
        try {
            return (String) getClaims(token).get("rol");
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Verifica si un token es válido
     * @param token Token a verificar
     * @return true si el token es válido, false en caso contrario
     */
    public boolean isTokenValid(String token) {
        try {
            Claims claims = getClaims(token);
            Date expirationDate = claims.getExpiration();
            return !expirationDate.before(new Date());
        } catch (Exception e) {
            return false;
        }
    }
}
