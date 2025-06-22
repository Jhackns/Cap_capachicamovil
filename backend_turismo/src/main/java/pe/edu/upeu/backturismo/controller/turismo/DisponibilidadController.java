package pe.edu.upeu.backturismo.controller.turismo;

import pe.edu.upeu.backturismo.entity.Disponibilidad;
import pe.edu.upeu.backturismo.service.DisponibilidadService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/disponibilidades")
public class DisponibilidadController {
    @Autowired
    private DisponibilidadService disponibilidadService;

    @GetMapping
    public List<Disponibilidad> getAllDisponibilidades() { return disponibilidadService.findAll(); }
    @GetMapping("/{id}")
    public ResponseEntity<Disponibilidad> getDisponibilidadById(@PathVariable Long id) {
        Optional<Disponibilidad> disponibilidad = disponibilidadService.findById(id);
        return disponibilidad.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PostMapping
    public Disponibilidad createDisponibilidad(@RequestBody Disponibilidad disponibilidad) { return disponibilidadService.save(disponibilidad); }
    @PutMapping("/{id}")
    public ResponseEntity<Disponibilidad> updateDisponibilidad(@PathVariable Long id, @RequestBody Disponibilidad disponibilidadDetails) {
        Optional<Disponibilidad> disponibilidad = disponibilidadService.findById(id);
        if (disponibilidad.isPresent()) return ResponseEntity.ok(disponibilidadService.save(disponibilidad.get()));
        return ResponseEntity.notFound().build();
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDisponibilidad(@PathVariable Long id) {
        if (disponibilidadService.findById(id).isPresent()) {
            disponibilidadService.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
