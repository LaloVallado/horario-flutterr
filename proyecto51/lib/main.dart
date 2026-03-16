import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ParallaxMonitorScreen(),
    ));

class ParallaxMonitorScreen extends StatelessWidget {
  const ParallaxMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(), // Scroll suave estilo iOS
        slivers: [
          // --- ENCABEZADO CON EFECTO PARALLAX CORREGIDO ---
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            stretch: true, // Efecto de estiramiento al jalar hacia abajo
            backgroundColor: const Color(0xFF1A1C20),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              title: const Text(
                'SISTEMA DE CONTROL',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 2.0,
                  shadows: [Shadow(blurRadius: 12, color: Colors.black)],
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // MANEJO ROBUSTO DE IMAGEN
                  Image.network(
                    'https://images.unsplash.com/photo-1530836361253-efad5cb2fe2e?auto=format&fit=crop&q=80',
                    fit: BoxFit.cover,
                    // Si falla la carga (Error 404 u otros)
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF2D3142),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off, color: Colors.white54, size: 50),
                            SizedBox(height: 10),
                            Text("Modo Offline", style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                      );
                    },
                    // Indicador de carga profesional
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.tealAccent,
                        ),
                      );
                    },
                  ),
                  // Overlay degradado para legibilidad
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black26,
                          Colors.transparent,
                          Colors.black87
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- CUERPO DEL DASHBOARD ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Estado de Sensores"),
                  const SizedBox(height: 20),
                  // Grid de tarjetas de sensores
                  Row(
                    children: [
                      Expanded(child: _buildMiniCard("Humedad", "65%", Icons.water_drop, Colors.blue)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildMiniCard("Temp", "24°C", Icons.thermostat, Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildFullCard("Calidad del Aire", "Excelente (12 AQI)", Icons.air, Colors.green),
                  const SizedBox(height: 35),
                  _buildSectionHeader("Historial de Red"),
                ],
              ),
            ),
          ),

          // --- LISTA DE EVENTOS ---
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildLogItem(index),
              childCount: 15,
            ),
          ),
          
          // Espacio extra al final para que el FAB no tape nada
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // --- WIDGETS DE ALTO NIVEL DE DISEÑO ---

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 24, color: Colors.tealAccent),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w800, 
            color: Color(0xFF4F5D75),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFullCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3142),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.tealAccent, size: 30),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: const Icon(Icons.code, size: 16, color: Colors.blueGrey),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sync Nodo #$index", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Text("Data packet received via HTTP", style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const Spacer(),
          const Text("12:41", style: TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}