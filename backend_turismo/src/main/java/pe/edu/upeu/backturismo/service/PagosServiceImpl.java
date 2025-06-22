package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Pagos;
import pe.edu.upeu.backturismo.repository.PagosRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class PagosServiceImpl implements PagosService {
    @Autowired
    private PagosRepository pagosRepository;

    @Override
    public List<Pagos> findAll() { return pagosRepository.findAll(); }
    @Override
    public Optional<Pagos> findById(Long id) { return pagosRepository.findById(id); }
    @Override
    public Pagos save(Pagos pagos) { return pagosRepository.save(pagos); }
    @Override
    public void deleteById(Long id) { pagosRepository.deleteById(id); }
}