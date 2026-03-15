import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // Este se genera con 'flutterfire configure'
import 'dart:async';

// --- TU CONTROLADOR ---
class FirestoreController {
  final FirebaseFirestore instance;
  late final DocumentReference _matchRef = instance.collection('matches').doc('partida_test');
  StreamSubscription? _subscription;

  FirestoreController({required this.instance}) {
    _subscription = _matchRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        print("Sincronizado con la nube: ${snapshot.data()}");
      }
    });
  }

  Future<void> enviarMovimiento(String carta) async {
    await _matchRef.set({
      'ultima_carta': carta,
      'jugador': 'Eduardo Vallado',
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void dispose() => _subscription?.cancel();
}

// --- EL PUNTO DE ENTRADA QUE TE FALTABA ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialización de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MaterialApp(
    home: GameScreen(),
  ));
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late FirestoreController _controller;

  @override
  void initState() {
    super.initState();
    // Instanciamos el controlador pasando la instancia de Firestore
    _controller = FirestoreController(instance: FirebaseFirestore.instance);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proyecto 23: Multiplayer')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _controller.enviarMovimiento('As de Espadas'),
          child: const Text('Enviar Movimiento a la Nube'),
        ),
      ),
    );
  }
}