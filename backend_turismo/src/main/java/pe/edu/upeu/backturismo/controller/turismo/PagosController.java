package pe.edu.upeu.backturismo.controller.turismo;

import pe.edu.upeu.backturismo.entity.Pagos;
import pe.edu.upeu.backturismo.service.PagosService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/pagos")
public class PagosController {
    @Autowired
    private PagosService pagosService;

    @GetMapping
    public List<Pagos> getAllPagos() { return pagosService.findAll(); }
    @GetMapping("/{id}")
    public ResponseEntity<Pagos> getPagoById(@PathVariable Long id) {
        Optional<Pagos> pago = pagosService.findById(id);
        return pago.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PostMapping
    public Pagos createPago(@RequestBody Pagos pago) { return pagosService.save(pago); }
    @PutMapping("/{id}")
    public ResponseEntity<Pagos> updatePago(@PathVariable Long id, @RequestBody Pagos pagoDetails) {
        Optional<Pagos> pago = pagosService.findById(id);
        if (pago.isPresent()) return ResponseEntity.ok(pagosService.save(pago.get()));
        return ResponseEntity.notFound().build();
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePago(@PathVariable Long id) {
        if (pagosService.findById(id).isPresent()) {
            pagosService.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
