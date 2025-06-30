import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;

  final LatLng _capachicaLatLng = const LatLng(-15.6927, -69.8194);

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionUsuario();
  }

  Future<void> _obtenerUbicacionUsuario() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final userLocation = await location.getLocation();
    setState(() {
      _userLocation = LatLng(userLocation.latitude!, userLocation.longitude!);
    });
  }

  void _centrarEnUbicacion() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa Turístico Capachica')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _capachicaLatLng,
          initialZoom: 13,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate:
            'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZ3JpbWFsZG9hcnJlZG9uZG8iLCJhIjoiY21hYmJvMGpoMmF6YjJrb29tNnJ0MXQ1dyJ9.Em9vVlsuF3-ddqRnxTMYAw',
            userAgentPackageName: 'com.example.turismo_capachica',
          ),
          MarkerLayer(
            markers: [
              const Marker(
                point: LatLng(-15.6927, -69.8194),
                width: 40,
                height: 40,
                child: Icon(Icons.location_pin, size: 40, color: Colors.red),
              ),
              if (_userLocation != null)
                Marker(
                  point: _userLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.person_pin_circle,
                      size: 40, color: Colors.blue),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centrarEnUbicacion,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}