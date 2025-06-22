package pe.edu.upeu.backturismo.controller.turismo;

import pe.edu.upeu.backturismo.entity.FotoAlojamiento;
import pe.edu.upeu.backturismo.service.FotoAlojamientoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/fotoalojamientos")
public class FotoAlojamientoController {
    @Autowired
    private FotoAlojamientoService fotoService;

    @GetMapping
    public List<FotoAlojamiento> getAllFotoAlojamientos() { return fotoService.findAll(); }
    @GetMapping("/{id}")
    public ResponseEntity<FotoAlojamiento> getFotoAlojamientoById(@PathVariable Long id) {
        Optional<FotoAlojamiento> foto = fotoService.findById(id);
        return foto.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PostMapping
    public FotoAlojamiento createFotoAlojamiento(@RequestBody FotoAlojamiento foto) { return fotoService.save(foto); }
    @PutMapping("/{id}")
    public ResponseEntity<FotoAlojamiento> updateFotoAlojamiento(@PathVariable Long id, @RequestBody FotoAlojamiento fotoDetails) {
        Optional<FotoAlojamiento> foto = fotoService.findById(id);
        if (foto.isPresent()) return ResponseEntity.ok(fotoService.save(foto.get()));
        return ResponseEntity.notFound().build();
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteFotoAlojamiento(@PathVariable Long id) {
        if (fotoService.findById(id).isPresent()) {
            fotoService.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
