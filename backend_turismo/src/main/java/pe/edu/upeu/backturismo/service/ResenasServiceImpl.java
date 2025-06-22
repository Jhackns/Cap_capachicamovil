package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Resenas;
import pe.edu.upeu.backturismo.repository.ResenasRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ResenasServiceImpl implements ResenasService {
    @Autowired
    private ResenasRepository reseñasRepository;

    @Override
    public List<Resenas> findAll() { return reseñasRepository.findAll(); }
    @Override
    public Optional<Resenas> findById(Long id) { return reseñasRepository.findById(id); }
    @Override
    public Resenas save(Resenas reseñas) { return reseñasRepository.save(reseñas); }
    @Override
    public void deleteById(Long id) { reseñasRepository.deleteById(id); }
}