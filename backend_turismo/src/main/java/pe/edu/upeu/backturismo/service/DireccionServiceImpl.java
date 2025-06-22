package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Direccion;
import pe.edu.upeu.backturismo.repository.DireccionRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class DireccionServiceImpl implements DireccionService {
    @Autowired
    private DireccionRepository direcciónRepository;
    @Override
    public List<Direccion> findAll() { return direcciónRepository.findAll(); }
    @Override
    public Optional<Direccion> findById(Long id) { return direcciónRepository.findById(id); }
    @Override
    public Direccion save(Direccion dirección) { return direcciónRepository.save(dirección); }
    @Override
    public void deleteById(Long id) { direcciónRepository.deleteById(id); }
}