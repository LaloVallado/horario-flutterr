import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const FirebaseSimulatedApp());
}

// --- MODELO DE DATOS ---

class GuestbookMessage {
  final String name;
  final String message;
  final DateTime timestamp;

  GuestbookMessage({
    required this.name, 
    required this.message, 
    required this.timestamp
  });
}

enum AttendingStatus { unknown, attending, notAttending }

// --- MOTOR DE SIMULACIÓN FIREBASE (Capa de Backend) ---

class MockFirebase {
  // Simulación de Firebase Auth
  static final StreamController<String?> _authController = StreamController<String?>.broadcast();
  static String? _currentUser;

  // Simulación de Firestore (Colección 'guestbook')
  static final List<GuestbookMessage> _messages = [];
  static final StreamController<List<GuestbookMessage>> _firestoreController = StreamController<List<GuestbookMessage>>.broadcast();

  // Simulación de Firestore (Colección 'attendees')
  static int _attendeeCount = 0;
  static final StreamController<int> _attendeeController = StreamController<int>.broadcast();

  // Getters de Streams
  static Stream<String?> get authStateChanges => _authController.stream;
  static Stream<List<GuestbookMessage>> get guestbookMessages => _firestoreController.stream;
  static Stream<int> get attendeeCount => _attendeeController.stream;

  // Lógica de Autenticación
  static Future<void> signIn(String email) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Latencia de red
    _currentUser = email.split('@')[0]; // Usamos el nombre antes del @ como nick
    _authController.add(_currentUser);
  }

  static void signOut() {
    _currentUser = null;
    _authController.add(null);
  }

  // Lógica de Firestore (Escritura y lectura)
  static Future<void> addMessage(String message) async {
    if (_currentUser == null) return;
    
    final newMessage = GuestbookMessage(
      name: _currentUser!,
      message: message,
      timestamp: DateTime.now(),
    );
    
    _messages.insert(0, newMessage); // Insertar al inicio para el chat
    _firestoreController.add(List.from(_messages));
  }

  static Future<void> updateRSVP(AttendingStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (status == AttendingStatus.attending) {
      _attendeeCount++;
    } else if (_attendeeCount > 0) {
      _attendeeCount--;
    }
    _attendeeController.add(_attendeeCount);
  }
}

// --- APP PRINCIPAL ---

class FirebaseSimulatedApp extends StatelessWidget {
  const FirebaseSimulatedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase RSVP',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const AuthGate(),
    );
  }
}

// --- NAVEGACIÓN BASADA EN AUTH (AuthGate) ---

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: MockFirebase.authStateChanges,
      builder: (context, snapshot) {
        // Si no hay usuario, mostramos pantalla de acceso
        if (!snapshot.hasData) {
          return const LoginScreen();
        }
        // Si hay usuario, vamos a la App principal
        return const HomeScreen(userName: "Invitado");
      },
    );
  }
}

// --- PANTALLA DE LOGIN ---

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_emailController.text.isEmpty) return;
    setState(() => _isLoading = true);
    await MockFirebase.signIn(_emailController.text);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flash_on, size: 80, color: Colors.amber),
              const SizedBox(height: 20),
              const Text("Firebase RSVP", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text("Únete al evento del ITM Mérida"),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading 
                    ? const CircularProgressIndicator() 
                    : const Text("INGRESAR"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- PANTALLA PRINCIPAL (Libro de Visitas y RSVP) ---

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AttendingStatus _status = AttendingStatus.unknown;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSVP Evento Firebase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => MockFirebase.signOut(),
          )
        ],
      ),
      body: ListView(
        children: [
          // Banner de Imagen Simulado
          Image.network(
            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
            height: 200,
            fit: BoxMaterial.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: Colors.blueGrey,
              child: const Icon(Icons.event, size: 100, color: Colors.white24),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EventDetailsWidget(),
                Divider(),
                _RSVPSection(),
                Divider(),
                Text("Libro de Visitas", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                _GuestbookWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS DE COMPONENTES ---

class _EventDetailsWidget extends StatelessWidget {
  const _EventDetailsWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 8),
            Text("17 de Marzo, 2026", style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16),
            const SizedBox(width: 8),
            Text("Instituto Tecnológico de Mérida", style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<int>(
          stream: MockFirebase.attendeeCount,
          initialData: 0,
          builder: (context, snapshot) {
            return Text(
              "${snapshot.data} personas asistirán",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            );
          },
        ),
      ],
    );
  }
}

class _RSVPSection extends StatefulWidget {
  const _RSVPSection();

  @override
  State<_RSVPSection> createState() => _RSVPSectionState();
}

class _RSVPSectionState extends State<_RSVPSection> {
  AttendingStatus _myStatus = AttendingStatus.unknown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Text("¿Asistirás?"),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _myStatus == AttendingStatus.attending ? Colors.green[100] : null,
            ),
            onPressed: () {
              setState(() => _myStatus = AttendingStatus.attending);
              MockFirebase.updateRSVP(AttendingStatus.attending);
            },
            child: const Text("SÍ"),
          ),
          const SizedBox(width: 8),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: _myStatus == AttendingStatus.notAttending ? Colors.red : null,
            ),
            onPressed: () {
              setState(() => _myStatus = AttendingStatus.notAttending);
              MockFirebase.updateRSVP(AttendingStatus.notAttending);
            },
            child: const Text("NO"),
          ),
        ],
      ),
    );
  }
}

class _GuestbookWidget extends StatefulWidget {
  const _GuestbookWidget();

  @override
  State<_GuestbookWidget> createState() => _GuestbookWidgetState();
}

class _GuestbookWidgetState extends State<_GuestbookWidget> {
  final _msgController = TextEditingController();

  void _sendMessage() {
    if (_msgController.text.isNotEmpty) {
      MockFirebase.addMessage(_msgController.text);
      _msgController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgController,
                decoration: const InputDecoration(hintText: "Deja un mensaje..."),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: _sendMessage,
            ),
          ],
        ),
        const SizedBox(height: 20),
        StreamBuilder<List<GuestbookMessage>>(
          stream: MockFirebase.guestbookMessages,
          initialData: const [],
          builder: (context, snapshot) {
            final messages = snapshot.data!;
            if (messages.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No hay mensajes aún. ¡Sé el primero!", style: TextStyle(color: Colors.grey)),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final m = messages[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(m.name[0].toUpperCase())),
                  title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(m.message),
                  trailing: Text(
                    "${m.timestamp.hour}:${m.timestamp.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// Helper para el BoxFit
class BoxMaterial {
  static const cover = BoxFit.cover;
}