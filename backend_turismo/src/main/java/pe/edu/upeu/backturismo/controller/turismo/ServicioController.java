package pe.edu.upeu.backturismo.controller.turismo;

import pe.edu.upeu.backturismo.entity.Servicio;
import pe.edu.upeu.backturismo.service.ServicioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/servicios")
public class ServicioController {
    @Autowired
    private ServicioService servicioService;

    @GetMapping
    public List<Servicio> getAllServicios() { return servicioService.findAll(); }
    @GetMapping("/{id}")
    public ResponseEntity<Servicio> getServicioById(@PathVariable Long id) {
        Optional<Servicio> servicio = servicioService.findById(id);
        return servicio.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PostMapping
    public Servicio createServicio(@RequestBody Servicio servicio) { return servicioService.save(servicio); }
    @PutMapping("/{id}")
    public ResponseEntity<Servicio> updateServicio(@PathVariable Long id, @RequestBody Servicio servicioDetails) {
        Optional<Servicio> servicio = servicioService.findById(id);
        if (servicio.isPresent()) return ResponseEntity.ok(servicioService.save(servicio.get()));
        return ResponseEntity.notFound().build();
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteServicio(@PathVariable Long id) {
        if (servicioService.findById(id).isPresent()) {
            servicioService.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
