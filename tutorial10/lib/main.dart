import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const AdMobCodelabApp());
}

// --- 1. MOTOR DE SIMULACIÓN DE ADMOB (Core Engine) ---

enum AdStatus { initial, loading, loaded, error, opened, closed }

class AdMobSimulator {
  // Simulación de Singleton para el SDK
  static final AdMobSimulator instance = AdMobSimulator._internal();
  AdMobSimulator._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
    debugPrint("AdMob SDK Initialized");
  }

  // IDs de prueba oficiales (Simulados)
  static const String bannerTestId = "ca-app-pub-3940256099942544/6300978111";
  static const String interstitialTestId = "ca-app-pub-3940256099942544/1033173712";
  static const String nativeTestId = "ca-app-pub-3940256099942544/2247696110";
}

// --- 2. GESTORES DE ANUNCIOS (Lifecycle Management) ---

class InterstitialAdManager {
  AdStatus status = AdStatus.initial;
  
  Future<void> load(Function onLoaded) async {
    status = AdStatus.loading;
    await Future.delayed(const Duration(seconds: 2)); // Simula petición de red
    status = AdStatus.loaded;
    onLoaded();
  }

  void show(BuildContext context, Function onClosed) {
    if (status == AdStatus.loaded) {
      status = AdStatus.opened;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _InterstitialOverlay(onClosed: () {
          status = AdStatus.closed;
          onClosed();
        }),
      );
    }
  }
}

// --- 3. UI DE LA APLICACIÓN (News Feed con Ads Intercalados) ---

class AdMobCodelabApp extends StatelessWidget {
  const AdMobCodelabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const MainAdFeed(),
    );
  }
}

class MainAdFeed extends StatefulWidget {
  const MainAdFeed({super.key});

  @override
  State<MainAdFeed> createState() => _MainAdFeedState();
}

class _MainAdFeedState extends State<MainAdFeed> {
  final InterstitialAdManager _interstitialManager = InterstitialAdManager();
  final ScrollController _scrollController = ScrollController();
  
  // Lista mixta: Noticias y Anuncios
  final List<dynamic> _feedItems = [];
  bool _isInterstitialReady = false;

  @override
  void initState() {
    super.initState();
    _initAdMob();
    _generateFeed();
  }

  Future<void> _initAdMob() async {
    await AdMobSimulator.instance.initialize();
    _interstitialManager.load(() {
      if (mounted) setState(() => _isInterstitialReady = true);
    });
  }

  void _generateFeed() {
    for (int i = 1; i <= 20; i++) {
      _feedItems.add("Noticia importante #$i: Avances en ingeniería de software.");
      // Insertar un anuncio nativo cada 5 elementos
      if (i % 5 == 0) {
        _feedItems.add(_NativeAdMarker());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdMob Native Integration'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.bolt),
                onPressed: _isInterstitialReady ? _showInterstitial : null,
              ),
              if (_isInterstitialReady)
                Positioned(right: 8, top: 8, child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _feedItems.length,
              itemBuilder: (context, index) {
                final item = _feedItems[index];
                if (item is _NativeAdMarker) {
                  return const NativeAdWidget();
                }
                return _NewsCard(text: item as String);
              },
            ),
          ),
          // --- BANNER AD SIEMPRE VISIBLE ---
          const BannerAdWidget(),
        ],
      ),
    );
  }

  void _showInterstitial() {
    _interstitialManager.show(context, () {
      setState(() => _isInterstitialReady = false);
      // Recargar para la próxima vez
      _interstitialManager.load(() {
        if (mounted) setState(() => _isInterstitialReady = true);
      });
    });
  }
}

// --- 4. COMPONENTES DE ANUNCIOS (Widgets) ---

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      color: Colors.grey[200],
      child: Row(
        children: [
          Container(width: 50, color: Colors.amber, child: const Center(child: Text("Ad", style: TextStyle(fontWeight: FontWeight.bold)))),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text("Este es un Banner Ad (320x50). Haz clic para saber más.", maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          TextButton(onPressed: () {}, child: const Text("VISITAR")),
        ],
      ),
    );
  }
}

class NativeAdWidget extends StatelessWidget {
  const NativeAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), color: Colors.orange[100], child: const Text("Ad", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              const Text("Anuncio Patrocinado", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.shopping_cart, size: 40, color: Colors.green)),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("¡Mejora tu suscripción!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Obtén acceso ilimitado a todas las herramientas pro.", style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, child: const Text("INSTALAR AHORA"))),
        ],
      ),
    );
  }
}

class _InterstitialOverlay extends StatelessWidget {
  final VoidCallback onClosed;
  const _InterstitialOverlay({required this.onClosed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.close), onPressed: () { Navigator.pop(context); onClosed(); })),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text("Video Ad Interstitial", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Text("Este anuncio ocupa toda la pantalla y se muestra en puntos de transición naturales de la app.", textAlign: TextAlign.center),
            ),
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[200]!)),
            const SizedBox(height: 40),
            ElevatedButton(onPressed: () { Navigator.pop(context); onClosed(); }, child: const Text("SALTAR ANUNCIO")),
          ],
        ),
      ),
    );
  }
}

// --- HELPERS ---

class _NewsCard extends StatelessWidget {
  final String text;
  const _NewsCard({required this.text});
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Padding(padding: const EdgeInsets.all(20), child: Text(text)));
}

class _NativeAdMarker {}