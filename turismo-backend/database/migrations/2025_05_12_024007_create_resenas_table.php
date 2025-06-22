<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('resenas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('emprendedor_id')->constrained('emprendedores')->onDelete('cascade');
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null'); // Si es usuario registrado
            $table->string('nombre_autor'); // Para reseñas anónimas
            $table->text('comentario');
            $table->unsignedTinyInteger('puntuacion')->between(1, 5);
            $table->json('imagenes')->nullable(); // Array de rutas de imágenes ["resenas/img1.jpg", ...]
            $table->enum('estado', ['pendiente', 'aprobado', 'rechazado'])->default('pendiente');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('resenas');
    }
};
