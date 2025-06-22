package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Reserva;
import pe.edu.upeu.backturismo.repository.ReservaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ReservaServiceImpl implements ReservaService {
    @Autowired
    private ReservaRepository reservaRepository;

    @Override
    public List<Reserva> findAll() { return reservaRepository.findAll(); }
    @Override
    public Optional<Reserva> findById(Long id) { return reservaRepository.findById(id); }
    @Override
    public Reserva save(Reserva reserva) { return reservaRepository.save(reserva); }
    @Override
    public void deleteById(Long id) { reservaRepository.deleteById(id); }
}