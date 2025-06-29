import 'package:flutter/material.dart';
// Importaciones necesarias para la pantalla de configuración

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  int _selectedColorIndex = 0;

  // Opciones de colores para la aplicación
  final List<ColorOption> _colorOptions = [
    ColorOption(
      name: 'Azul',
      primary: Colors.blue,
      secondary: Colors.blueAccent,
    ),
    ColorOption(
      name: 'Verde',
      primary: Colors.green,
      secondary: Colors.lightGreen,
    ),
    ColorOption(
      name: 'Morado',
      primary: Colors.purple,
      secondary: Colors.purpleAccent,
    ),
    ColorOption(
      name: 'Naranja',
      primary: Colors.orange,
      secondary: Colors.deepOrange,
    ),
    ColorOption(
      name: 'Rojo',
      primary: Colors.red,
      secondary: Colors.redAccent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Las preferencias se cargarán en didChangeDependencies
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cargar preferencias después de que el widget esté completamente inicializado
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  void _toggleThemeMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    // Aquí se guardarían las preferencias
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tema ${_isDarkMode ? 'oscuro' : 'claro'} activado'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _changeAppColor(int index) {
    setState(() {
      _selectedColorIndex = index;
    });
    // Aquí se guardarían las preferencias
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Color ${_colorOptions[index].name} seleccionado'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Tema de la aplicación'),
                  subtitle: const Text('Cambiar entre tema claro y oscuro'),
                  trailing: Switch(
                    value: _isDarkMode,
                    onChanged: (value) => _toggleThemeMode(),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Divider(height: 1),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Color principal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colorOptions.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () => _changeAppColor(index),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: _colorOptions[index].primary,
                            child: _selectedColorIndex == index
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Notificaciones'),
                  subtitle: const Text('Configurar notificaciones de la app'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funcionalidad en desarrollo'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.language,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Idioma'),
                  subtitle: const Text('Español'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funcionalidad en desarrollo'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Acerca de'),
                  subtitle: const Text('Información sobre la aplicación'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acerca de'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Tour Capachica'),
            SizedBox(height: 8),
            Text('Versión 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Aplicación desarrollada para promover el turismo y los emprendimientos locales en la península de Capachica, Puno, Perú.',
            ),
          ],
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
}

class ColorOption {
  final String name;
  final Color primary;
  final Color secondary;

  ColorOption({
    required this.name,
    required this.primary,
    required this.secondary,
  });
}
