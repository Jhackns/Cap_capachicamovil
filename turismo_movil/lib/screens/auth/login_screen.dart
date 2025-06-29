import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../services/connectivity_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_app_bar.dart';
import '../../utils/error_handler.dart';

class LoginScreen extends StatefulWidget {
  final String? message;
  
  const LoginScreen({Key? key, this.message}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _authService = AuthService();
  bool _isLogin = true;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Iniciar Sesión'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Message display (if any)
                        if (widget.message != null) ...[  
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    widget.message!,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        // Header
                        Text(
                          _isLogin ? 'Iniciar Sesión' : 'Crear Cuenta',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        
                        // Username field (only for register)
                        if (!_isLogin)
                          CustomTextField(
                            label: 'Nombre de usuario',
                            hint: 'Ingresa tu nombre de usuario',
                            controller: _usernameController,
                            prefixIcon: const Icon(Icons.person),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa un nombre de usuario';
                              }
                              return null;
                            },
                          ),
                        
                        // Email field
                        CustomTextField(
                          label: 'Correo electrónico',
                          hint: 'Ingresa tu correo electrónico',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu correo electrónico';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Ingresa un correo electrónico válido';
                            }
                            return null;
                          },
                        ),
                        
                        // Password field
                        CustomTextField(
                          label: 'Contraseña',
                          hint: 'Ingresa tu contraseña',
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu contraseña';
                            }
                            if (!_isLogin && value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Error message
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        
                        // Submit button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: const Color(0xFF9C27B0),
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse'),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Google Sign In Button
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          icon: const Icon(Icons.g_mobiledata, size: 24),
                          label: Text(_isLogin ? 'Continuar con Google' : 'Registrarse con Google'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[400])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'o',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[400])),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Toggle between login and register
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/register');
                          },
                          child: const Text('¿No tienes una cuenta? Regístrate'),
                        ),
                        
                        // Back to home
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context, 
                              '/main',
                              (route) => false, // Elimina todas las rutas anteriores
                            );
                          },
                          child: const Text('Volver al inicio'),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Botón de diagnóstico
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _runDiagnostics,
                          icon: const Icon(Icons.bug_report),
                          label: const Text('Diagnóstico de Conexión'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: const BorderSide(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final success = await context.read<AuthProvider>().login(
          _emailController.text, 
          _passwordController.text
        );
        
        if (mounted && success) {
          // Redirigir siempre al dashboard unificado
          Navigator.of(context).pushReplacementNamed('/dashboard');
        } else if (mounted) {
          // Si el login falla pero no lanza excepción, mostrar error genérico
          setState(() {
            _error = 'Correo o contraseña incorrectos.';
          });
        }
      } catch (e) {
        if (mounted) {
          // Traducir mensajes comunes del backend
          String errorMsg = ErrorHandler.getErrorMessage(e);
          if (e.toString().contains('These credentials do not match our records') ||
              e.toString().toLowerCase().contains('invalid credentials') ||
              e.toString().contains('Credenciales inválidas')) {
            errorMsg = 'Correo o contraseña incorrectos.';
          } else if (e.toString().toLowerCase().contains('user not found') ||
                     e.toString().toLowerCase().contains('usuario no existe')) {
            errorMsg = 'El usuario no existe.';
          } else if (e.toString().toLowerCase().contains('no se recibió el token')) {
            errorMsg = 'Error inesperado: no se recibió el token de autenticación.';
          } else if (e.toString().toLowerCase().contains('timeout')) {
            errorMsg = 'No se pudo conectar con el servidor. Intenta nuevamente.';
          } else if (e.toString().toLowerCase().contains('network')) {
            errorMsg = 'Error de red. Verifica tu conexión a internet.';
          }
          setState(() {
            _error = errorMsg;
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Implementar autenticación con Google
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Autenticación con Google próximamente disponible'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al iniciar sesión con Google: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final connectivityService = ConnectivityService();
      final results = await connectivityService.runDiagnostics();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Diagnóstico de Conexión'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DiagnosticResult(
                    label: 'Backend Base',
                    result: results['backend_base'] ?? 'Error',
                    isSuccess: results['backend_base'] == 'Conectado',
                  ),
                  const SizedBox(height: 8),
                  _DiagnosticResult(
                    label: 'API Login',
                    result: results['api_login'] ?? 'Error',
                    isSuccess: results['api_login'] == 'Conectado',
                  ),
                  const SizedBox(height: 8),
                  _DiagnosticResult(
                    label: 'API Users',
                    result: results['api_users'] ?? 'Error',
                    isSuccess: results['api_users'] == 'Conectado',
                  ),
                  const SizedBox(height: 8),
                  _DiagnosticResult(
                    label: 'API Roles',
                    result: results['api_roles'] ?? 'Error',
                    isSuccess: results['api_roles'] == 'Conectado',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en diagnóstico: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _DiagnosticResult extends StatelessWidget {
  final String label;
  final String result;
  final bool isSuccess;

  const _DiagnosticResult({
    required this.label,
    required this.result,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          color: isSuccess ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                result,
                style: TextStyle(
                  color: isSuccess ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
