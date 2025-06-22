<?php

namespace App\Http\Controllers\API\Emprendedores\Resenas\Policies;

use App\Models\User;
use App\Models\Resenas;
use Illuminate\Auth\Access\HandlesAuthorization;
use Illuminate\Support\Facades\Log;

class ResenasPolicy
{
    use HandlesAuthorization;

    /**
     * Determine whether the user can manage reseñas.
     */
    public function gestionarResenas(User $user, $emprendedor)
    {
        // Log para debug
        Log::info('Verificando autorización para gestionar reseñas', [
            'user_id' => $user->id,
            'user_roles' => $user->getRoleNames(),
            'emprendedor_id' => $emprendedor->id
        ]);

        // Si el usuario es administrador del sistema
        if ($user->hasRole('admin') || $user->hasRole('super-admin')) {
            Log::info('Usuario es admin, autorización concedida');
            return true;
        }

        // Si el usuario es administrador del emprendimiento
        $esAdminEmprendimiento = $user->emprendimientos()
            ->where('emprendedores.id', $emprendedor->id)
            ->exists();

        Log::info('Verificación de administrador de emprendimiento', [
            'es_admin' => $esAdminEmprendimiento
        ]);

        return $esAdminEmprendimiento;
    }
}
