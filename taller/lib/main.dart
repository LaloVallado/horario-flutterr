import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

// ============================================================================
// PUNTO DE ENTRADA Y CONFIGURACIÓN PRINCIPAL
// ============================================================================
void main() {
  runApp(const SystemAppCore());
}

class SystemAppCore extends StatelessWidget {
  const SystemAppCore({super.key});

  @override
  Widget build(BuildContext context) {
    // Envolvemos toda la app en nuestro Gestor de Estado Global
    return EngineStateProvider(
      child: Builder(
        builder: (context) {
          final state = EngineStateProvider.of(context);
          return MaterialApp(
            title: 'Sistema Argos - 8vo Semestre',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(state.primaryColor, false),
            darkTheme: _buildTheme(state.primaryColor, true),
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const RootNavigationLayer(),
          );
        }
      ),
    );
  }

  // Corrección del error de CardTheme eliminando const conflictivos
  ThemeData _buildTheme(Color primary, bool isDark) {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primary,
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 8 : 4,
        margin: const EdgeInsets.all(8),
        // Aquí estaba el error en tu código anterior. Sin 'const' funciona perfecto.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
      ),
    );
  }
}

// ============================================================================
// GESTOR DE ESTADO GLOBAL (Sin Provider, usando Flutter Nativo)
// ============================================================================
class EngineStateProvider extends StatefulWidget {
  final Widget child;
  const EngineStateProvider({super.key, required this.child});

  static EngineState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedEngineState>()!.state;
  }

  @override
  State<EngineStateProvider> createState() => EngineState();
}

class EngineState extends State<EngineStateProvider> {
  // --- Variables de Estado ---
  bool isDarkMode = true;
  Color primaryColor = Colors.cyanAccent;
  
  final List<String> systemLogs = [
    "[SYS] Núcleo inicializado correctamente.",
    "[NET] Conectando con servidor principal...",
    "[NET] Handshake establecido. Latencia: 12ms",
    "[ARGOS] Subsistema de rastreo ESP32 en espera."
  ];

  final List<TelemetryNode> connectedNodes = [
    TelemetryNode(id: "ESP32_Mérida_Poniente", type: "Sensor Clima", battery: 85, isOnline: true),
    TelemetryNode(id: "ESP32_Cozumel_Lab", type: "Sensor Humedad", battery: 42, isOnline: true),
    TelemetryNode(id: "Argos_Tracker_01", type: "Geolocalización", battery: 12, isOnline: false),
    TelemetryNode(id: "SmartQueue_Terminal", type: "Control Acceso", battery: 100, isOnline: true),
  ];

  final List<DataRowModel> databaseSim = List.generate(
    50, (index) => DataRowModel(
      id: 1000 + index,
      timestamp: DateTime.now().subtract(Duration(minutes: index * 15)),
      value: (20.0 + math.Random().nextDouble() * 15).toStringAsFixed(2),
      status: math.Random().nextDouble() > 0.1 ? "OK" : "WARN",
    )
  );

  // --- Métodos Mutadores ---
  void toggleTheme() => setState(() => isDarkMode = !isDarkMode);
  
  void setPrimaryColor(Color color) {
    setState(() {
      primaryColor = color;
      addLog("[UI] Esquema de color actualizado.");
    });
  }

  void addLog(String message) {
    setState(() {
      final time = DateTime.now().toString().substring(11, 19);
      systemLogs.insert(0, "[$time] $message");
      if (systemLogs.length > 200) systemLogs.removeLast(); // Prevenir desbordamiento de memoria
    });
  }

