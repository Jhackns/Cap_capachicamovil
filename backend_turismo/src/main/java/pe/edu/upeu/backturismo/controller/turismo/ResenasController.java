package pe.edu.upeu.backturismo.controller.turismo;

import pe.edu.upeu.backturismo.entity.Resenas;
import pe.edu.upeu.backturismo.service.ResenasService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/resenas")
public class ResenasController {

    @Autowired
    private ResenasService resenasService;

    @GetMapping
    public List<Resenas> getAllResenas() {
        return resenasService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Resenas> getResenaById(@PathVariable Long id) {
        Optional<Resenas> resena = resenasService.findById(id);
        return resena.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    public Resenas createResena(@RequestBody Resenas resena) {
        return resenasService.save(resena);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Resenas> updateResena(@PathVariable Long id, @RequestBody Resenas resenaDetails) {
        Optional<Resenas> resena = resenasService.findById(id);
        if (resena.isPresent()) {
            Resenas updatedResena = resena.get();
            updatedResena.setComentario(resenaDetails.getComentario());
            updatedResena.setCalificacion(resenaDetails.getCalificacion());
            // Add other fields to update as needed
            return ResponseEntity.ok(resenasService.save(updatedResena));
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteResena(@PathVariable Long id) {
        if (resenasService.findById(id).isPresent()) {
            resenasService.deleteById(id);
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
