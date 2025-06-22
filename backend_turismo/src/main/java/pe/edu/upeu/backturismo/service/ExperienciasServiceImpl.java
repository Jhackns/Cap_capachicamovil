package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Experiencias;
import pe.edu.upeu.backturismo.repository.ExperienciasRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ExperienciasServiceImpl implements ExperienciasService {
    @Autowired
    private ExperienciasRepository experienciasRepository;

    @Override
    public List<Experiencias> findAll() { return experienciasRepository.findAll(); }
    @Override
    public Optional<Experiencias> findById(Long id) { return experienciasRepository.findById(id); }
    @Override
    public Experiencias save(Experiencias experiencias) { return experienciasRepository.save(experiencias); }
    @Override
    public void deleteById(Long id) { experienciasRepository.deleteById(id); }
}