import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_app_bar.dart';

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
                        
                        // Toggle between login and register
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                            authProvider.clearError();
                          },
                          child: Text(
                            _isLogin
                                ? '¿No tienes una cuenta? Regístrate'
                                : '¿Ya tienes una cuenta? Inicia sesión',
                          ),
                        ),
                        
                        // Back to home
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context, 
                              '/home',
                              (route) => false, // Elimina todas las rutas anteriores
                            );
                          },
                          child: const Text('Volver al inicio'),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Diagnostic button
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _runDiagnostic,
                          icon: const Icon(Icons.bug_report, size: 18),
                          label: const Text('Diagnóstico de Conexión'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
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
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = e.toString();
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

  Future<void> _runDiagnostic() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final diagnosticInfo = await ConnectivityService.getDiagnosticInfo();
      
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
                  Text('URL Base: ${diagnosticInfo['baseUrl']}'),
                  const SizedBox(height: 8),
                  Text('URL Login: ${diagnosticInfo['loginUrl']}'),
                  const SizedBox(height: 16),
                  Text('Conexión Backend: ${diagnosticInfo['backendConnection'] ? '✅ OK' : '❌ FALLO'}'),
                  Text('Endpoint Status: ${diagnosticInfo['statusEndpoint'] ? '✅ OK' : '❌ FALLO'}'),
                  Text('Endpoint Login: ${diagnosticInfo['loginEndpoint'] ? '✅ OK' : '❌ FALLO'}'),
                  if ((diagnosticInfo['errors'] as List<String>).isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Errores:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...(diagnosticInfo['errors'] as List<String>).map((error) => 
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 4),
                        child: Text('• $error', style: const TextStyle(color: Colors.red)),
                      )
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error en diagnóstico: $e';
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
