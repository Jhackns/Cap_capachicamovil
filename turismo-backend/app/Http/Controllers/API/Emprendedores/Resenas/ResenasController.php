<?php

namespace App\Http\Controllers\API\Emprendedores\Resenas;

use App\Http\Controllers\Controller;
use App\Models\Resenas;
use App\Models\Emprendedor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Auth;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Support\Facades\Log;

class ResenasController extends Controller
{
    use AuthorizesRequests;

    // GET /api/emprendedores/{id}/resenas
    public function index($emprendedorId)
    {
        $resenas = Resenas::where('emprendedor_id', $emprendedorId)
            ->with('usuario:id,name')
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        // Convertir las rutas de las imágenes a URLs absolutas
        $resenas->getCollection()->transform(function ($resena) {
            if ($resena->imagenes) {
                $resena->imagenes = array_map(function ($imagen) {
                    // Si la imagen ya es una URL completa, la dejamos como está
                    if (filter_var($imagen, FILTER_VALIDATE_URL)) {
                        return $imagen;
                    }
                    // Si no, la convertimos a URL absoluta
                    return asset('storage/' . $imagen);
                }, $resena->imagenes);
            }
            return $resena;
        });

        return response()->json($resenas);
    }

    // POST /api/resenas (con imágenes)
    public function store(Request $request)
    {
        // Validar que el usuario esté autenticado
        if (!Auth::check()) {
            return response()->json([
                'success' => false,
                'message' => 'Debes iniciar sesión para crear reseñas'
            ], 401);
        }

        $validated = $request->validate([
            'emprendedor_id' => 'required|exists:emprendedores,id',
            'comentario' => 'required|string|min:10',
            'puntuacion' => 'required|integer|between:1,5',
            'imagenes.*' => 'nullable|image|mimes:jpeg,png,jpg|max:5120'
        ]);

        // Subir imágenes
        $imagenesPaths = [];
        if ($request->hasFile('imagenes')) {
            foreach ($request->file('imagenes') as $imagen) {
                $path = $imagen->store('resenas', 'public');
                $imagenesPaths[] = $path;
            }
        }

        // Crear nueva reseña
        $resena = new Resenas();
        $resena->emprendedor_id = $validated['emprendedor_id'];
        $resena->nombre_autor = Auth::user()->name; // Usar el nombre del usuario autenticado
        $resena->comentario = $validated['comentario'];
        $resena->puntuacion = $validated['puntuacion'];
        $resena->imagenes = $imagenesPaths;
        $resena->user_id = Auth::id();
        $resena->estado = 'pendiente';
        $resena->save();

        return response()->json([
            'success' => true,
            'message' => 'Reseña creada exitosamente',
            'data' => $resena
        ], 201);
    }

    // PUT /api/emprendedores/{emprendedorId}/resenas/{resenaId}/estado
    public function updateEstado(Request $request, $emprendedorId, $resenaId)
    {
        try {
            // Validar que el emprendedor exista
            $emprendedor = \App\Models\Emprendedor::findOrFail($emprendedorId);

            // Validar que la reseña exista y pertenezca al emprendedor
            $resena = Resenas::where('id', $resenaId)
                ->where('emprendedor_id', $emprendedorId)
                ->firstOrFail();

            // Verificar que el usuario esté autenticado
            if (!Auth::check()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Debes iniciar sesión para realizar esta acción'
                ], 401);
            }

            // Validar el estado
            $validated = $request->validate([
                'estado' => 'required|in:aprobado,rechazado,pendiente'
            ]);

            // Actualizar el estado
            $resena->update($validated);

            return response()->json([
                'success' => true,
                'message' => 'Estado de reseña actualizado correctamente',
                'data' => [
                    'resena_id' => $resena->id,
                    'emprendedor_id' => $emprendedor->id,
                    'estado' => $resena->estado
                ]
            ]);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'No se encontró el emprendedor o la reseña especificada'
            ], 404);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Datos de entrada inválidos',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            Log::error('Error al actualizar estado de reseña', [
                'error' => $e->getMessage(),
                'resena_id' => $resenaId,
                'emprendedor_id' => $emprendedorId
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error al actualizar el estado de la reseña'
            ], 500);
        }
    }

    // DELETE /api/emprendedores/{emprendedorId}/resenas/{resenaId}
    public function destroy($emprendedorId, $resenaId)
    {
        try {
            // Validar que el emprendedor exista
            $emprendedor = \App\Models\Emprendedor::findOrFail($emprendedorId);

            // Validar que la reseña exista y pertenezca al emprendedor
            $resena = Resenas::where('id', $resenaId)
                ->where('emprendedor_id', $emprendedorId)
                ->firstOrFail();

            // Verificar que el usuario esté autenticado
            if (!Auth::check()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Debes iniciar sesión para realizar esta acción'
                ], 401);
            }

            // Eliminar imágenes asociadas
            if ($resena->imagenes) {
                foreach ($resena->imagenes as $imagen) {
                    Storage::disk('public')->delete($imagen);
                }
            }

            // Eliminar la reseña
            $resena->delete();

            return response()->json([
                'success' => true,
                'message' => "La reseña #{$resenaId} ha sido eliminada exitosamente",
                'data' => [
                    'resena_id' => $resenaId,
                    'emprendedor_id' => $emprendedorId
                ]
            ], 200);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'No se encontró el emprendedor o la reseña especificada'
            ], 404);
        } catch (\Exception $e) {
            Log::error('Error al eliminar reseña', [
                'error' => $e->getMessage(),
                'resena_id' => $resenaId,
                'emprendedor_id' => $emprendedorId
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error al eliminar la reseña'
            ], 500);
        }
    }
}
