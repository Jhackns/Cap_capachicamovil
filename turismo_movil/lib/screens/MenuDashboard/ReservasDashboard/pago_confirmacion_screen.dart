import 'package:flutter/material.dart';
import '../../../models/reserva.dart';

class PagoConfirmacionScreen extends StatefulWidget {
  final Reserva reserva;

  const PagoConfirmacionScreen({
    Key? key,
    required this.reserva,
  }) : super(key: key);

  @override
  State<PagoConfirmacionScreen> createState() => _PagoConfirmacionScreenState();
}

class _PagoConfirmacionScreenState extends State<PagoConfirmacionScreen> {
  String? _metodoPagoSeleccionado;

  final List<Map<String, dynamic>> _metodosPago = [
    {
      'id': 'yape',
      'nombre': 'Yape',
      'icono': Icons.phone_android,
      'color': const Color(0xFF9C27B0),
      'descripcion': 'Pago móvil rápido y seguro',
    },
    {
      'id': 'visa',
      'nombre': 'Visa',
      'icono': Icons.credit_card,
      'color': Colors.blue,
      'descripcion': 'Tarjeta de crédito/débito Visa',
    },
    {
      'id': 'mastercard',
      'nombre': 'Mastercard',
      'icono': Icons.credit_card,
      'color': Colors.orange,
      'descripcion': 'Tarjeta de crédito/débito Mastercard',
    },
  ];

  double get _precioTotal {
    return widget.reserva.precioTotal ??
        (widget.reserva.servicios?.fold<double>(0.0, (sum, servicio) => sum + (servicio.precio ?? 0.0)) ?? 0.0);
  }

  int get _totalServicios {
    return widget.reserva.servicios?.length ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Pago'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la reserva
            _buildInfoReserva(),
            const SizedBox(height: 24),

            // Métodos de pago
            _buildMetodosPago(),
            const SizedBox(height: 32),

            // Botón de proceder al pago
            _buildBotonProceder(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoReserva() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reserva: #${widget.reserva.codigo ?? 'N/A'}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total de servicios:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '$_totalServicios',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monto total:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'S/. ${_precioTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetodosPago() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Método de pago:',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF9C27B0),
          ),
        ),
        const SizedBox(height: 16),
        ..._metodosPago.map((metodo) => _buildMetodoPagoCard(metodo)).toList(),
      ],
    );
  }

  Widget _buildMetodoPagoCard(Map<String, dynamic> metodo) {
    final isSeleccionado = _metodoPagoSeleccionado == metodo['id'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _metodoPagoSeleccionado = metodo['id'];
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSeleccionado ? metodo['color'].withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSeleccionado ? metodo['color'] : Colors.grey[300]!,
              width: isSeleccionado ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: metodo['color'],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  metodo['icono'],
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metodo['nombre'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSeleccionado ? metodo['color'] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metodo['descripcion'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSeleccionado)
                Icon(
                  Icons.check_circle,
                  color: metodo['color'],
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotonProceder() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _metodoPagoSeleccionado != null ? _procederAlPago : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9C27B0),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Proceder al pago',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _procederAlPago() {
    if (_metodoPagoSeleccionado == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaPagoScreen(
          reserva: widget.reserva,
          metodoPago: _metodoPagoSeleccionado!,
          precioTotal: _precioTotal,
        ),
      ),
    );
  }
}

class PantallaPagoScreen extends StatelessWidget {
  final Reserva reserva;
  final String metodoPago;
  final double precioTotal;

  const PantallaPagoScreen({
    Key? key,
    required this.reserva,
    required this.metodoPago,
    required this.precioTotal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proceso de Pago'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Descripción
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Proceso de Pago',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Completa tu reserva de manera segura',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Contenido específico del método de pago
            _buildContenidoMetodoPago(),
            const SizedBox(height: 24),

            // Monto a pagar
            _buildMontoPagar(),
            const SizedBox(height: 24),

            // Instrucciones
            _buildInstrucciones(),
            const SizedBox(height: 32),

            // Botones de acción
            _buildBotonesAccion(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContenidoMetodoPago() {
    switch (metodoPago) {
      case 'yape':
        return _buildContenidoYape();
      case 'visa':
        return _buildContenidoVisa();
      case 'mastercard':
        return _buildContenidoMastercard();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildContenidoYape() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '💜',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pagar con Yape',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Escanea el código QR',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          // Código QR simulado
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code,
                    size: 80,
                    color: Color(0xFF9C27B0),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Código QR\nde pago',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenidoVisa() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.credit_card,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pagar con Visa',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Proceso de pago simulado',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenidoMastercard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.credit_card,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pagar con Mastercard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Proceso de pago simulado',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMontoPagar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Monto a pagar:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'S/. ${precioTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9C27B0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstrucciones() {
    List<String> instrucciones = [];
    
    switch (metodoPago) {
      case 'yape':
        instrucciones = [
          '1. Abre tu app de Yape',
          '2. Selecciona "Escanear QR"',
          '3. Escanea el código mostrado',
          '4. Confirma el pago en tu app',
        ];
        break;
      case 'visa':
      case 'mastercard':
        instrucciones = [
          '1. Ingresa los datos de tu tarjeta',
          '2. Verifica la información',
          '3. Confirma el pago',
          '4. Espera la confirmación',
        ];
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instrucciones:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...instrucciones.map((instruccion) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              instruccion,
              style: const TextStyle(fontSize: 16),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildBotonesAccion(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _simularPagoExitoso(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '✓ Simular pago exitoso',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _simularPagoExitoso(BuildContext context) {
    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Pago realizado exitosamente!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Navegar a la página principal
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false,
      );
    });
  }
} 