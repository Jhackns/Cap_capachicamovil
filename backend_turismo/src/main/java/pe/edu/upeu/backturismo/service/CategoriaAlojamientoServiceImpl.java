package pe.edu.upeu.backturismo.service;


import pe.edu.upeu.backturismo.entity.CategoriaAlojamiento;
import pe.edu.upeu.backturismo.repository.CategoriaAlojamientoRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class CategoriaAlojamientoServiceImpl implements CategoriaAlojamientoService {
    @Autowired
    private CategoriaAlojamientoRepository categoríaRepository;

    @Override
    public List<CategoriaAlojamiento> findAll() { return categoríaRepository.findAll(); }
    @Override
    public Optional<CategoriaAlojamiento> findById(Long id) { return categoríaRepository.findById(id); }
    @Override
    public CategoriaAlojamiento save(CategoriaAlojamiento categoría) { return categoríaRepository.save(categoría); }
    @Override
    public void deleteById(Long id) { categoríaRepository.deleteById(id); }
}