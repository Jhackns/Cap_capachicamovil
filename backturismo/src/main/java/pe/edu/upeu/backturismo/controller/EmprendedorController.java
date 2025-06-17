package pe.edu.upeu.backturismo.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import pe.edu.upeu.backturismo.model.Emprendedor;
import pe.edu.upeu.backturismo.repository.EmprendedorRepository;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/emprendedores")
@Validated
public class EmprendedorController {

    @Autowired
    private EmprendedorRepository repository;

    @Operation(summary = "Get all active emprendedores", description = "Returns a list of all active emprendedores")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved list",
                    content = @Content(schema = @Schema(implementation = Emprendedor.class)))
    })
    @GetMapping
    public ResponseEntity<List<Emprendedor>> getAll() {
        List<Emprendedor> emprendedores = repository.findByEstadoTrue();
        return ResponseEntity.ok(emprendedores);
    }

    @Operation(summary = "Create a new emprendedor", description = "Creates a new emprendedor (ADMIN only)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Emprendedor created successfully",
                    content = @Content(schema = @Schema(implementation = Emprendedor.class))),
            @ApiResponse(responseCode = "400", description = "Invalid input"),
            @ApiResponse(responseCode = "403", description = "Access denied")
    })
    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody Emprendedor emprendedor) {
        try {
            Emprendedor savedEmprendedor = repository.save(emprendedor);
            return ResponseEntity.ok(savedEmprendedor);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error creating emprendedor: " + e.getMessage());
        }
    }

    @Operation(summary = "Update an existing emprendedor", description = "Updates an emprendedor by ID (ADMIN only)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Emprendedor updated successfully",
                    content = @Content(schema = @Schema(implementation = Emprendedor.class))),
            @ApiResponse(responseCode = "400", description = "Invalid input"),
            @ApiResponse(responseCode = "403", description = "Access denied"),
            @ApiResponse(responseCode = "404", description = "Emprendedor not found")
    })
    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable Long id, @Valid @RequestBody Emprendedor emprendedor) {
        Optional<Emprendedor> existing = repository.findById(id);
        if (existing.isPresent()) {
            emprendedor.setId(id);
            Emprendedor updatedEmprendedor = repository.save(emprendedor);
            return ResponseEntity.ok(updatedEmprendedor);
        }
        return ResponseEntity.notFound().build();
    }

    @Operation(summary = "Delete an emprendedor", description = "Deletes an emprendedor by ID (ADMIN only)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Emprendedor deleted successfully"),
            @ApiResponse(responseCode = "403", description = "Access denied"),
            @ApiResponse(responseCode = "404", description = "Emprendedor not found")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        Optional<Emprendedor> existing = repository.findById(id);
        if (existing.isPresent()) {
            repository.deleteById(id);
            return ResponseEntity.ok().body("Emprendedor deleted successfully");
        }
        return ResponseEntity.notFound().build();
    }
}