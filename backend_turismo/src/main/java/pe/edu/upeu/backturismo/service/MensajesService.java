package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Mensajes;
import java.util.List;
import java.util.Optional;

public interface MensajesService {
    List<Mensajes> findAll();
    Optional<Mensajes> findById(Long id);
    Mensajes save(Mensajes mensajes);
    void deleteById(Long id);
}