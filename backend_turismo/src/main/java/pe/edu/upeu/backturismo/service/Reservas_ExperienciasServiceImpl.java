package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Reservas_Experiencias;
import pe.edu.upeu.backturismo.repository.Reservas_ExperienciasRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class Reservas_ExperienciasServiceImpl implements Reservas_ExperienciasService {
    @Autowired
    private Reservas_ExperienciasRepository reservasExperienciasRepository;

    @Override
    public List<Reservas_Experiencias> findAll() { return reservasExperienciasRepository.findAll(); }
    @Override
    public Optional<Reservas_Experiencias> findById(Long id) { return reservasExperienciasRepository.findById(id); }
    @Override
    public Reservas_Experiencias save(Reservas_Experiencias reservasExperiencias) { return reservasExperienciasRepository.save(reservasExperiencias); }
    @Override
    public void deleteById(Long id) { reservasExperienciasRepository.deleteById(id); }
}