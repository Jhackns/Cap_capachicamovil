package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Favoritos;
import pe.edu.upeu.backturismo.repository.FavoritosRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class FavoritosServiceImpl implements FavoritosService {
    @Autowired
    private FavoritosRepository favoritosRepository;

    @Override
    public List<Favoritos> findAll() { return favoritosRepository.findAll(); }
    @Override
    public Optional<Favoritos> findById(Long id) { return favoritosRepository.findById(id); }
    @Override
    public Favoritos save(Favoritos favoritos) { return favoritosRepository.save(favoritos); }
    @Override
    public void deleteById(Long id) { favoritosRepository.deleteById(id); }
}