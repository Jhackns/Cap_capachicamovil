package pe.edu.upeu.backturismo.service;

import pe.edu.upeu.backturismo.entity.Emprendedor;
import pe.edu.upeu.backturismo.repository.EmprendedorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
public class EmprendedorServiceImpl implements EmprendedorService {
    @Autowired
    private EmprendedorRepository emprendedorRepository;

    @Override
    public List<Emprendedor> findAll() { return emprendedorRepository.findAll(); }
    @Override
    public Optional<Emprendedor> findById(Long id) { return emprendedorRepository.findById(id); }
    @Override
    public Emprendedor save(Emprendedor emprendedor) { return emprendedorRepository.save(emprendedor); }
    @Override
    public void deleteById(Long id) { emprendedorRepository.deleteById(id); }
}