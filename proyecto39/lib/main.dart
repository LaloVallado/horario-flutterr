import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: PantallaPrincipal()));

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActual = 0;

  // Claves globales para controlar cada Navigator de forma independiente
  final List<GlobalKey<NavigatorState>> _navKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indiceActual,
        children: [
          _TabNavigatior(navKey: _navKeys[0], tabName: 'Sensores', color: Colors.teal),
          _TabNavigatior(navKey: _navKeys[1], tabName: 'Ajustes', color: Colors.blueGrey),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (int index) {
          if (_indiceActual == index) {
            // Si toca la pestaña actual, vuelve al inicio de esa pila
            _navKeys[index].currentState?.popUntil((route) => route.isFirst);
          } else {
            setState(() => _indiceActual = index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Sensores'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

// Widget personalizado que contiene un Navigator independiente
class _TabNavigatior extends StatelessWidget {
  final GlobalKey<NavigatorState> navKey;
  final String tabName;
  final Color color;

  const _TabNavigatior({required this.navKey, required this.tabName, required this.color});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text(tabName), backgroundColor: color),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Estás en la raíz de $tabName'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Este push ocurre DENTRO del Navigator de la pestaña
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(title: const Text('Detalle Interno')),
                            body: const Center(child: Text('Navegación Anidada')),
                          ),
                        ),
                      );
                    },
                    child: const Text('Ir más profundo'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}