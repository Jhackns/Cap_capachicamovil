package pe.edu.upeu.backturismo.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import pe.edu.upeu.backturismo.model.Emprendedor;
import pe.edu.upeu.backturismo.model.Resena;
import pe.edu.upeu.backturismo.repository.EmprendedorRepository;
import pe.edu.upeu.backturismo.repository.ResenaRepository;
import pe.edu.upeu.backturismo.dto.ResenaDTO;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/emprendedores/{emprendedorId}/resenas")
@Validated
@CrossOrigin(origins = "*")
public class ResenaController {

    @Autowired
    private ResenaRepository resenaRepository;

    @Autowired
    private EmprendedorRepository emprendedorRepository;

    @Operation(summary = "Get all reviews for an emprendedor", description = "Returns a list of all reviews for a specific emprendedor")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Successfully retrieved list",
                    content = @Content(schema = @Schema(implementation = ResenaDTO.class))),
            @ApiResponse(responseCode = "404", description = "Emprendedor not found")
    })
    @GetMapping
    @PreAuthorize("permitAll()")
    public ResponseEntity<?> getAllResenas(@PathVariable Long emprendedorId) {
        if (!emprendedorRepository.existsById(emprendedorId)) {
            return ResponseEntity.notFound().build();
        }
        List<Resena> resenas = resenaRepository.findByEmprendedorId(emprendedorId);
        List<ResenaDTO> resenasDTO = resenas.stream()
                .map(resena -> new ResenaDTO(
                        resena.getId(),
                        resena.getNombreAutor(),
                        resena.getComentario(),
                        resena.getPuntuacion(),
                        resena.getImagenes(),
                        resena.getEmprendedor().getId(),
                        resena.getCreatedAt(),
                        resena.getUpdatedAt()
                ))
                .collect(Collectors.toList());
        return ResponseEntity.ok(resenasDTO);
    }

    @Operation(summary = "Create a new review", description = "Creates a new review for an emprendedor (requires authentication)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Review created successfully",
                    content = @Content(schema = @Schema(implementation = ResenaDTO.class))),
            @ApiResponse(responseCode = "400", description = "Invalid input"),
            @ApiResponse(responseCode = "401", description = "Unauthorized"),
            @ApiResponse(responseCode = "404", description = "Emprendedor not found")
    })
    @PostMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> createResena(
            @PathVariable Long emprendedorId,
            @Valid @RequestBody Resena resena) {
        return emprendedorRepository.findById(emprendedorId)
                .map(emprendedor -> {
                    resena.setEmprendedor(emprendedor);
                    Resena savedResena = resenaRepository.save(resena);
                    ResenaDTO resenaDTO = new ResenaDTO(
                            savedResena.getId(),
                            savedResena.getNombreAutor(),
                            savedResena.getComentario(),
                            savedResena.getPuntuacion(),
                            savedResena.getImagenes(),
                            savedResena.getEmprendedor().getId(),
                            savedResena.getCreatedAt(),
                            savedResena.getUpdatedAt()
                    );
                    return ResponseEntity.ok(resenaDTO);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @Operation(summary = "Delete a review", description = "Deletes a review by ID (requires authentication)")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Review deleted successfully"),
            @ApiResponse(responseCode = "401", description = "Unauthorized"),
            @ApiResponse(responseCode = "404", description = "Review not found")
    })
    @DeleteMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<?> deleteResena(
            @PathVariable Long emprendedorId,
            @PathVariable Long id) {
        if (!resenaRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        resenaRepository.deleteByEmprendedorIdAndId(emprendedorId, id);
        return ResponseEntity.ok().body("Reseña eliminada exitosamente");
    }
} 