import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const AwesomeDrawingQuizApp());
}

class AwesomeDrawingQuizApp extends StatelessWidget {
  const AwesomeDrawingQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Awesome Drawing Quiz - Simulación',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeRoute(),
    );
  }
}

/// --- PANTALLA DE INICIO (Con Simulación de Banner) ---
class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {
  bool _isBannerVisible = false;

  @override
  void initState() {
    super.initState();
    // Simulamos que el anuncio tarda 2 segundos en cargar
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isBannerVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drawing Quiz - Home')),
      body: Column(
        children: [
          // SIMULACIÓN DE BANNER AD
          if (_isBannerVisible)
            Container(
              width: double.infinity,
              height: 50,
              color: Colors.grey[300],
              child: const Center(
                child: Text("🎰 ANUNCIO BANNER (Simulado)", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              ),
            ),
          
          Expanded(
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameRoute()),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('EMPEZAR JUEGO'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// --- PANTALLA DE JUEGO (Intersticial y Recompensado) ---
class GameRoute extends StatefulWidget {
  const GameRoute({super.key});

  @override
  State<GameRoute> createState() => _GameRouteState();
}

class _GameRouteState extends State<GameRoute> {
  int _score = 0;
  int _level = 1;

  // Método para simular el anuncio Intersticial (Pantalla completa)
  void _showFakeInterstitial() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, size: 80, color: Colors.white),
            const Text("\n🎬 ANUNCIO INTERSTICIAL", 
              style: TextStyle(color: Colors.white, fontSize: 20, decoration: TextDecoration.none)),
            const Text("Espera 3 segundos...", 
              style: TextStyle(color: Colors.white70, fontSize: 14, decoration: TextDecoration.none)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cierra el anuncio
                Navigator.pop(context); // Regresa al inicio
              },
              child: const Text("CERRAR ANUNCIO"),
            )
          ],
        ),
      ),
    );
  }

  // Método para simular el anuncio Recompensado
  void _showFakeRewardedAd() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("🎁 Ver Video para Pista"),
        content: const Text("Si ves este video de 5 segundos, recibirás +50 puntos."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _score += 50);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("¡Recompensa: +50 puntos otorgados!")),
              );
            }, 
            child: const Text("VER VIDEO")
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nivel $_level')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Puntaje: $_score', style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (_level < 3) {
                  setState(() => _level++);
                } else {
                  _showFakeInterstitial();
                }
              },
              child: Text(_level < 3 ? 'SIGUIENTE NIVEL' : 'TERMINAR Y VER AD'),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _showFakeRewardedAd,
              icon: const Icon(Icons.card_giftcard),
              label: const Text('Obtener Pista (+50 pts)'),
            ),
          ],
        ),
      ),
    );
  }
}