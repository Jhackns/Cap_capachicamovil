package pe.edu.upeu.backturismo.controller.turismo;

import pe.edu.upeu.backturismo.entity.Reportes;
import pe.edu.upeu.backturismo.service.ReportesService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/reportes")
public class ReportesController {
    @Autowired
    private ReportesService reportesService;

    @GetMapping
    public List<Reportes> getAllReportes() { return reportesService.findAll(); }
    @GetMapping("/{id}")
    public ResponseEntity<Reportes> getReporteById(@PathVariable Long id) {
        Optional<Reportes> reporte = reportesService.findById(id);
        return reporte.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }
    @PostMapping
    public Reportes createReporte(@RequestBody Reportes reporte) { return reportesService.save(reporte); }
    @PutMapping("/{id}")
    public ResponseEntity<Reportes> updateReporte(@PathVariable Long id, @RequestBody Reportes reporteDetails) {
        Optional<Reportes> reporte = reportesService.findById(id);
        if (reporte.isPresent()) return ResponseEntity.ok(reportesService.save(reporte.get()));
        return ResponseEntity.notFound().build();
    }
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReporte(@PathVariable Long id) {
        if (reportesService.findById(id).isPresent()) {
            reportesService.deleteById(id);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.notFound().build();
    }
}