  void executeCommand(String cmd) {
    final command = cmd.trim().toLowerCase();
    addLog("> $command");
    
    if (command == "clear") {
      setState(() => systemLogs.clear());
      addLog("[SYS] Consola limpiada.");
    } else if (command == "ping") {
      addLog("[NET] Pong! Latencia local: 0ms");
    } else if (command.startsWith("reboot")) {
      addLog("[WARN] Reiniciando subsistemas...");
      Timer(const Duration(seconds: 2), () => addLog("[SYS] Reinicio completado."));
    } else {
      addLog("[ERR] Comando '$command' no reconocido. Intente 'ping', 'clear' o 'reboot'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedEngineState(
      state: this,
      child: widget.child,
    );
  }
}

class _InheritedEngineState extends InheritedWidget {
  final EngineState state;
  const _InheritedEngineState({required this.state, required super.child});

  @override
  bool updateShouldNotify(covariant _InheritedEngineState oldWidget) => true;
}

// ============================================================================
// MODELOS DE DATOS
// ============================================================================
class TelemetryNode {
  final String id;
  final String type;
  final int battery;
  final bool isOnline;
  TelemetryNode({required this.id, required this.type, required this.battery, required this.isOnline});
}

class DataRowModel {
  final int id;
  final DateTime timestamp;
  final String value;
  final String status;
  DataRowModel({required this.id, required this.timestamp, required this.value, required this.status});
}

// ============================================================================
// CAPA DE NAVEGACIÓN Y ENRUTAMIENTO (Responsive)
// ============================================================================
class RootNavigationLayer extends StatefulWidget {
  const RootNavigationLayer({super.key});

  @override
  State<RootNavigationLayer> createState() => _RootNavigationLayerState();
}

class _RootNavigationLayerState extends State<RootNavigationLayer> {
  int _currentIndex = 0;

  final List<Widget> _views = const [
    DashboardView(),
    NodesManagerView(),
    DatabaseView(),
    TerminalView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 850;
    final state = EngineStateProvider.of(context);

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
              extended: MediaQuery.of(context).size.width >= 1100,
              elevation: 4,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    Icon(Icons.memory, size: 40, color: state.primaryColor),
                    const SizedBox(height: 8),
                    const Text("CORE V2", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Métricas')),
                NavigationRailDestination(icon: Icon(Icons.hub), label: Text('Nodos ESP32')),
                NavigationRailDestination(icon: Icon(Icons.table_chart), label: Text('Registros')),
                NavigationRailDestination(icon: Icon(Icons.terminal), label: Text('Terminal CLI')),
                NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Sistema')),
              ],
            ),
          if (isDesktop) const VerticalDivider(thickness: 1, width: 1),
          
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _views[_currentIndex],
            ),
          ),
        ],
      ),
      // Navegación inferior para dispositivos móviles
      bottomNavigationBar: !isDesktop ? NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Métricas'),
          NavigationDestination(icon: Icon(Icons.hub), label: 'Nodos'),
          NavigationDestination(icon: Icon(Icons.table_chart), label: 'Datos'),
          NavigationDestination(icon: Icon(Icons.terminal), label: 'CLI'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ) : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          state.addLog("[SYS] Ejecutando rutina de diagnóstico de red...");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Diagnóstico iniciado. Revise la terminal.'))
          );
        },
        child: const Icon(Icons.network_check),
      ),
    );
  }
}

