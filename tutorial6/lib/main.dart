import 'package:flutter/material.dart';

void main() {
  runApp(const ReplyApp());
}

class ReplyApp extends StatelessWidget {
  const ReplyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material Motion Reply',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const MailboxScreen(),
    );
  }
}

// --- MODELO DE DATOS ---
class Email {
  final String sender;
  final String time;
  final String title;
  final String body;
  Email(this.sender, this.time, this.title, this.body);
}

final List<Email> emails = [
  Email("Google Express", "15 min", "Paquete en camino", "Tu pedido de Flutter Merch está cerca..."),
  Email("Ali Connors", "1 hr", "Cena el viernes", "Hola, ¿podemos ir al restaurante de Mérida?"),
  Email("Sandra Adams", "4 hrs", "Actualización de proyecto", "El sistema de colisiones en Flame quedó listo."),
];

// --- 1. PATRÓN: TRANSFORMACIÓN DE CONTENEDOR (Manual) ---
// Simula el widget OpenContainer expandiendo un elemento.
class ContainerTransformRoute extends PageRouteBuilder {
  final Widget page;
  ContainerTransformRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
                ),
                child: child,
              ),
            );
          },
        );
}

// --- PANTALLA PRINCIPAL: BUZÓN ---
class MailboxScreen extends StatefulWidget {
  const MailboxScreen({super.key});

  @override
  State<MailboxScreen> createState() => _MailboxScreenState();
}

class _MailboxScreenState extends State<MailboxScreen> {
  int _currentIndex = 0;
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
          ? const TextField(decoration: InputDecoration(hintText: "Buscar correos..."))
          : const Text("Recibidos"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () => setState(() => _isSearching = !_isSearching),
          ),
        ],
      ),
      body: _buildFadeThroughBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inbox), label: "Buzón"),
          NavigationDestination(icon: Icon(Icons.send), label: "Enviados"),
          NavigationDestination(icon: Icon(Icons.favorite), label: "Favoritos"),
        ],
      ),
      floatingActionButton: _buildFadeScaleFAB(),
    );
  }

  // --- 2. PATRÓN: FADE THROUGH (Entre carpetas) ---
  Widget _buildFadeThroughBody() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: ListView.builder(
        key: ValueKey(_currentIndex), // Forzar reconstrucción para la animación
        itemCount: emails.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => _EmailCard(email: emails[index]),
      ),
    );
  }

  // --- 3. PATRÓN: FADE SCALE (FAB) ---
  Widget _buildFadeScaleFAB() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: FloatingActionButton(
        key: ValueKey(_currentIndex),
        onPressed: () {},
        child: Icon(_currentIndex == 0 ? Icons.edit : Icons.share),
      ),
    );
  }
}

// --- TARJETA DE EMAIL (El disparador de la transformación) ---
class _EmailCard extends StatelessWidget {
  final Email email;
  const _EmailCard({required this.email});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        ContainerTransformRoute(page: DetailScreen(email: email)),
      ),
      child: Hero( // Hero simula la conexión visual de la transformación
        tag: email.title,
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(email.sender, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(email.time, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(email.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(email.body, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- PANTALLA DE DETALLE ---
class DetailScreen extends StatelessWidget {
  final Email email;
  const DetailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Hero(
        tag: email.title,
        child: Material(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email.sender, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Divider(),
                const SizedBox(height: 16),
                Text(email.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                const SizedBox(height: 20),
                Text(email.body, style: const TextStyle(fontSize: 18)),
                const Spacer(),
                const Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: null, child: Text("Responder"))),
                    SizedBox(width: 10),
                    Expanded(child: ElevatedButton(onPressed: null, child: Text("Archivar"))),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}