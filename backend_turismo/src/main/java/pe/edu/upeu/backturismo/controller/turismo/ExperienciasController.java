package pe.edu.upeu.backturismo.controller.turismo;

import pe.edu.upeu.backturismo.entity.Experiencias;
import pe.edu.upeu.backturismo.service.ExperienciasService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/experiencias")
public class ExperienciasController {
    @Autowired
    private ExperienciasService experienciasService;

    @GetMapping
    public List<Experiencias> getAllExperiencias() { return experienciasService.findAll(); }
    @GetMapping("/{id}")
    public ResponseEntity<Experiencias> getExperienciaById(@PathVariable Long id) {
        Optional<Experiencias> experiencia = experienciasService.findById(id);
        return experiencia.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PostMapping
    public Experiencias createExperiencia(@RequestBody Experiencias experiencia) { return experienciasService.save(experiencia); }
    @PutMapping("/{id}")
    public ResponseEntity<Experiencias> updateExperiencia(@PathVariable Long id, @RequestBody Experiencias experienciaDetails) {
        Optional<Experiencias> experiencia = experienciasService.findById(id);
        if (experiencia.isPresent()) return ResponseEntity.ok(experienciasService.save(experiencia.get()));
        return ResponseEntity.notFound().build();
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteExperiencia(@PathVariable Long id) {
        if (experienciasService.findById(id).isPresent()) {
            experienciasService.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
