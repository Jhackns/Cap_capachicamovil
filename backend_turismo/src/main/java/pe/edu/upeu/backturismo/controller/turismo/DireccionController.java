package pe.edu.upeu.backturismo.controller.turismo;

import pe.edu.upeu.backturismo.entity.Direccion;
import pe.edu.upeu.backturismo.service.DireccionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/direcciones")
public class DireccionController {
    @Autowired
    private DireccionService direccionService;

    @GetMapping
    public List<Direccion> getAllDirecciones() { return direccionService.findAll(); }
    @GetMapping("/{id}")
    public ResponseEntity<Direccion> getDireccionById(@PathVariable Long id) {
        Optional<Direccion> direccion = direccionService.findById(id);
        return direccion.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PostMapping
    public Direccion createDireccion(@RequestBody Direccion direccion) { return direccionService.save(direccion); }
    @PutMapping("/{id}")
    public ResponseEntity<Direccion> updateDireccion(@PathVariable Long id, @RequestBody Direccion direccionDetails) {
        Optional<Direccion> direccion = direccionService.findById(id);
        if (direccion.isPresent()) return ResponseEntity.ok(direccionService.save(direccion.get()));
        return ResponseEntity.notFound().build();
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDireccion(@PathVariable Long id) {
        if (direccionService.findById(id).isPresent()) {
            direccionService.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
