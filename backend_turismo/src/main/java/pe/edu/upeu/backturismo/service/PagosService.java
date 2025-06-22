package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Pagos;
import java.util.List;
import java.util.Optional;

public interface PagosService {
    List<Pagos> findAll();
    Optional<Pagos> findById(Long id);
    Pagos save(Pagos pagos);
    void deleteById(Long id);
}