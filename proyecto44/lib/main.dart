import 'package:flutter/material.dart';

// 1. EL CONTRATO (Interface)
abstract class Command {
  Future<void> execute();
}

// 2. EL COMANDO CONCRETO (Lógica encapsulada)
class UpdateConfigCommand extends Command {
  final String value;
  final Function(String) onResult;

  UpdateConfigCommand(this.value, {required this.onResult});

  @override
  Future<void> execute() async {
    // Simulamos latencia de red (comunicación con ESP32)
    await Future.delayed(const Duration(seconds: 1));
    
    if (value.isNotEmpty) {
      onResult("Configuración '$value' enviada al servidor.");
    } else {
      onResult("Error: El valor no puede estar vacío.");
    }
  }
}

// 3. EL VIEWMODEL (Gestor de estado)
class ControlViewModel extends ChangeNotifier {
  String _status = "Sistema en espera";
  bool _isLoading = false;

  String get status => _status;
  bool get isLoading => _isLoading;

  // Ejecuta cualquier comando que implemente la interfaz Command
  Future<void> runCommand(Command command) async {
    _isLoading = true;
    _status = "Procesando...";
    notifyListeners();

    await command.execute();

    _isLoading = false;
    notifyListeners();
  }

  void setStatus(String msg) {
    _status = msg;
    notifyListeners();
  }
}

// 4. LA INTERFAZ (UI)
void main() => runApp(const MaterialApp(home: PantallaControl()));

class PantallaControl extends StatefulWidget {
  const PantallaControl({super.key});

  @override
  State<PantallaControl> createState() => _PantallaControlState();
}

class _PantallaControlState extends State<PantallaControl> {
  final ControlViewModel viewModel = ControlViewModel();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Escuchamos cambios en el ViewModel para redibujar la UI
    viewModel.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Command Pattern - ITM')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              color: Colors.blueGrey[50],
              child: ListTile(
                title: const Text("Estado del Sistema"),
                subtitle: Text(viewModel.status),
                trailing: viewModel.isLoading 
                    ? const CircularProgressIndicator() 
                    : const Icon(Icons.sync),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nuevo Valor de Microclima',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: viewModel.isLoading ? null : () {
                // Creamos el comando y se lo pasamos al ViewModel
                final cmd = UpdateConfigCommand(
                  _controller.text,
                  onResult: (res) => viewModel.setStatus(res),
                );
                viewModel.runCommand(cmd);
              },
              child: const Text("EJECUTAR COMANDO"),
            ),
          ],
        ),
      ),
    );
  }
}