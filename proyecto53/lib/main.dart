import 'package:flutter/material.dart';

// --- ARQUITECTURA: LA CLASE RESULT (EL CORAZÓN DEL SISTEMA) ---
// S = Success type, E = Error type
abstract class Result<S, E> {
  const Result();
}

class Success<S, E> extends Result<S, E> {
  final S value;
  Success(this.value);
}

class Failure<S, E> extends Result<S, E> {
  final E error;
  Failure(this.error);
}

// --- DOMINIO: MODELOS DE ERROR ---
enum SensorError { connectionTimeout, invalidData, hardwareFault }

// --- LÓGICA DE NEGOCIO (VIEWMODEL) ---
class TelemetryService {
  // Función robusta que devuelve un Result en lugar de lanzar excepciones
  Future<Result<double, SensorError>> fetchTemperature() async {
    await Future.delayed(const Duration(milliseconds: 1500)); // Latencia de red
    
    // Simulación de lógica de decisión de ingeniería
    bool isHardwareOk = true; 
    if (!isHardwareOk) return Failure(SensorError.hardwareFault);
    
    return Success(26.8); // Retorno exitoso
  }
}

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: ResultPatternScreen(),
));

class ResultPatternScreen extends StatefulWidget {
  const ResultPatternScreen({super.key});

  @override
  State<ResultPatternScreen> createState() => _ResultPatternScreenState();
}

class _ResultPatternScreenState extends State<ResultPatternScreen> {
  final TelemetryService _service = TelemetryService();
  String _displayValue = "--";
  String _statusMessage = "SISTEMA LISTO";
  bool _isProcessing = false;
  Color _accentColor = Colors.cyanAccent;

  Future<void> _requestData() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = "SOLICITANDO PAQUETES...";
      _accentColor = Colors.cyanAccent;
    });

    // EJECUCIÓN DEL PATRÓN RESULT
    final result = await _service.fetchTemperature();

    if (mounted) {
      setState(() {
        _isProcessing = false;
        // El "pattern matching" manual que obliga a manejar ambos casos
        if (result is Success<double, SensorError>) {
          _displayValue = "${result.value}°C";
          _statusMessage = "CONEXIÓN ESTABLE";
          _accentColor = Colors.greenAccent;
        } else if (result is Failure<double, SensorError>) {
          _displayValue = "ERR";
          _accentColor = Colors.redAccent;
          _statusMessage = "FALLO: ${result.error.name.toUpperCase()}";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // GitHub Dark Theme
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDiagnosticHexagon(),
              const SizedBox(height: 50),
              _buildConsoleOutput(),
              const SizedBox(height: 40),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticHexagon() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _accentColor.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: _accentColor.withOpacity(0.1), blurRadius: 40, spreadRadius: 5),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("TEMP_CORE", style: TextStyle(color: _accentColor, fontSize: 12, letterSpacing: 2)),
          const SizedBox(height: 5),
          Text(_displayValue, style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w100)),
        ],
      ),
    );
  }

  Widget _buildConsoleOutput() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal, color: Colors.green, size: 14),
              const SizedBox(width: 10),
              Text("STATUS_LOG_V1.0", style: TextStyle(color: Colors.grey[600], fontSize: 10)),
            ],
          ),
          const Divider(color: Colors.white10),
          Text("> $_statusMessage", style: TextStyle(color: _accentColor, fontFamily: 'Courier')),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: _isProcessing ? null : _requestData,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _accentColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isProcessing 
          ? const CircularProgressIndicator(color: Colors.cyanAccent)
          : Text("POLL SENSOR DATA", style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}