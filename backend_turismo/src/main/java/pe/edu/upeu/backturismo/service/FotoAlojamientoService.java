package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.FotoAlojamiento;
import java.util.List;
import java.util.Optional;

public interface FotoAlojamientoService {
    List<FotoAlojamiento> findAll();
    Optional<FotoAlojamiento> findById(Long id);
    FotoAlojamiento save(FotoAlojamiento foto);
    void deleteById(Long id);
}