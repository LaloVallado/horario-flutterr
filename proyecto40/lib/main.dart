import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Proyecto 40 - ITM',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: ConfigForm(),
          ),
        ),
      ),
    );
  }
}

class ConfigForm extends StatefulWidget {
  const ConfigForm({super.key});

  @override
  State<ConfigForm> createState() => _ConfigFormState();
}

class _ConfigFormState extends State<ConfigForm> {
  // Estado inicial del widget
  String _mensaje = "Esperando configuración...";
  final _controller = TextEditingController();

  void _actualizarConfiguracion() {
    setState(() {
      if (_controller.text.isEmpty) {
        _mensaje = "Por favor ingresa un valor";
      } else {
        _mensaje = "Set: ${_controller.text}°C";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.thermostat, size: 50, color: Colors.teal),
        const SizedBox(height: 20),
        Text(
          _mensaje,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          key: const Key('campo_temperatura'), // Key para el Test
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Umbral de Temperatura',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.settings_input_component),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _actualizarConfiguracion,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('ACTUALIZAR'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}