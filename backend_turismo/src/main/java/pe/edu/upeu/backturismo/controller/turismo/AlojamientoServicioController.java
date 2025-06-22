package pe.edu.upeu.backturismo.controller.turismo;

import pe.edu.upeu.backturismo.entity.AlojamientoServicio;
import pe.edu.upeu.backturismo.service.AlojamientoServicioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/alojamientoservicios")
public class AlojamientoServicioController {
    @Autowired
    private AlojamientoServicioService alojamientoServicioService;

    @GetMapping
    public List<AlojamientoServicio> getAllAlojamientoServicios() { return alojamientoServicioService.findAll(); }
    @GetMapping("/{id}")
    public ResponseEntity<AlojamientoServicio> getAlojamientoServicioById(@PathVariable Long id) {
        Optional<AlojamientoServicio> alojamientoServicio = alojamientoServicioService.findById(id);
        return alojamientoServicio.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PostMapping
    public AlojamientoServicio createAlojamientoServicio(@RequestBody AlojamientoServicio alojamientoServicio) { return alojamientoServicioService.save(alojamientoServicio); }
    @PutMapping("/{id}")
    public ResponseEntity<AlojamientoServicio> updateAlojamientoServicio(@PathVariable Long id, @RequestBody AlojamientoServicio alojamientoServicioDetails) {
        Optional<AlojamientoServicio> alojamientoServicio = alojamientoServicioService.findById(id);
        if (alojamientoServicio.isPresent()) return ResponseEntity.ok(alojamientoServicioService.save(alojamientoServicio.get()));
        return ResponseEntity.notFound().build();
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAlojamientoServicio(@PathVariable Long id) {
        if (alojamientoServicioService.findById(id).isPresent()) {
            alojamientoServicioService.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