// ============================================================================
// VISTA 1: DASHBOARD (Métricas en Tiempo Real y Canvas Avanzado)
// ============================================================================
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Telemetría Central", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Chip(
              label: const Text("SISTEMA ESTABLE", style: TextStyle(fontSize: 12)),
              backgroundColor: Colors.green.withOpacity(0.2),
              side: const BorderSide(color: Colors.green),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel de Tarjetas Superiores
            GridView.count(
              crossAxisCount: isDesktop ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isDesktop ? 1.5 : 1.2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildStatCard(context, "Carga CPU", "34%", Icons.memory, Colors.purpleAccent),
                _buildStatCard(context, "Temp. Servidor", "42°C", Icons.thermostat, Colors.orangeAccent),
                _buildStatCard(context, "Ancho de Banda", "1.2 GB/s", Icons.router, Colors.blueAccent),
                _buildStatCard(context, "Nodos Activos", "3/4", Icons.hub, Colors.greenAccent),
              ],
            ),
            const SizedBox(height: 24),
            
            // Sección de Gráficos Generados con CustomPaint (Ingeniería Pura)
            Text("Análisis de Frecuencia (Tiempo Real)", style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                child: LiveOscilloscope(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext ctx, String title, String val, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const Spacer(),
                Icon(Icons.show_chart, color: Colors.grey.withOpacity(0.5)),
              ],
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text(val, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// --- Animación de Gráfico con Matemáticas ---
class LiveOscilloscope extends StatefulWidget {
  const LiveOscilloscope({super.key});
  @override
  State<LiveOscilloscope> createState() => _LiveOscilloscopeState();
}

class _LiveOscilloscopeState extends State<LiveOscilloscope> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Corriendo a 60 FPS continuos
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = EngineStateProvider.of(context).primaryColor;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SineWavePainter(progress: _controller.value, waveColor: primaryColor),
        );
      },
    );
  }
}

