package pe.edu.upeu.backturismo.controller.turismo;

import pe.edu.upeu.backturismo.entity.Alojamientos;
import pe.edu.upeu.backturismo.service.AlojamientosService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/alojamientos")
public class AlojamientosController {
    @Autowired
    private AlojamientosService alojamientosService;

    @GetMapping
    public List<Alojamientos> getAllAlojamientos() { return alojamientosService.findAll(); }
    @GetMapping("/{id}")
    public ResponseEntity<Alojamientos> getAlojamientoById(@PathVariable Long id) {
        Optional<Alojamientos> alojamiento = alojamientosService.findById(id);
        return alojamiento.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PostMapping
    public Alojamientos createAlojamiento(@RequestBody Alojamientos alojamiento) { return alojamientosService.save(alojamiento); }
    @PutMapping("/{id}")
    public ResponseEntity<Alojamientos> updateAlojamiento(@PathVariable Long id, @RequestBody Alojamientos alojamientoDetails) {
        Optional<Alojamientos> alojamiento = alojamientosService.findById(id);
        if (alojamiento.isPresent()) return ResponseEntity.ok(alojamientosService.save(alojamiento.get()));
        return ResponseEntity.notFound().build();
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAlojamiento(@PathVariable Long id) {
        if (alojamientosService.findById(id).isPresent()) {
            alojamientosService.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
