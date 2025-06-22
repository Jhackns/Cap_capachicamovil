package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Reportes;
import pe.edu.upeu.backturismo.repository.ReportesRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class ReportesServiceImpl implements ReportesService {
    @Autowired
    private ReportesRepository reportesRepository;

    @Override
    public List<Reportes> findAll() { return reportesRepository.findAll(); }
    @Override
    public Optional<Reportes> findById(Long id) { return reportesRepository.findById(id); }
    @Override
    public Reportes save(Reportes reportes) { return reportesRepository.save(reportes); }
    @Override
    public void deleteById(Long id) { reportesRepository.deleteById(id); }
}