package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Alojamientos;
import pe.edu.upeu.backturismo.repository.AlojamientosRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class AlojamientosServiceImpl implements AlojamientosService {
    @Autowired
    private AlojamientosRepository alojamientosRepository;

    @Override
    public List<Alojamientos> findAll() { return alojamientosRepository.findAll(); }
    @Override
    public Optional<Alojamientos> findById(Long id) { return alojamientosRepository.findById(id); }
    @Override
    public Alojamientos save(Alojamientos alojamientos) { return alojamientosRepository.save(alojamientos); }
    @Override
    public void deleteById(Long id) { alojamientosRepository.deleteById(id); }
}