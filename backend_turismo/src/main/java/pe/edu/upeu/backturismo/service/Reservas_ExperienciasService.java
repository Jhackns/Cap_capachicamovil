package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Reservas_Experiencias;
import java.util.List;
import java.util.Optional;

public interface Reservas_ExperienciasService {
    List<Reservas_Experiencias> findAll();
    Optional<Reservas_Experiencias> findById(Long id);
    Reservas_Experiencias save(Reservas_Experiencias reservasExperiencias);
    void deleteById(Long id);
}