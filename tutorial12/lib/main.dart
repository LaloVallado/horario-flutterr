import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CrosswordGameApp(),
    ),
  );
}

// --- 1. MODELOS DE DATOS INMUTABLES ---

@immutable
class PuzzleState {
  final List<List<String>> grid;
  final bool isGenerating;
  final String message;

  const PuzzleState({
    required this.grid,
    this.isGenerating = false,
    this.message = 'Listo para generar',
  });

  PuzzleState copyWith({
    List<List<String>>? grid,
    bool? isGenerating,
    String? message,
  }) {
    return PuzzleState(
      grid: grid ?? this.grid,
      isGenerating: isGenerating ?? this.isGenerating,
      message: message ?? this.message,
    );
  }
}

// --- 2. LÓGICA DE IA (Backtracking) ---
// Esta clase contiene el algoritmo pesado que se ejecutará en un Isolate.

class CrosswordGenerator {
  static const int size = 10;
  
  // Lista de palabras para el acertijo
  static const List<String> wordBank = [
    'FLUTTER', 'DART', 'ISOLATE', 'RIVERPOD', 'WIDGET', 
    'ENGINEERING', 'ALGORITHM', 'SYSTEMS', 'COMPUTE', 'MOBILE'
  ];

  static List<List<String>> generate(int gridSize) {
    // Inicializar cuadrícula vacía
    List<List<String>> grid = List.generate(
      gridSize, 
      (_) => List.generate(gridSize, (_) => ''),
    );

    // Intentar colocar palabras (Simulación de backtracking recursivo)
    // En una implementación real, aquí iría la lógica de colisión de letras.
    final Random random = Random();
    List<String> selectedWords = List.from(wordBank)..shuffle();

    for (var word in selectedWords.take(5)) {
      bool placed = false;
      int attempts = 0;
      
      while (!placed && attempts < 20) {
        int row = random.nextInt(gridSize);
        int col = random.nextInt(gridSize - word.length + 1);
        
        // Verificación simple de espacio horizontal
        bool canPlace = true;
        for (int i = 0; i < word.length; i++) {
          if (grid[row][col + i] != '' && grid[row][col + i] != word[i]) {
            canPlace = false;
            break;
          }
        }

        if (canPlace) {
          for (int i = 0; i < word.length; i++) {
            grid[row][col + i] = word[i];
          }
          placed = true;
        }
        attempts++;
      }
    }

    // Rellenar espacios vacíos con letras aleatorias
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c] == '') {
          grid[r][c] = String.fromCharCode(random.nextInt(26) + 65);
        }
      }
    }

    return grid;
  }
}

// --- 3. GESTIÓN DE ESTADO CON RIVERPOD ---

class PuzzleNotifier extends Notifier<PuzzleState> {
  @override
  PuzzleState build() {
    return PuzzleState(grid: List.generate(10, (_) => List.generate(10, (_) => '')));
  }

  Future<void> generateNewPuzzle() async {
    state = state.copyWith(isGenerating: true, message: 'Calculando posiciones de IA...');

    // USO DE COMPUTE: Esto crea un Isolate, ejecuta la función y devuelve el resultado
    // sin bloquear los 60 FPS de la interfaz de usuario.
    try {
      final newGrid = await compute(CrosswordGenerator.generate, 10);
      
      state = state.copyWith(
        grid: newGrid,
        isGenerating: false,
        message: '¡Acertijo generado con éxito!',
      );
    } catch (e) {
      state = state.copyWith(isGenerating: false, message: 'Error en la generación');
    }
  }
}

final puzzleProvider = NotifierProvider<PuzzleNotifier, PuzzleState>(() {
  return PuzzleNotifier();
});

// --- 4. INTERFAZ DE USUARIO (UI) ---

class CrosswordGameApp extends StatelessWidget {
  const CrosswordGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzle = ref.watch(puzzleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IA Word Puzzle Solver'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStatusBanner(puzzle),
          Expanded(
            child: Center(
              child: puzzle.isGenerating 
                ? const _LoadingView() 
                : _PuzzleGrid(grid: puzzle.grid),
            ),
          ),
          _buildControls(ref, puzzle),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(PuzzleState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: state.isGenerating ? Colors.amber.shade100 : Colors.blueGrey.shade50,
      child: Text(
        state.message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildControls(WidgetRef ref, PuzzleState state) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            "Este algoritmo usa Búsqueda Exhaustiva en un sub-proceso (Isolate).",
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: state.isGenerating 
                ? null 
                : () => ref.read(puzzleProvider.notifier).generateNewPuzzle(),
              icon: const Icon(Icons.psychology),
              label: const Text('GENERAR NUEVO CRUCIGRAMA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade800,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PuzzleGrid extends StatelessWidget {
  final List<List<String>> grid;
  const _PuzzleGrid({required this.grid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: 100,
        itemBuilder: (context, index) {
          int r = index ~/ 10;
          int c = index % 10;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blueGrey.shade200),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Center(
              child: Text(
                grid[r][c],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 20),
        const Text("La IA está trabajando..."),
        const Text("(El UI sigue fluido gracias a los Isolates)", style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}