package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Alojamiento;
import pe.edu.upeu.backturismo.repository.AlojamientoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class AlojamientoServiceImpl implements AlojamientoService {
    @Autowired
    private AlojamientoRepository alojamientoRepository;

    @Override
    public List<Alojamiento> findAll() { return alojamientoRepository.findAll(); }
    @Override
    public Optional<Alojamiento> findById(Long id) { return alojamientoRepository.findById(id); }
    @Override
    public Alojamiento save(Alojamiento alojamiento) { return alojamientoRepository.save(alojamiento); }
    @Override
    public void deleteById(Long id) { alojamientoRepository.deleteById(id); }
}