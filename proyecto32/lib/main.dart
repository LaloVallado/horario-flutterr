import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';

void main() {
  runApp(const MonitorMicroclimaApp());
}

class MonitorMicroclimaApp extends StatelessWidget {
  const MonitorMicroclimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const PantallaMonitor(),
    );
  }
}

class PantallaMonitor extends StatefulWidget {
  const PantallaMonitor({super.key});

  @override
  State<PantallaMonitor> createState() => _PantallaMonitorState();
}

class _PantallaMonitorState extends State<PantallaMonitor> {
  // Usaremos el WebSocket de precios de Binance (Bitcoin) porque es el más estable para pruebas
  late WebSocketChannel _canal;
  bool _estaConectado = false;
  String _ultimoMensaje = "Esperando datos del mercado...";

  @override
  void initState() {
    super.initState();
    _conectarAlServidor();
  }

  void _conectarAlServidor() {
    try {
      // Stream de precio de Bitcoin en tiempo real
      _canal = WebSocketChannel.connect(
        Uri.parse('wss://stream.binance.com:9443/ws/btcusdt@trade'),
      );

      _canal.stream.listen(
        (data) {
          setState(() {
            _estaConectado = true;
            _ultimoMensaje = data;
          });
        },
        onError: (error) {
          setState(() {
            _estaConectado = false;
            _ultimoMensaje = "Error: No se pudo conectar. Verifica tu internet o firewall.";
          });
        },
        onDone: () {
          setState(() {
            _estaConectado = false;
            _ultimoMensaje = "Conexión cerrada por el servidor.";
          });
        },
      );
    } catch (e) {
      print("Error de inicialización: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Monitor Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _canal.sink.close();
              _conectarAlServidor();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Indicador de estado visual
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _estaConectado ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _estaConectado ? Colors.green : Colors.red),
              ),
              child: Row(
                children: [
                  Icon(
                    _estaConectado ? Icons.bolt : Icons.sync_disabled,
                    color: _estaConectado ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _estaConectado ? "SISTEMA ONLINE" : "SISTEMA OFFLINE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _estaConectado ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Consola de datos
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _ultimoMensaje,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Nota: Este proyecto usa el stream de Binance para asegurar que la conexión WebSocket funcione en tu Mac M1.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _canal.sink.close();
    super.dispose();
  }
}