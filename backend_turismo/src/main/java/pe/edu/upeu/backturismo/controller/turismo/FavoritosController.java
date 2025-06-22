package pe.edu.upeu.backturismo.controller.turismo;

import pe.edu.upeu.backturismo.entity.Favoritos;
import pe.edu.upeu.backturismo.service.FavoritosService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/favoritos")
public class FavoritosController {
    @Autowired
    private FavoritosService favoritosService;

    @GetMapping
    public List<Favoritos> getAllFavoritos() { return favoritosService.findAll(); }
    @GetMapping("/{id}")
    public ResponseEntity<Favoritos> getFavoritoById(@PathVariable Long id) {
        Optional<Favoritos> favorito = favoritosService.findById(id);
        return favorito.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PostMapping
    public Favoritos createFavorito(@RequestBody Favoritos favorito) { return favoritosService.save(favorito); }
    @PutMapping("/{id}")
    public ResponseEntity<Favoritos> updateFavorito(@PathVariable Long id, @RequestBody Favoritos favoritoDetails) {
        Optional<Favoritos> favorito = favoritosService.findById(id);
        if (favorito.isPresent()) return ResponseEntity.ok(favoritosService.save(favorito.get()));
        return ResponseEntity.notFound().build();
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteFavorito(@PathVariable Long id) {
        if (favoritosService.findById(id).isPresent()) {
            favoritosService.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
