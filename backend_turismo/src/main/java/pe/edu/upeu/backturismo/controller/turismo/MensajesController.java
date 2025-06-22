package pe.edu.upeu.backturismo.controller.turismo;

import pe.edu.upeu.backturismo.entity.Mensajes;
import pe.edu.upeu.backturismo.service.MensajesService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/mensajes")
public class MensajesController {
    @Autowired
    private MensajesService mensajesService;

    @GetMapping
    public List<Mensajes> getAllMensajes() { return mensajesService.findAll(); }
    @GetMapping("/{id}")
    public ResponseEntity<Mensajes> getMensajeById(@PathVariable Long id) {
        Optional<Mensajes> mensaje = mensajesService.findById(id);
        return mensaje.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PostMapping
    public Mensajes createMensaje(@RequestBody Mensajes mensaje) { return mensajesService.save(mensaje); }
    @PutMapping("/{id}")
    public ResponseEntity<Mensajes> updateMensaje(@PathVariable Long id, @RequestBody Mensajes mensajeDetails) {
        Optional<Mensajes> mensaje = mensajesService.findById(id);
        if (mensaje.isPresent()) return ResponseEntity.ok(mensajesService.save(mensaje.get()));
        return ResponseEntity.notFound().build();
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMensaje(@PathVariable Long id) {
        if (mensajesService.findById(id).isPresent()) {
            mensajesService.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
