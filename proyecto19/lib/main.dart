import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Para detectar si es Web
import 'package:flutter/material.dart';

Future<void> main() async {
  // Aseguramos la inicialización de los servicios nativos
  WidgetsFlutterBinding.ensureInitialized();

  // Obtenemos las cámaras disponibles
  final cameras = await availableCameras();
  
  // Si no hay cámaras (pasa a veces en simuladores mal configurados)
  if (cameras.isEmpty) {
    runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('No se encontraron cámaras')))));
    return;
  }

  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: TakePictureScreen(camera: firstCamera),
    ),
  );
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false, // Desactivamos audio para simplificar permisos
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proyecto 19 - Cámara')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            // Capturamos la foto
            final image = await _controller.takePicture();

            if (!mounted) return;

            // Navegamos a la pantalla de resultado
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: image.path),
              ),
            );
          } catch (e) {
            print("Error al capturar: $e");
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado de Captura')),
      body: Center(
        // LA CORRECCIÓN CRÍTICA ESTÁ AQUÍ:
        child: kIsWeb
            ? Image.network(imagePath) // En Safari/Web el path es un Blob URL
            : Image.file(File(imagePath)), // En Android/iOS es un archivo real
      ),
    );
  }
}