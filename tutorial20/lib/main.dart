// ============================================================
//  CONFIGURACIÓN PREVIA (hacer ANTES de correr la app)
// ============================================================
//
//  1. Agregar dependencias en pubspec.yaml:
//       dependencies:
//         google_maps_flutter: ^2.5.0
//         http: ^1.2.0
//
//  2. ANDROID → android/app/src/main/AndroidManifest.xml
//     Dentro de <application> agregar:
//       <meta-data
//         android:name="com.google.android.geo.API_KEY"
//         android:value="TU_API_KEY_AQUI"/>
//     Y dentro de <manifest>:
//       <uses-permission android:name="android.permission.INTERNET"/>
//
//  3. iOS → ios/Runner/AppDelegate.swift
//       import GoogleMaps
//       GMSServices.provideAPIKey("TU_API_KEY_AQUI")
//     Y en ios/Runner/Info.plist agregar:
//       NSLocationWhenInUseUsageDescription
//
//  4. Obtener API Key gratuita:
//     https://console.cloud.google.com → APIs → Maps SDK for Android/iOS
//
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const GoogleMapsApp());
}

// ── App ───────────────────────────────────────────────────────────────────────
class GoogleMapsApp extends StatelessWidget {
  const GoogleMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Maps Flutter',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
      ),
      home: const MapScreen(),
    );
  }
}

// ── Modelo de ubicación ───────────────────────────────────────────────────────
class Location {
  final String name;
  final double lat;
  final double lng;
  final String? description;

  const Location({
    required this.name,
    required this.lat,
    required this.lng,
    this.description,
  });

  /// Estructura esperada del JSON:
  /// { "name": "...", "lat": 0.0, "lng": 0.0, "description": "..." }
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }
}

// ── Servicio web ──────────────────────────────────────────────────────────────
class LocationService {
  // Reemplaza con tu URL real.
  // Debe devolver un JSON array: [ { name, lat, lng, description }, ... ]
  static const String _url =
      'https://flutter-maps-codelab.firebaseio.com/locations.json';

  /// Obtiene ubicaciones del servicio web.
  /// Si falla, devuelve datos de ejemplo locales.
  static Future<List<Location>> fetchLocations() async {
    try {
      final response = await http
          .get(Uri.parse(_url))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        // Firebase devuelve Map; una API REST normal puede devolver List
        List<dynamic> list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map) {
          list = decoded.values.toList();
        } else {
          return _fallbackLocations();
        }

        return list
            .whereType<Map<String, dynamic>>()
            .map(Location.fromJson)
            .toList();
      }
    } catch (_) {
      // Sin red o URL de ejemplo → datos locales
    }
    return _fallbackLocations();
  }

  /// Datos de ejemplo (Ciudad de México).
  static List<Location> _fallbackLocations() {
    return const [
      Location(
        name: 'Zócalo',
        lat: 19.4326,
        lng: -99.1332,
        description: 'Plaza de la Constitución, Centro Histórico',
      ),
      Location(
        name: 'Chapultepec',
        lat: 19.4200,
        lng: -99.1817,
        description: 'Bosque y Castillo de Chapultepec',
      ),
      Location(
        name: 'Xochimilco',
        lat: 19.2570,
        lng: -99.1040,
        description: 'Canales y chinampas patrimonio UNESCO',
      ),
      Location(
        name: 'Teotihuacán',
        lat: 19.6925,
        lng: -98.8438,
        description: 'Pirámides del Sol y la Luna',
      ),
      Location(
        name: 'Palacio de Bellas Artes',
        lat: 19.4353,
        lng: -99.1412,
        description: 'Máximo recinto cultural de México',
      ),
    ];
  }
}

// ── Pantalla principal ────────────────────────────────────────────────────────
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(19.4326, -99.1332),
    zoom: 10,
  );

  final Set<Marker> _markers = {};
  List<Location> _locations = [];
  bool _isLoading = true;
  String? _error;
  Location? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  // ── Carga de datos ──────────────────────────────────────────────────────────
  Future<void> _loadLocations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final locations = await LocationService.fetchLocations();
      if (!mounted) return;
      setState(() {
        _locations = locations;
        _markers.clear();
        for (final loc in locations) {
          _markers.add(
            Marker(
              markerId: MarkerId(loc.name),
              position: LatLng(loc.lat, loc.lng),
              infoWindow: InfoWindow(
                title: loc.name,
                snippet: loc.description,
              ),
              onTap: () => _onMarkerTap(loc),
            ),
          );
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onMarkerTap(Location loc) {
    setState(() => _selectedLocation = loc);
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(loc.lat, loc.lng), zoom: 14),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Flutter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar ubicaciones',
            onPressed: _isLoading ? null : _loadLocations,
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Mapa ──────────────────────────────────────────────────────────
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            onTap: (_) => setState(() => _selectedLocation = null),
          ),

          // ── Cargando ──────────────────────────────────────────────────────
          if (_isLoading)
            const Center(
              child: Card(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Cargando ubicaciones…'),
                    ],
                  ),
                ),
              ),
            ),

          // ── Error ─────────────────────────────────────────────────────────
          if (_error != null)
            Center(
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 36),
                      const SizedBox(height: 8),
                      Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _loadLocations,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Detalle de marcador seleccionado ──────────────────────────────
          if (_selectedLocation != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 20,
              child: _LocationCard(
                location: _selectedLocation!,
                onClose: () =>
                    setState(() => _selectedLocation = null),
              ),
            ),
        ],
      ),

      // ── FAB: lista de ubicaciones ──────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLocationsList,
        icon: const Icon(Icons.list),
        label: Text('${_locations.length} lugares'),
      ),
    );
  }

  // ── Bottom sheet ────────────────────────────────────────────────────────────
  void _showLocationsList() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ubicaciones (${_locations.length})',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _locations.length,
                itemBuilder: (context, i) {
                  final loc = _locations[i];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF1A73E8),
                      child: Icon(Icons.location_on,
                          color: Colors.white, size: 18),
                    ),
                    title: Text(loc.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    subtitle: loc.description != null
                        ? Text(
                            loc.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      _onMarkerTap(loc);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

// ── Tarjeta de detalle de ubicación ──────────────────────────────────────────
class _LocationCard extends StatelessWidget {
  final Location location;
  final VoidCallback onClose;

  const _LocationCard({
    required this.location,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF1A73E8),
              child: Icon(Icons.location_on, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    location.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  if (location.description != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      location.description!,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${location.lat.toStringAsFixed(4)}, '
                    '${location.lng.toStringAsFixed(4)}',
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
              tooltip: 'Cerrar',
            ),
          ],
        ),
      ),
    );
  }
}