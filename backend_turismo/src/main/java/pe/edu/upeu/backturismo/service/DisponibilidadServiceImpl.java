package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Disponibilidad;
import pe.edu.upeu.backturismo.repository.DisponibilidadRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class DisponibilidadServiceImpl implements DisponibilidadService {
    @Autowired
    private DisponibilidadRepository disponibilidadRepository;

    @Override
    public List<Disponibilidad> findAll() { return disponibilidadRepository.findAll(); }
    @Override
    public Optional<Disponibilidad> findById(Long id) { return disponibilidadRepository.findById(id); }
    @Override
    public Disponibilidad save(Disponibilidad disponibilidad) { return disponibilidadRepository.save(disponibilidad); }
    @Override
    public void deleteById(Long id) { disponibilidadRepository.deleteById(id); }
}