import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MaterialApp(home: PantallaEliminar()));

class PantallaEliminar extends StatefulWidget {
  const PantallaEliminar({super.key});

  @override
  State<PantallaEliminar> createState() => _PantallaEliminarState();
}

class _PantallaEliminarState extends State<PantallaEliminar> {
  String _status = "Listo para eliminar el Nodo #1";
  bool _cargando = false;

  // --- FUNCIÓN PARA BORRAR DATOS ---
  Future<void> _borrarRecurso(int id) async {
    setState(() => _cargando = true);

    // La URL incluye el ID del recurso que queremos borrar
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts/$id');

    try {
      final respuesta = await http.delete(url);

      if (respuesta.statusCode == 200) {
        // Código 200 o 204 significa éxito en la eliminación
        setState(() => _status = "¡Nodo #$id eliminado con éxito del servidor!");
      } else {
        setState(() => _status = "Error al eliminar: ${respuesta.statusCode}");
      }
    } catch (e) {
      setState(() => _status = "Error de red: $e");
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HTTP DELETE - ITM')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delete_forever, size: 80, color: Colors.redAccent),
              const SizedBox(height: 20),
              Text(_status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 30),
              _cargando 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () => _borrarRecurso(1),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]),
                    child: const Text("ELIMINAR NODO #1", style: TextStyle(color: Colors.red)),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}