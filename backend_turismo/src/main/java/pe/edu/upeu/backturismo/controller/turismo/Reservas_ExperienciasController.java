package pe.edu.upeu.backturismo.controller.turismo;

import pe.edu.upeu.backturismo.entity.Reservas_Experiencias;
import pe.edu.upeu.backturismo.service.Reservas_ExperienciasService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/reservasexperiencias")
public class Reservas_ExperienciasController {
    @Autowired
    private Reservas_ExperienciasService reservasExperienciasService;

    @GetMapping
    public List<Reservas_Experiencias> getAllReservasExperiencias() { return reservasExperienciasService.findAll(); }
    @GetMapping("/{id}")
    public ResponseEntity<Reservas_Experiencias> getReservaExperienciaById(@PathVariable Long id) {
        Optional<Reservas_Experiencias> reservaExperiencia = reservasExperienciasService.findById(id);
        return reservaExperiencia.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PostMapping
    public Reservas_Experiencias createReservaExperiencia(@RequestBody Reservas_Experiencias reservaExperiencia) { return reservasExperienciasService.save(reservaExperiencia); }
    @PutMapping("/{id}")
    public ResponseEntity<Reservas_Experiencias> updateReservaExperiencia(@PathVariable Long id, @RequestBody Reservas_Experiencias reservaExperienciaDetails) {
        Optional<Reservas_Experiencias> reservaExperiencia = reservasExperienciasService.findById(id);
        if (reservaExperiencia.isPresent()) return ResponseEntity.ok(reservasExperienciasService.save(reservaExperiencia.get()));
        return ResponseEntity.notFound().build();
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReservaExperiencia(@PathVariable Long id) {
        if (reservasExperienciasService.findById(id).isPresent()) {
            reservasExperienciasService.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
