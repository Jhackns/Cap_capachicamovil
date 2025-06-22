package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.AlojamientoServicio;
import pe.edu.upeu.backturismo.repository.AlojamientoServicioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class AlojamientoServicioServiceImpl implements AlojamientoServicioService {
    @Autowired
    private AlojamientoServicioRepository alojamientoServicioRepository;

    @Override
    public List<AlojamientoServicio> findAll() { return alojamientoServicioRepository.findAll(); }
    @Override
    public Optional<AlojamientoServicio> findById(Long id) { return alojamientoServicioRepository.findById(id); }
    @Override
    public AlojamientoServicio save(AlojamientoServicio alojamientoServicio) { return alojamientoServicioRepository.save(alojamientoServicio); }
    @Override
    public void deleteById(Long id) { alojamientoServicioRepository.deleteById(id); }
}