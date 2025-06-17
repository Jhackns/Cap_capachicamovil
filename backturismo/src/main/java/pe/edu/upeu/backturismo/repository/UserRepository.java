package pe.edu.upeu.backturismo.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pe.edu.upeu.backturismo.model.User;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
}