package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Emprendedor;
import java.util.List;
import java.util.Optional;

public interface EmprendedorService {
    List<Emprendedor> findAll();
    Optional<Emprendedor> findById(Long id);
    Emprendedor save(Emprendedor emprendedor);
    void deleteById(Long id);
}