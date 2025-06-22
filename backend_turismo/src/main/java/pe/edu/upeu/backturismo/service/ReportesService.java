package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Reportes;
import java.util.List;
import java.util.Optional;

public interface ReportesService {
    List<Reportes> findAll();
    Optional<Reportes> findById(Long id);
    Reportes save(Reportes reportes);
    void deleteById(Long id);
}