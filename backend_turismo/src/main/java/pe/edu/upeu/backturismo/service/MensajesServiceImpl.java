package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Mensajes;
import pe.edu.upeu.backturismo.repository.MensajesRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class MensajesServiceImpl implements MensajesService {
    @Autowired
    private MensajesRepository mensajesRepository;

    @Override
    public List<Mensajes> findAll() { return mensajesRepository.findAll(); }
    @Override
    public Optional<Mensajes> findById(Long id) { return mensajesRepository.findById(id); }
    @Override
    public Mensajes save(Mensajes mensajes) { return mensajesRepository.save(mensajes); }
    @Override
    public void deleteById(Long id) { mensajesRepository.deleteById(id); }
}