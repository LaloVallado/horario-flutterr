import 'dart:async';
import 'package:flutter/material.dart';

// --- SERVICIO DE REPORTERÍA (SIMULADO) ---
// En producción, aquí integrarías Sentry.init() o FirebaseCrashlytics
class ErrorReporter {
  static void log(Object error, StackTrace stackTrace) {
    // Aquí enviarías el error a tu servidor o servicio de monitoreo
    print("🚀 [SENTRY_LOG]: Enviando reporte al servidor...");
    print("❌ ERROR: $error");
  }
}

void main() {
  // CAPTURA GLOBAL: Encapsulamos toda la app en un Zone para errores asíncronos
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    // Captura errores del framework de Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      ErrorReporter.log(details.exception, details.stack!);
    };

    runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ErrorMonitorDashboard(),
    ));
  }, (error, stack) => ErrorReporter.log(error, stack));
}

class ErrorMonitorDashboard extends StatefulWidget {
  const ErrorMonitorDashboard({super.key});

  @override
  State<ErrorMonitorDashboard> createState() => _ErrorMonitorDashboardState();
}

class _ErrorMonitorDashboardState extends State<ErrorMonitorDashboard> {
  String _lastStatus = "Sistema Estable";
  Color _statusColor = Colors.greenAccent;

  void _simularFalloCritico() {
    try {
      // Simulamos una operación ilegal (división por cero o acceso a null)
      dynamic hardwareData = null;
      print(hardwareData.temperature); // Esto disparará una excepción
    } catch (e, stack) {
      setState(() {
        _lastStatus = "Error reportado al servidor";
        _statusColor = Colors.redAccent;
      });
      ErrorReporter.log(e, stack);
      _mostrarAlertaDeError(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark Mode Industrial
      appBar: AppBar(
        title: const Text('TELEMETRÍA DE FALLOS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 40),
            _buildActionCard(
              "Simular Error de Red",
              "Prueba la captura de excepciones HTTP",
              Icons.wifi_off,
              _simularFalloCritico,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueGrey[900]!, Colors.black]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.security, color: _statusColor, size: 50),
          const SizedBox(height: 15),
          Text(_lastStatus, style: TextStyle(color: _statusColor, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("MONITOREO ACTIVO", style: TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String sub, IconData icon, VoidCallback action) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  void _mostrarAlertaDeError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Error capturado y enviado a los logs de ingeniería."),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}