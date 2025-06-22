package pe.edu.upeu.backturismo.controller.turismo;

import pe.edu.upeu.backturismo.entity.Emprendedor;
import pe.edu.upeu.backturismo.service.EmprendedorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/emprendedores")
public class EmprendedorController {
    @Autowired
    private EmprendedorService emprendedorService;

    @GetMapping
    public List<Emprendedor> getAllEmprendedores() { return emprendedorService.findAll(); }
    @GetMapping("/{id}")
    public ResponseEntity<Emprendedor> getEmprendedorById(@PathVariable Long id) {
        Optional<Emprendedor> emprendedor = emprendedorService.findById(id);
        return emprendedor.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PostMapping
    public Emprendedor createEmprendedor(@RequestBody Emprendedor emprendedor) { return emprendedorService.save(emprendedor); }
    @PutMapping("/{id}")
    public ResponseEntity<Emprendedor> updateEmprendedor(@PathVariable Long id, @RequestBody Emprendedor emprendedorDetails) {
        Optional<Emprendedor> emprendedor = emprendedorService.findById(id);
        if (emprendedor.isPresent()) return ResponseEntity.ok(emprendedorService.save(emprendedor.get()));
        return ResponseEntity.notFound().build();
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteEmprendedor(@PathVariable Long id) {
        if (emprendedorService.findById(id).isPresent()) {
            emprendedorService.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
