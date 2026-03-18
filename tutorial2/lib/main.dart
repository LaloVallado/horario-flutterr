import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const FlameSimulatedApp());
}

class FlameSimulatedApp extends StatelessWidget {
  const FlameSimulatedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flame Breakout Simulator',
      theme: ThemeData.dark(useMaterial3: true),
      home: const GameScreen(),
    );
  }
}

// --- MODELOS DEL JUEGO (Simulando Flame Components) ---

class GameObject {
  double x, y, width, height;
  GameObject(this.x, this.y, this.width, this.height);

  Rect get rect => Rect.fromLTWH(x, y, width, height);
}

class Ball extends GameObject {
  double dx, dy;
  Ball({required double x, required double y, required this.dx, required this.dy}) 
      : super(x, y, 15, 15);

  void update() {
    x += dx;
    y += dy;
  }
}

class Brick extends GameObject {
  final Color color;
  bool isDestroyed = false;
  Brick(double x, double y, double width, double height, this.color) 
      : super(x, y, width, height);
}

// --- ENGINE PRINCIPAL ---

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  // Estado del juego
  late Ticker _ticker;
  Size worldSize = Size.zero;
  
  // Componentes
  late Ball ball;
  late GameObject paddle;
  List<Brick> bricks = [];
  
  // Lógica de puntaje
  int score = 0;
  int lives = 3;
  bool isPlaying = false;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    // Inicializamos el "Game Loop" (Ticker de Flame)
    _ticker = createTicker(_onTick);
    _resetGame();
  }

  void _resetGame() {
    ball = Ball(x: 200, y: 400, dx: 3, dy: -3);
    paddle = GameObject(150, 600, 100, 20);
    _generateBricks();
    score = 0;
    lives = 3;
    gameOver = false;
  }

  void _generateBricks() {
    bricks.clear();
    const rows = 5;
    const cols = 6;
    const padding = 5.0;
    const brickHeight = 25.0;

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        bricks.add(Brick(
          0, 0, 0, 0, // Se calculan en el primer frame según el tamaño de pantalla
          [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue][i],
        ));
      }
    }
  }

  void _onTick(Duration elapsed) {
    if (!isPlaying || gameOver) return;

    setState(() {
      // 1. Mover Pelota
      ball.update();

      // 2. Colisiones con Paredes
      if (ball.x <= 0 || ball.x + ball.width >= worldSize.width) ball.dx *= -1;
      if (ball.y <= 0) ball.dy *= -1;

      // 3. Colisión con el Bate (Paddle)
      if (ball.rect.overlaps(paddle.rect)) {
        ball.dy = -ball.dy.abs(); // Rebota hacia arriba
        // Añadir efecto de ángulo según donde pegue en el bate
        double relativeHit = (ball.x + ball.width / 2) - (paddle.x + paddle.width / 2);
        ball.dx = relativeHit / 10;
      }

      // 4. Colisión con Ladrillos
      for (var brick in bricks) {
        if (!brick.isDestroyed && ball.rect.overlaps(brick.rect)) {
          brick.isDestroyed = true;
          ball.dy *= -1;
          score += 10;
          break;
        }
      }

      // 5. Caída (Perder vida)
      if (ball.y > worldSize.height) {
        lives--;
        if (lives <= 0) {
          gameOver = true;
          isPlaying = false;
        } else {
          ball.x = paddle.x + paddle.width / 2;
          ball.y = paddle.y - 30;
          ball.dy = -4;
        }
      }

      // Victoria
      if (bricks.every((b) => b.isDestroyed)) {
        gameOver = true;
        isPlaying = false;
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          worldSize = Size(constraints.maxWidth, constraints.maxHeight);
          
          // Ajustar posiciones iniciales si es la primera vez
          if (bricks.isNotEmpty && bricks[0].width == 0) {
            double bWidth = (worldSize.width - 40) / 6;
            for (int i = 0; i < bricks.length; i++) {
              int row = i ~/ 6;
              int col = i % 6;
              bricks[i].x = 20 + (col * bWidth);
              bricks[i].y = 80 + (row * 30);
              bricks[i].width = bWidth - 4;
              bricks[i].height = 20;
            }
            paddle.y = worldSize.height - 100;
            paddle.x = (worldSize.width / 2) - 50;
          }

          return GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                paddle.x += details.delta.dx;
                // Limites
                paddle.x = paddle.x.clamp(0, worldSize.width - paddle.width);
              });
            },
            child: Stack(
              children: [
                // CAPA DE DIBUJO DEL JUEGO (Flame Canvas)
                CustomPaint(
                  size: Size.infinite,
                  painter: GamePainter(
                    ball: ball,
                    paddle: paddle,
                    bricks: bricks,
                  ),
                ),

                // INTERFAZ DE USUARIO (Flutter Overlay)
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("PUNTOS: $score", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text("VIDAS: ${'❤️' * lives}", style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                ),

                if (!isPlaying && !gameOver)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("FLAME BREAKOUT", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.cyan)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _ticker.start();
                            setState(() => isPlaying = true);
                          },
                          child: const Text("INICIAR JUEGO"),
                        ),
                      ],
                    ),
                  ),

                if (gameOver)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      color: Colors.black87,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(lives > 0 ? "¡GANASTE!" : "GAME OVER", 
                            style: TextStyle(fontSize: 40, color: lives > 0 ? Colors.green : Colors.red)),
                          Text("Puntaje Final: $score", style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _resetGame();
                                isPlaying = true;
                              });
                            },
                            child: const Text("REINTENTAR"),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- PAINTER (El renderizador de componentes) ---

class GamePainter extends CustomPainter {
  final Ball ball;
  final GameObject paddle;
  final List<Brick> bricks;

  GamePainter({required this.ball, required this.paddle, required this.bricks});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Dibujar Pelota (Glow effect)
    paint.color = Colors.white;
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawOval(ball.rect, paint);
    paint.maskFilter = null;

    // Dibujar Paddle
    paint.color = Colors.cyan;
    canvas.drawRRect(
      RRect.fromRectAndRadius(paddle.rect, const Radius.circular(8)), 
      paint
    );

    // Dibujar Ladrillos
    for (var brick in bricks) {
      if (!brick.isDestroyed) {
        paint.color = brick.color;
        canvas.drawRRect(
          RRect.fromRectAndRadius(brick.rect, const Radius.circular(4)), 
          paint
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}