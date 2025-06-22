package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.FotoAlojamiento;
import pe.edu.upeu.backturismo.repository.FotoAlojamientoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class FotoAlojamientoServiceImpl implements FotoAlojamientoService {
    @Autowired
    private FotoAlojamientoRepository fotoRepository;

    @Override
    public List<FotoAlojamiento> findAll() { return fotoRepository.findAll(); }
    @Override
    public Optional<FotoAlojamiento> findById(Long id) { return fotoRepository.findById(id); }
    @Override
    public FotoAlojamiento save(FotoAlojamiento foto) { return fotoRepository.save(foto); }
    @Override
    public void deleteById(Long id) { fotoRepository.deleteById(id); }
}