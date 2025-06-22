package pe.edu.upeu.backturismo.controller.turismo;

import pe.edu.upeu.backturismo.entity.CategoriaAlojamiento;
import pe.edu.upeu.backturismo.service.CategoriaAlojamientoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/categoriaalojamientos")
public class CategoriaAlojamientoController {
    @Autowired
    private CategoriaAlojamientoService categoriaService;

    @GetMapping
    public List<CategoriaAlojamiento> getAllCategoriaAlojamientos() { return categoriaService.findAll(); }
    @GetMapping("/{id}")
    public ResponseEntity<CategoriaAlojamiento> getCategoriaAlojamientoById(@PathVariable Long id) {
        Optional<CategoriaAlojamiento> categoria = categoriaService.findById(id);
        return categoria.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PostMapping
    public CategoriaAlojamiento createCategoriaAlojamiento(@RequestBody CategoriaAlojamiento categoria) { return categoriaService.save(categoria); }
    @PutMapping("/{id}")
    public ResponseEntity<CategoriaAlojamiento> updateCategoriaAlojamiento(@PathVariable Long id, @RequestBody CategoriaAlojamiento categoriaDetails) {
        Optional<CategoriaAlojamiento> categoria = categoriaService.findById(id);
        if (categoria.isPresent()) return ResponseEntity.ok(categoriaService.save(categoria.get()));
        return ResponseEntity.notFound().build();
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCategoriaAlojamiento(@PathVariable Long id) {
        if (categoriaService.findById(id).isPresent()) {
            categoriaService.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
