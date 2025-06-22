package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Servicio;
import pe.edu.upeu.backturismo.repository.ServicioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ServicioServiceImpl implements ServicioService {
    @Autowired
    private ServicioRepository servicioRepository;

    @Override
    public List<Servicio> findAll() { return servicioRepository.findAll(); }
    @Override
    public Optional<Servicio> findById(Long id) { return servicioRepository.findById(id); }
    @Override
    public Servicio save(Servicio servicio) { return servicioRepository.save(servicio); }
    @Override
    public void deleteById(Long id) { servicioRepository.deleteById(id); }
}