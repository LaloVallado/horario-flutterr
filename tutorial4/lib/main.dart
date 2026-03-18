import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const WebViewSimulatedApp());
}

class WebViewSimulatedApp extends StatelessWidget {
  const WebViewSimulatedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter WebView Simulator',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const WebViewStack(),
    );
  }
}

// --- SIMULACIÓN DE WEBVIEWCONTROLLER (Lógica de Control) ---
class SimulatedWebViewController {
  final Function(String) onUrlChanged;
  final Function(int) onProgressChanged;
  
  String currentUrl = 'https://flutter.dev';
  List<String> history = ['https://google.com'];

  SimulatedWebViewController({
    required this.onUrlChanged,
    required this.onProgressChanged,
  });

  Future<void> loadUrl(String url) async {
    onProgressChanged(0);
    // Simulamos latencia de red
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 150));
      onProgressChanged(i);
    }
    history.add(currentUrl);
    currentUrl = url;
    onUrlChanged(url);
  }

  void goBack() {
    if (history.isNotEmpty) {
      String previous = history.removeLast();
      loadUrl(previous);
    }
  }
}

// --- COMPONENTE PRINCIPAL (WebView Stack) ---
class WebViewStack extends StatefulWidget {
  const WebViewStack({super.key});

  @override
  State<WebViewStack> createState() => _WebViewStackState();
}

class _WebViewStackState extends State<WebViewStack> {
  late SimulatedWebViewController controller;
  int loadingProgress = 0;
  String displayUrl = 'https://flutter.dev';
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    controller = SimulatedWebViewController(
      onUrlChanged: (url) => setState(() => displayUrl = url),
      onProgressChanged: (progress) => setState(() => loadingProgress = progress),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Browser'),
        actions: [
          _NavigationControls(controller: controller),
          _MenuWidget(controller: controller),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: loadingProgress < 100
              ? LinearProgressIndicator(value: loadingProgress / 100)
              : const SizedBox.shrink(),
        ),
      ),
      body: Stack(
        children: [
          // EL "WEBVIEW" SIMULADO
          _SimulatedBrowserCanvas(url: displayUrl, progress: loadingProgress),
          
          // CAPA DE INTERFAZ SOBRE EL WEBVIEW
          if (loadingProgress < 100)
            Container(
              color: Colors.white,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCookieManager(context),
        child: const Icon(Icons.cookie),
      ),
    );
  }

  void _showCookieManager(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 200,
        child: Column(
          children: [
            const Text('Cookie Manager', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cleaning_services),
              title: const Text('Clear all cookies'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CONTROLES DE NAVEGACIÓN ---
class _NavigationControls extends StatelessWidget {
  final SimulatedWebViewController controller;
  const _NavigationControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => controller.goBack(),
        ),
        IconButton(
          icon: const Icon(Icons.replay),
          onPressed: () => controller.loadUrl(controller.currentUrl),
        ),
      ],
    );
  }
}

// --- MENÚ DE OPCIONES ---
class _MenuWidget extends StatelessWidget {
  final SimulatedWebViewController controller;
  const _MenuWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'https://youtube.com', child: Text('Ir a YouTube')),
        const PopupMenuItem(value: 'https://github.com', child: Text('Ir a GitHub')),
        const PopupMenuItem(value: 'html', child: Text('Ver Código HTML')),
      ],
      onSelected: (value) {
        if (value == 'html') {
          _showHtmlSnippet(context);
        } else {
          controller.loadUrl(value.toString());
        }
      },
    );
  }

  void _showHtmlSnippet(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('HTML Source'),
        content: const Text('<html><body><h1>Simulated Page</h1></body></html>'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }
}

// --- RENDERIZADOR DE CONTENIDO SIMULADO ---
class _SimulatedBrowserCanvas extends StatelessWidget {
  final String url;
  final int progress;

  const _SimulatedBrowserCanvas({required this.url, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F0F0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Row(
              children: [
                const Icon(Icons.lock, size: 16, color: Colors.green),
                const SizedBox(width: 10),
                Text(url, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildPageContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageContent() {
    return [
      Text('Welcome to ${url.split('//').last}', 
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      const Text('Esta es una simulación de WebView robusta. Aquí se renderizaría el contenido del DOM.',
        style: TextStyle(fontSize: 16)),
      const SizedBox(height: 30),
      ...List.generate(5, (index) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.web)),
          title: Text('Elemento de red #$index'),
          subtitle: const Text('Cargado mediante JavascriptChannel simulado'),
        ),
      )),
    ];
  }
}