class SineWavePainter extends CustomPainter {
  final double progress;
  final Color waveColor;
  SineWavePainter({required this.progress, required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
      
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    // Dibujar cuadrícula técnica
    for(double i = 0; i < size.width; i += 40) canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    for(double i = 0; i < size.height; i += 40) canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);

    // Dibujar onda matemática (Seno)
    final path = Path();
    for (double x = 0; x < size.width; x++) {
      // Cálculo de onda: y = A * sin(B * x + C) + D
      double y = 40 * math.sin((x / 30) + (progress * 2 * math.pi)) + (size.height / 2);
      
      // Añadir algo de ruido para simular datos reales
      y += math.Random().nextDouble() * 5 - 2.5;

      if (x == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SineWavePainter oldDelegate) => oldDelegate.progress != progress;
}

// ============================================================================
// VISTA 2: GESTOR DE NODOS (Hardware Conectado)
// ============================================================================
class NodesManagerView extends StatelessWidget {
  const NodesManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    final nodes = EngineStateProvider.of(context).connectedNodes;

    return Scaffold(
      appBar: AppBar(title: const Text("Red de Dispositivos")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: nodes.length,
        itemBuilder: (context, index) {
          final node = nodes[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: node.battery / 100,
                    color: node.battery > 20 ? Colors.green : Colors.red,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                  ),
                  Icon(Icons.memory, size: 20, color: node.isOnline ? Colors.white : Colors.grey),
                ],
              ),
              title: Text(node.id, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Función: ${node.type} • Batería: ${node.battery}%"),
              trailing: Chip(
                label: Text(node.isOnline ? "ONLINE" : "OFFLINE"),
                backgroundColor: node.isOnline ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                side: BorderSide(color: node.isOnline ? Colors.green : Colors.red),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// VISTA 3: BASE DE DATOS (Registros Tabulares)
// ============================================================================
class DatabaseView extends StatefulWidget {
  const DatabaseView({super.key});

  @override
  State<DatabaseView> createState() => _DatabaseViewState();
}

class _DatabaseViewState extends State<DatabaseView> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {
    final data = EngineStateProvider.of(context).databaseSim;
    final dataSource = TelemetryDataSource(data, context);

    return Scaffold(
      appBar: AppBar(title: const Text("Base de Datos Local")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: PaginatedDataTable(
          header: const Text("Historial de Lecturas"),
          rowsPerPage: _rowsPerPage,
          onRowsPerPageChanged: (val) => setState(() => _rowsPerPage = val ?? 10),
          columns: const [
            DataColumn(label: Text("ID")),
            DataColumn(label: Text("Timestamp")),
            DataColumn(label: Text("Valor Bruto")),
            DataColumn(label: Text("Estado")),
          ],
          source: dataSource,
        ),
      ),
    );
  }
}

class TelemetryDataSource extends DataTableSource {
  final List<DataRowModel> data;
  final BuildContext context;
  TelemetryDataSource(this.data, this.context);

  @override
  DataRow getRow(int index) {
    final row = data[index];
    final color = row.status == "OK" ? Colors.greenAccent : Colors.orangeAccent;
    return DataRow(cells: [
      DataCell(Text("#${row.id}")),
      DataCell(Text(row.timestamp.toString().substring(0, 19))),
      DataCell(Text(row.value, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(row.status, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}

// ============================================================================
// VISTA 4: TERMINAL DE COMANDOS (CLI Interactivo)
// ============================================================================
class TerminalView extends StatefulWidget {
  const TerminalView({super.key});

  @override
  State<TerminalView> createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> {
  final TextEditingController _cmdController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _submitCommand() {
    if (_cmdController.text.isEmpty) return;
    EngineStateProvider.of(context).executeCommand(_cmdController.text);
    _cmdController.clear();
    // Auto-scroll al fondo
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = EngineStateProvider.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shell Integrado"),
        backgroundColor: Colors.black,
        foregroundColor: state.primaryColor,
      ),
      backgroundColor: Colors.black, // Estilo Hacker
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true, // Para que el log más nuevo salga abajo
              padding: const EdgeInsets.all(16),
              itemCount: state.systemLogs.length,
              itemBuilder: (context, index) {
                final log = state.systemLogs[index];
                Color logColor = Colors.white70;
                if (log.startsWith("[ERR]")) logColor = Colors.redAccent;
                if (log.startsWith("[WARN]")) logColor = Colors.yellowAccent;
                if (log.startsWith("[SYS]")) logColor = state.primaryColor;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    log,
                    style: TextStyle(fontFamily: 'monospace', color: logColor, fontSize: 14),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            child: Row(
              children: [
                Text("sys@argos:~ \$ ", style: TextStyle(color: state.primaryColor, fontFamily: 'monospace')),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _cmdController,
                    onSubmitted: (_) => _submitCommand(),
                    style: const TextStyle(fontFamily: 'monospace'),
                    decoration: const InputDecoration(
                      hintText: "Escriba un comando (ej. 'ping', 'clear')",
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: state.primaryColor),
                  onPressed: _submitCommand,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// VISTA 5: CONFIGURACIÓN DEL SISTEMA
// ============================================================================
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = EngineStateProvider.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Preferencias de Sistema")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text("Perfil de Ingeniero", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: state.primaryColor.withOpacity(0.2),
                child: Icon(Icons.person, color: state.primaryColor),
              ),
              title: const Text("Administrador ITM"),
              subtitle: const Text("8vo Semestre • Ingeniería en Sistemas"),
              trailing: const Icon(Icons.verified, color: Colors.blue),
            ),
          ),
          
          const SizedBox(height: 32),
          const Text("Interfaz de Usuario (UX/UI)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text("Tema Oscuro / Claro"),
            subtitle: const Text("Ajuste visual para ergonomía"),
            value: state.isDarkMode,
            onChanged: (val) => state.toggleTheme(),
            secondary: Icon(state.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          ),
          
          const SizedBox(height: 24),
          const Text("Esquema de Color Primario"),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            children: [
              _colorButton(context, Colors.cyanAccent),
              _colorButton(context, Colors.greenAccent),
              _colorButton(context, Colors.orangeAccent),
              _colorButton(context, Colors.purpleAccent),
            ],
          ),

          const SizedBox(height: 32),
          const Text("Opciones de Desarrollo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          
          ListTile(
            title: const Text("Versión del Kernel"),
            subtitle: const Text("Argos v2.4.1 (Stable Build)"),
            leading: const Icon(Icons.info_outline),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _colorButton(BuildContext context, Color color) {
    final state = EngineStateProvider.of(context);
    final isSelected = state.primaryColor == color;
    return InkWell(
      onTap: () => state.setPrimaryColor(color),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 3),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)] : null,
        ),
      ),
    );
  }
}