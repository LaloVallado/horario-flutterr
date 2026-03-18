import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const AnimationQuizApp());
}

/// Aplicación principal: juego de preguntas con muchas animaciones.
/// - Animaciones implícitas y explícitas
/// - Flip 3D de tarjeta para respuesta
/// - AnimatedSwitcher, AnimatedContainer, AnimatedOpacity, AnimatedScale
/// - Control por AnimationController y curvas personalizadas
/// - Rutas con transiciones y gesto de "arrastrar para volver" simulado
class AnimationQuizApp extends StatelessWidget {
  const AnimationQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animaciones en Flutter - Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const SplashScreen(),
    );
  }
}

/// Pantalla inicial con logo animado y transición a Home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctr;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctr = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _scale = CurvedAnimation(parent: _ctr, curve: Curves.elasticOut);
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctr, curve: const Interval(0.0, 0.6)));
    _rotation = Tween<double>(begin: -0.6, end: 0.0).animate(CurvedAnimation(parent: _ctr, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)));
    _ctr.forward();
    // navegacion tras atraso
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(pageBuilder: (_, __, ___) => const HomePage(), transitionsBuilder: _fadeTransition));
      }
    });
  }

  Widget _fadeTransition(_, Animation<double> anim, __, Widget child) {
    return FadeTransition(opacity: anim, child: child);
  }

  @override
  void dispose() {
    _ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seed = Colors.deepPurple;
    return Scaffold(
      backgroundColor: seed.shade50,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctr,
          builder: (context, child) {
            return Opacity(
              opacity: _fade.value,
              child: Transform.rotate(
                angle: _rotation.value,
                child: Transform.scale(scale: 0.8 + 0.4 * _scale.value, child: child),
              ),
            );
          },
          child: _SplashLogo(),
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [cs.primaryContainer, cs.primary]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: const Icon(Icons.question_answer, color: Colors.white, size: 44),
        ),
        const SizedBox(width: 14),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('AnimQuiz', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text('Codelab de animaciones', style: TextStyle(fontSize: 12)),
          ],
        )
      ],
    );
  }
}

/// Página principal con opciones: jugar, demos de animaciones y ajustes.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openAnimatedDemos(BuildContext c) {
    Navigator.push(c, _createRoute(const AnimDemosPage()));
  }

  void _openQuiz(BuildContext c) {
    Navigator.push(c, _createRoute(const QuizLauncher()));
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (_, anim, __) => FadeTransition(opacity: anim, child: page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Animaciones en Flutter'), centerTitle: true, elevation: 2),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Bienvenido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Este codelab demuestra varias técnicas de animación en Flutter. Explora la demo o inicia el quiz.', style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 12),
                Wrap(spacing: 10, children: [
                  ElevatedButton.icon(onPressed: () => _openQuiz(context), icon: const Icon(Icons.play_arrow), label: const Text('Iniciar Quiz')),
                  OutlinedButton.icon(onPressed: () => _openAnimatedDemos(context), icon: const Icon(Icons.animation), label: const Text('Demos')),
                ])
              ]),
            ),
          ),
          const SizedBox(height: 12),
          const _FeatureList(),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(12), child: _AboutBox())),
        ],
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(leading: const Icon(Icons.play_circle), title: const Text('Animaciones implícitas'), subtitle: const Text('AnimatedContainer, AnimatedOpacity, etc.')),
      ListTile(leading: const Icon(Icons.build), title: const Text('Animaciones explícitas'), subtitle: const Text('AnimationController, Tween, CurvedAnimation')),
      ListTile(leading: const Icon(Icons.flip), title: const Text('Flip 3D de tarjeta'), subtitle: const Text('Transform con Matrix4')),
      ListTile(leading: const Icon(Icons.list), title: const Text('AnimatedSwitcher & transiciones'), subtitle: const Text('Cambio suave de widgets')),
    ]);
  }
}

class _AboutBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Sobre este codelab', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Aprende a combinar animaciones implícitas y explícitas creando un quiz interactivo.'),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: const [
        Chip(label: Text('Implicit')),
        Chip(label: Text('Explicit')),
        Chip(label: Text('3D')),
        Chip(label: Text('Transitions')),
      ]),
    ]);
  }
}

/// Página con varios demos de animación (interactivos).
class AnimDemosPage extends StatelessWidget {
  const AnimDemosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demos de animación'), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(12), children: const [
        Padding(padding: EdgeInsets.symmetric(vertical: 8), child: _ImplicitDemo()),
        Padding(padding: EdgeInsets.symmetric(vertical: 8), child: _ExplicitMotionDemo()),
        Padding(padding: EdgeInsets.symmetric(vertical: 8), child: _FlipCardDemo()),
        Padding(padding: EdgeInsets.symmetric(vertical: 8), child: _SwitcherDemo()),
      ]),
    );
  }
}

/// Demo de animaciones implícitas combinadas.
class _ImplicitDemo extends StatefulWidget {
  const _ImplicitDemo();

  @override
  State<_ImplicitDemo> createState() => _ImplicitDemoState();
}

class _ImplicitDemoState extends State<_ImplicitDemo> {
  bool _big = false;
  bool _visible = true;
  Color _color = Colors.teal;
  double _radius = 12;

  void _toggle() {
    setState(() {
      _big = !_big;
      _visible = !_visible;
      _color = Color.lerp(_color, Colors.deepOrange, 0.5) ?? _color;
      _radius = _radius == 12 ? 40 : 12;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = _big ? 220.0 : 140.0;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Animaciones implícitas', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOutCubic,
                width: size,
                height: size,
                decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(_radius)),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _visible ? 1 : 0.3,
                  child: Center(child: Icon(_big ? Icons.star : Icons.auto_awesome, size: _big ? 64 : 42, color: Colors.white)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text('Tap para alternar tamaño, color y opacidad')),
        ]),
      ),
    );
  }
}

/// Demo explícito: movimiento y curva personalizada con AnimationController.
class _ExplicitMotionDemo extends StatefulWidget {
  const _ExplicitMotionDemo();

  @override
  State<_ExplicitMotionDemo> createState() => _ExplicitMotionDemoState();
}

class _ExplicitMotionDemoState extends State<_ExplicitMotionDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _offset;
  late final Animation<double> _scale;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _offset = Tween<Offset>(begin: const Offset(-0.6, 0), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _rotate = Tween<double>(begin: -0.08, end: 0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _replay() {
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Animación explícita', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              return Transform.translate(
                offset: _offset.value * MediaQuery.of(context).size.width * 0.4,
                child: Transform.rotate(angle: _rotate.value, child: Transform.scale(scale: _scale.value, child: child)),
              );
            },
            child: Container(
              height: 120,
              decoration: BoxDecoration(color: Colors.indigo.shade400, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('Movimiento controlado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            ElevatedButton(onPressed: _replay, child: const Text('Reproducir')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () => _ctrl.stop(), child: const Text('Pausar')),
          ]),
        ]),
      ),
    );
  }
}

/// Demo: tarjeta que gira en 3D con AnimationController.
class _FlipCardDemo extends StatefulWidget {
  const _FlipCardDemo();

  @override
  State<_FlipCardDemo> createState() => _FlipCardDemoState();
}

class _FlipCardDemoState extends State<_FlipCardDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _ctr;
  bool _front = true;

  @override
  void initState() {
    super.initState();
    _ctr = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void dispose() {
    _ctr.dispose();
    super.dispose();
  }

  void _flip() {
    if (_front) {
      _ctr.forward();
    } else {
      _ctr.reverse();
    }
    setState(() => _front = !_front);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Flip 3D', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _flip,
            child: SizedBox(
              width: double.infinity,
              height: 180,
              child: AnimatedBuilder(
                animation: _ctr,
                builder: (context, child) {
                  // rotY de 0 a pi
                  final angle = _ctr.value * pi;
                  // para que la cara trasera no se renderice invertida, ajustamos la rotacion y la opacidad
                  final isUnder = angle > pi / 2;
                  final displayAngle = isUnder ? angle - pi : angle;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0015)
                      ..rotateY(displayAngle),
                    child: isUnder ? _buildBack() : _buildFront(),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text('Tap para girar la tarjeta')),
        ]),
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      decoration: BoxDecoration(color: Colors.orange.shade400, borderRadius: BorderRadius.circular(12)),
      child: const Center(child: Text('Frente', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700))),
    );
  }

  Widget _buildBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: Container(
        decoration: BoxDecoration(color: Colors.blueGrey.shade700, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text('Reverso', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700))),
      ),
    );
  }
}

/// Demo de AnimatedSwitcher con transiciones personalizadas.
class _SwitcherDemo extends StatefulWidget {
  const _SwitcherDemo();

  @override
  State<_SwitcherDemo> createState() => _SwitcherDemoState();
}

class _SwitcherDemoState extends State<_SwitcherDemo> {
  int _count = 0;

  void _next() => setState(() => _count++);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('AnimatedSwitcher', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, anim) {
                final rotate = Tween(begin: -0.5, end: 0.0).animate(anim);
                return RotationTransition(turns: rotate, child: FadeTransition(opacity: anim, child: child));
              },
              child: Container(
                key: ValueKey<int>(_count),
                width: 160,
                height: 120,
                decoration: BoxDecoration(color: Colors.primaries[_count % Colors.primaries.length].shade300, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text('Tarjeta $_count', style: const TextStyle(fontWeight: FontWeight.w700))),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: ElevatedButton(onPressed: _next, child: const Text('Siguiente'))),
        ]),
      ),
    );
  }
}

/// Lanzador del quiz para configurar niveles y empezar.
class QuizLauncher extends StatefulWidget {
  const QuizLauncher({super.key});

  @override
  State<QuizLauncher> createState() => _QuizLauncherState();
}

class _QuizLauncherState extends State<QuizLauncher> {
  int _questions = 5;
  String _theme = 'General';
  bool _timer = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          ListTile(title: const Text('Preguntas'), trailing: Text('$_questions')),
          Slider(value: _questions.toDouble(), min: 3, max: 12, divisions: 9, label: '$_questions', onChanged: (v) => setState(() => _questions = v.round())),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _theme,
            items: const [DropdownMenuItem(value: 'General', child: Text('General')), DropdownMenuItem(value: 'Ciencia', child: Text('Ciencia')), DropdownMenuItem(value: 'Arte', child: Text('Arte'))],
            onChanged: (v) => setState(() => _theme = v ?? 'General'),
            decoration: const InputDecoration(labelText: 'Tema'),
          ),
          SwitchListTile(title: const Text('Temporizador por pregunta'), value: _timer, onChanged: (v) => setState(() => _timer = v)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(context, _quizRoute(QuizScreenConfig(count: _questions, theme: _theme, timed: _timer)));
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Empezar'),
          )
        ]),
      ),
    );
  }

  Route _quizRoute(QuizScreenConfig cfg) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => QuizScreen(config: cfg),
      transitionsBuilder: (_, anim, __, child) {
        final offset = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
        return SlideTransition(position: offset, child: FadeTransition(opacity: anim, child: child));
      },
    );
  }
}

/// Configuración para la pantalla de quiz.
class QuizScreenConfig {
  final int count;
  final String theme;
  final bool timed;
  const QuizScreenConfig({required this.count, required this.theme, required this.timed});
}

/// Modelo de pregunta simple.
class Question {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  Question({required this.prompt, required this.options, required this.correctIndex, required this.explanation});
}

/// Pantalla principal del quiz con animaciones por cada pregunta.
class QuizScreen extends StatefulWidget {
  final QuizScreenConfig config;
  const QuizScreen({super.key, required this.config});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late final List<Question> _questions;
  int _index = 0;
  int _score = 0;
  bool _showResult = false;
  bool _answered = false;
  int? _selected;
  late final AnimationController _progressCtr;
  Timer? _qTimer;
  int _timeLeft = 0;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions(widget.config.count, widget.config.theme);
    _progressCtr = AnimationController(vsync: this, duration: Duration(seconds: max(6, widget.config.timed ? 8 : 1)));
    if (widget.config.timed) _startTimer();
  }

  @override
  void dispose() {
    _progressCtr.dispose();
    _qTimer?.cancel();
    super.dispose();
  }

  List<Question> _generateQuestions(int count, String theme) {
    // Generador básico y reproducible de preguntas
    final rng = Random(42 + theme.hashCode);
    final List<Question> list = [];
    for (var i = 0; i < count; i++) {
      final a = '¿Cuál es el resultado de ${i + 2} + ${rng.nextInt(8) + 1}?';
      final correct = (i + 2) + (rng.nextInt(8) + 1);
      final options = List<int>.generate(4, (j) => correct + (j - 1)).toList();
      options.shuffle(rng);
      final correctIndex = options.indexOf(correct);
      list.add(Question(
        prompt: a,
        options: options.map((e) => e.toString()).toList(),
        correctIndex: correctIndex,
        explanation: 'Porque ${(correct - 1)} + 1 = $correct',
      ));
    }
    return list;
  }

  void _startTimer() {
    _timeLeft = 8;
    _progressCtr.duration = Duration(seconds: _timeLeft);
    _progressCtr.forward(from: 0);
    _qTimer?.cancel();
    _qTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          t.cancel();
          _onTimeout();
        }
      });
    });
  }

  void _onTimeout() {
    // tratar como incorrecta
    setState(() {
      _answered = true;
      _selected = null;
    });
    Future.delayed(const Duration(milliseconds: 700), () => _nextQuestion());
  }

  void _select(int idx) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selected = idx;
      if (idx == _questions[_index].correctIndex) _score++;
    });
    // animar feedback y luego avanzar
    Future.delayed(const Duration(milliseconds: 1000), () => _nextQuestion());
  }

  void _nextQuestion() {
    _qTimer?.cancel();
    _progressCtr.stop();
    if (_index + 1 >= _questions.length) {
      setState(() {
        _showResult = true;
      });
      return;
    }
    setState(() {
      _index++;
      _answered = false;
      _selected = null;
    });
    if (widget.config.timed) _startTimer();
  }

  void _restart() {
    setState(() {
      _questions.clear();
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const QuizLauncher()));
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressCtr,
      builder: (context, child) {
        final pct = widget.config.timed ? _progressCtr.value : (_index / max(1, _questions.length));
        return LinearProgressIndicator(value: pct, minHeight: 8, color: pct > 0.6 ? Colors.green : Colors.orange);
      },
    );
  }

  Widget _buildQuestionCard(Question q) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Pregunta ${_index + 1} / ${_questions.length}', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(q.prompt, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Column(
          children: List.generate(q.options.length, (i) {
            final correct = i == q.correctIndex;
            final selected = _selected == i;
            Color? color;
            if (_answered) {
              if (selected) color = correct ? Colors.green.shade400 : Colors.red.shade400;
              if (correct && !selected) color = Colors.green.shade200;
            }
            return AnimatedOptionTile(
              key: ValueKey('q_${_index}_opt_$i'),
              text: q.options[i],
              highlightColor: color,
              onTap: () => _select(i),
              disabled: _answered,
            );
          }),
        ),
        const SizedBox(height: 10),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Explicación: ${q.explanation}', style: TextStyle(color: Colors.grey.shade700)),
          ),
          crossFadeState: _answered ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 400),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resultados')),
        body: Center(
          child: ScoreSummary(score: _score, total: _questions.length, onRestart: _restart),
        ),
      );
    }
    final q = _questions[_index];
    return WillPopScope(
      onWillPop: () async {
        // confirmar salida
        final res = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Salir'), content: const Text('¿Deseas abandonar el quiz?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sí'))]));
        return res ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Animado'),
          actions: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Center(child: Text('P: ${_index + 1}/${_questions.length} • S: $_score'))),
          ],
        ),
        body: Column(children: [
          Padding(padding: const EdgeInsets.all(8), child: _buildProgressBar()),
          Expanded(
            child: Stack(children: [
              // AnimatedSwitcher para transición entre preguntas
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, anim) {
                  final inAnim = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(anim);
                  return SlideTransition(position: inAnim, child: FadeTransition(opacity: anim, child: child));
                },
                child: Card(
                  key: ValueKey<int>(_index),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: _buildQuestionCard(q),
                ),
              ),
              // temporizador visual circular
              if (widget.config.timed)
                Positioned(right: 18, top: 18, child: CircularTimer(timeLeft: _timeLeft, total: _progressCtr.duration?.inSeconds ?? 8)),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Tile de opción con animaciones de escala y color.
class AnimatedOptionTile extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool disabled;
  final Color? highlightColor;
  const AnimatedOptionTile({super.key, required this.text, required this.onTap, this.disabled = false, this.highlightColor});

  @override
  State<AnimatedOptionTile> createState() => _AnimatedOptionTileState();
}

class _AnimatedOptionTileState extends State<AnimatedOptionTile> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool _pressed = false;
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.disabled) return;
    _anim.forward();
    setState(() {
      _scale = 0.97;
      _pressed = true;
    });
  }

  void _onTapUp(_) {
    if (widget.disabled) return;
    _anim.reverse();
    setState(() {
      _scale = 1.0;
      _pressed = false;
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.highlightColor ?? (Theme.of(context).colorScheme.surfaceVariant);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: () {
          _anim.reverse();
          setState(() {
            _scale = 1.0;
            _pressed = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(_scale, _scale),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
          child: ListTile(
            title: Text(widget.text),
            trailing: widget.disabled ? const Icon(Icons.lock_clock) : null,
          ),
        ),
      ),
    );
  }
}

/// Temporizador circular simple.
class CircularTimer extends StatelessWidget {
  final int timeLeft;
  final int total;
  const CircularTimer({super.key, required this.timeLeft, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (timeLeft / total).clamp(0.0, 1.0) : 0.0;
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(alignment: Alignment.center, children: [
        CircularProgressIndicator(value: pct, color: pct > 0.4 ? Colors.green : Colors.red),
        Text('$timeLeft', style: const TextStyle(fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/// Resultado: resumen y animación de "confeti" simple con canvas.
class ScoreSummary extends StatefulWidget {
  final int score;
  final int total;
  final VoidCallback onRestart;
  const ScoreSummary({super.key, required this.score, required this.total, required this.onRestart});

  @override
  State<ScoreSummary> createState() => _ScoreSummaryState();
}

class _ScoreSummaryState extends State<ScoreSummary> with SingleTickerProviderStateMixin {
  late final AnimationController _ctr;
  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _ctr = AnimationController(vsync: this, duration: const Duration(seconds: 3))..addListener(() => setState(() {}));
    _spawnParticles();
    _ctr.forward();
  }

  void _spawnParticles() {
    final rnd = Random();
    final n = 40;
    for (var i = 0; i < n; i++) {
      _particles.add(_ConfettiParticle(
        offset: Offset(rnd.nextDouble() * 300, -rnd.nextDouble() * 40),
        velocity: Offset((rnd.nextDouble() - 0.5) * 120, 40 + rnd.nextDouble() * 80),
        color: Colors.primaries[i % Colors.primaries.length],
        size: 6 + rnd.nextDouble() * 8,
        life: 2 + rnd.nextDouble() * 2,
      ));
    }
  }

  @override
  void dispose() {
    _ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = _ctr.value;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: 340,
        height: 300,
        child: CustomPaint(
          painter: _ConfettiPainter(particles: _particles, progress: pct),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Puntuación: ${widget.score}/${widget.total}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ElevatedButton.icon(onPressed: widget.onRestart, icon: const Icon(Icons.replay), label: const Text('Volver a iniciar')),
            ]),
          ),
        ),
      ),
    ]);
  }
}

class _ConfettiParticle {
  Offset offset;
  Offset velocity;
  final Color color;
  final double size;
  final double life;

  _ConfettiParticle({required this.offset, required this.velocity, required this.color, required this.size, required this.life});
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 3.0;
    final paint = Paint();
    for (var p in particles) {
      final dt = t;
      final gravity = 120.0;
      final nx = p.offset.dx + p.velocity.dx * dt * 0.6;
      final ny = p.offset.dy + p.velocity.dy * dt * 0.8 + 0.5 * gravity * dt * dt;
      final alpha = ((1 - (dt / p.life)).clamp(0.0, 1.0) * 255).toInt();
      paint.color = p.color.withAlpha(alpha);
      canvas.drawRect(Rect.fromCenter(center: Offset(nx, ny), width: p.size, height: p.size), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}

/// Aplicación principal: juego de preguntas con muchas animaciones.
/// - Animaciones implícitas y explícitas
/// - Flip 3D de tarjeta para respuesta
/// - AnimatedSwitcher, AnimatedContainer, AnimatedOpacity, AnimatedScale
/// - Control por AnimationController y curvas personalizadas
/// - Rutas con transiciones y gesto de "arrastrar para volver" simulado
class AnimationQuizApp extends StatelessWidget {
  const AnimationQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animaciones en Flutter - Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const SplashScreen(),
    );
  }
}

/// Pantalla inicial con logo animado y transición a Home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctr;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctr = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _scale = CurvedAnimation(parent: _ctr, curve: Curves.elasticOut);
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctr, curve: const Interval(0.0, 0.6)));
    _rotation = Tween<double>(begin: -0.6, end: 0.0).animate(CurvedAnimation(parent: _ctr, curve: const Interval(0.2, 1.0, curve: Curves.easeOut)));
    _ctr.forward();
    // navegacion tras atraso
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(pageBuilder: (_, __, ___) => const HomePage(), transitionsBuilder: _fadeTransition));
      }
    });
  }

  Widget _fadeTransition(_, Animation<double> anim, __, Widget child) {
    return FadeTransition(opacity: anim, child: child);
  }

  @override
  void dispose() {
    _ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seed = Colors.deepPurple;
    return Scaffold(
      backgroundColor: seed.shade50,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctr,
          builder: (context, child) {
            return Opacity(
              opacity: _fade.value,
              child: Transform.rotate(
                angle: _rotation.value,
                child: Transform.scale(scale: 0.8 + 0.4 * _scale.value, child: child),
              ),
            );
          },
          child: _SplashLogo(),
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [cs.primaryContainer, cs.primary]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: const Icon(Icons.question_answer, color: Colors.white, size: 44),
        ),
        const SizedBox(width: 14),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('AnimQuiz', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text('Codelab de animaciones', style: TextStyle(fontSize: 12)),
          ],
        )
      ],
    );
  }
}

/// Página principal con opciones: jugar, demos de animaciones y ajustes.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openAnimatedDemos(BuildContext c) {
    Navigator.push(c, _createRoute(const AnimDemosPage()));
  }

  void _openQuiz(BuildContext c) {
    Navigator.push(c, _createRoute(const QuizLauncher()));
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (_, anim, __) => FadeTransition(opacity: anim, child: page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Animaciones en Flutter'), centerTitle: true, elevation: 2),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Bienvenido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Este codelab demuestra varias técnicas de animación en Flutter. Explora la demo o inicia el quiz.', style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 12),
                Wrap(spacing: 10, children: [
                  ElevatedButton.icon(onPressed: () => _openQuiz(context), icon: const Icon(Icons.play_arrow), label: const Text('Iniciar Quiz')),
                  OutlinedButton.icon(onPressed: () => _openAnimatedDemos(context), icon: const Icon(Icons.animation), label: const Text('Demos')),
                ])
              ]),
            ),
          ),
          const SizedBox(height: 12),
          const _FeatureList(),
          const SizedBox(height: 12),
          Card(child: Padding(padding: const EdgeInsets.all(12), child: _AboutBox())),
        ],
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(leading: const Icon(Icons.play_circle), title: const Text('Animaciones implícitas'), subtitle: const Text('AnimatedContainer, AnimatedOpacity, etc.')),
      ListTile(leading: const Icon(Icons.build), title: const Text('Animaciones explícitas'), subtitle: const Text('AnimationController, Tween, CurvedAnimation')),
      ListTile(leading: const Icon(Icons.flip), title: const Text('Flip 3D de tarjeta'), subtitle: const Text('Transform con Matrix4')),
      ListTile(leading: const Icon(Icons.list), title: const Text('AnimatedSwitcher & transiciones'), subtitle: const Text('Cambio suave de widgets')),
    ]);
  }
}

class _AboutBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Sobre este codelab', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      const Text('Aprende a combinar animaciones implícitas y explícitas creando un quiz interactivo.'),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: const [
        Chip(label: Text('Implicit')),
        Chip(label: Text('Explicit')),
        Chip(label: Text('3D')),
        Chip(label: Text('Transitions')),
      ]),
    ]);
  }
}

/// Página con varios demos de animación (interactivos).
class AnimDemosPage extends StatelessWidget {
  const AnimDemosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demos de animación'), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(12), children: const [
        Padding(padding: EdgeInsets.symmetric(vertical: 8), child: _ImplicitDemo()),
        Padding(padding: EdgeInsets.symmetric(vertical: 8), child: _ExplicitMotionDemo()),
        Padding(padding: EdgeInsets.symmetric(vertical: 8), child: _FlipCardDemo()),
        Padding(padding: EdgeInsets.symmetric(vertical: 8), child: _SwitcherDemo()),
      ]),
    );
  }
}

/// Demo de animaciones implícitas combinadas.
class _ImplicitDemo extends StatefulWidget {
  const _ImplicitDemo();

  @override
  State<_ImplicitDemo> createState() => _ImplicitDemoState();
}

class _ImplicitDemoState extends State<_ImplicitDemo> {
  bool _big = false;
  bool _visible = true;
  Color _color = Colors.teal;
  double _radius = 12;

  void _toggle() {
    setState(() {
      _big = !_big;
      _visible = !_visible;
      _color = Color.lerp(_color, Colors.deepOrange, 0.5) ?? _color;
      _radius = _radius == 12 ? 40 : 12;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = _big ? 220.0 : 140.0;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Animaciones implícitas', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Center(
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOutCubic,
                width: size,
                height: size,
                decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(_radius)),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _visible ? 1 : 0.3,
                  child: Center(child: Icon(_big ? Icons.star : Icons.auto_awesome, size: _big ? 64 : 42, color: Colors.white)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text('Tap para alternar tamaño, color y opacidad')),
        ]),
      ),
    );
  }
}

/// Demo explícito: movimiento y curva personalizada con AnimationController.
class _ExplicitMotionDemo extends StatefulWidget {
  const _ExplicitMotionDemo();

  @override
  State<_ExplicitMotionDemo> createState() => _ExplicitMotionDemoState();
}

class _ExplicitMotionDemoState extends State<_ExplicitMotionDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _offset;
  late final Animation<double> _scale;
  late final Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _offset = Tween<Offset>(begin: const Offset(-0.6, 0), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _rotate = Tween<double>(begin: -0.08, end: 0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _replay() {
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Animación explícita', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              return Transform.translate(
                offset: _offset.value * MediaQuery.of(context).size.width * 0.4,
                child: Transform.rotate(angle: _rotate.value, child: Transform.scale(scale: _scale.value, child: child)),
              );
            },
            child: Container(
              height: 120,
              decoration: BoxDecoration(color: Colors.indigo.shade400, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('Movimiento controlado', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            ElevatedButton(onPressed: _replay, child: const Text('Reproducir')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () => _ctrl.stop(), child: const Text('Pausar')),
          ]),
        ]),
      ),
    );
  }
}

/// Demo: tarjeta que gira en 3D con AnimationController.
class _FlipCardDemo extends StatefulWidget {
  const _FlipCardDemo();

  @override
  State<_FlipCardDemo> createState() => _FlipCardDemoState();
}

class _FlipCardDemoState extends State<_FlipCardDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _ctr;
  bool _front = true;

  @override
  void initState() {
    super.initState();
    _ctr = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void dispose() {
    _ctr.dispose();
    super.dispose();
  }

  void _flip() {
    if (_front) {
      _ctr.forward();
    } else {
      _ctr.reverse();
    }
    setState(() => _front = !_front);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Flip 3D', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _flip,
            child: SizedBox(
              width: double.infinity,
              height: 180,
              child: AnimatedBuilder(
                animation: _ctr,
                builder: (context, child) {
                  // rotY de 0 a pi
                  final angle = _ctr.value * pi;
                  // para que la cara trasera no se renderice invertida, ajustamos la rotacion y la opacidad
                  final isUnder = angle > pi / 2;
                  final displayAngle = isUnder ? angle - pi : angle;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0015)
                      ..rotateY(displayAngle),
                    child: isUnder ? _buildBack() : _buildFront(),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text('Tap para girar la tarjeta')),
        ]),
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      decoration: BoxDecoration(color: Colors.orange.shade400, borderRadius: BorderRadius.circular(12)),
      child: const Center(child: Text('Frente', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700))),
    );
  }

  Widget _buildBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: Container(
        decoration: BoxDecoration(color: Colors.blueGrey.shade700, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text('Reverso', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700))),
      ),
    );
  }
}

/// Demo de AnimatedSwitcher con transiciones personalizadas.
class _SwitcherDemo extends StatefulWidget {
  const _SwitcherDemo();

  @override
  State<_SwitcherDemo> createState() => _SwitcherDemoState();
}

class _SwitcherDemoState extends State<_SwitcherDemo> {
  int _count = 0;

  void _next() => setState(() => _count++);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('AnimatedSwitcher', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, anim) {
                final rotate = Tween(begin: -0.5, end: 0.0).animate(anim);
                return RotationTransition(turns: rotate, child: FadeTransition(opacity: anim, child: child));
              },
              child: Container(
                key: ValueKey<int>(_count),
                width: 160,
                height: 120,
                decoration: BoxDecoration(color: Colors.primaries[_count % Colors.primaries.length].shade300, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text('Tarjeta $_count', style: const TextStyle(fontWeight: FontWeight.w700))),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: ElevatedButton(onPressed: _next, child: const Text('Siguiente'))),
        ]),
      ),
    );
  }
}

/// Lanzador del quiz para configurar niveles y empezar.
class QuizLauncher extends StatefulWidget {
  const QuizLauncher({super.key});

  @override
  State<QuizLauncher> createState() => _QuizLauncherState();
}

class _QuizLauncherState extends State<QuizLauncher> {
  int _questions = 5;
  String _theme = 'General';
  bool _timer = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          ListTile(title: const Text('Preguntas'), trailing: Text('$_questions')),
          Slider(value: _questions.toDouble(), min: 3, max: 12, divisions: 9, label: '$_questions', onChanged: (v) => setState(() => _questions = v.round())),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _theme,
            items: const [DropdownMenuItem(value: 'General', child: Text('General')), DropdownMenuItem(value: 'Ciencia', child: Text('Ciencia')), DropdownMenuItem(value: 'Arte', child: Text('Arte'))],
            onChanged: (v) => setState(() => _theme = v ?? 'General'),
            decoration: const InputDecoration(labelText: 'Tema'),
          ),
          SwitchListTile(title: const Text('Temporizador por pregunta'), value: _timer, onChanged: (v) => setState(() => _timer = v)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(context, _quizRoute(QuizScreenConfig(count: _questions, theme: _theme, timed: _timer)));
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Empezar'),
          )
        ]),
      ),
    );
  }

  Route _quizRoute(QuizScreenConfig cfg) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => QuizScreen(config: cfg),
      transitionsBuilder: (_, anim, __, child) {
        final offset = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
        return SlideTransition(position: offset, child: FadeTransition(opacity: anim, child: child));
      },
    );
  }
}

/// Configuración para la pantalla de quiz.
class QuizScreenConfig {
  final int count;
  final String theme;
  final bool timed;
  const QuizScreenConfig({required this.count, required this.theme, required this.timed});
}

/// Modelo de pregunta simple.
class Question {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  Question({required this.prompt, required this.options, required this.correctIndex, required this.explanation});
}

/// Pantalla principal del quiz con animaciones por cada pregunta.
class QuizScreen extends StatefulWidget {
  final QuizScreenConfig config;
  const QuizScreen({super.key, required this.config});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late final List<Question> _questions;
  int _index = 0;
  int _score = 0;
  bool _showResult = false;
  bool _answered = false;
  int? _selected;
  late final AnimationController _progressCtr;
  Timer? _qTimer;
  int _timeLeft = 0;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions(widget.config.count, widget.config.theme);
    _progressCtr = AnimationController(vsync: this, duration: Duration(seconds: max(6, widget.config.timed ? 8 : 1)));
    if (widget.config.timed) _startTimer();
  }

  @override
  void dispose() {
    _progressCtr.dispose();
    _qTimer?.cancel();
    super.dispose();
  }

  List<Question> _generateQuestions(int count, String theme) {
    // Generador básico y reproducible de preguntas
    final rng = Random(42 + theme.hashCode);
    final List<Question> list = [];
    for (var i = 0; i < count; i++) {
      final a = '¿Cuál es el resultado de ${i + 2} + ${rng.nextInt(8) + 1}?';
      final correct = (i + 2) + (rng.nextInt(8) + 1);
      final options = List<int>.generate(4, (j) => correct + (j - 1)).toList();
      options.shuffle(rng);
      final correctIndex = options.indexOf(correct);
      list.add(Question(
        prompt: a,
        options: options.map((e) => e.toString()).toList(),
        correctIndex: correctIndex,
        explanation: 'Porque ${(correct - 1)} + 1 = $correct',
      ));
    }
    return list;
  }

  void _startTimer() {
    _timeLeft = 8;
    _progressCtr.duration = Duration(seconds: _timeLeft);
    _progressCtr.forward(from: 0);
    _qTimer?.cancel();
    _qTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          t.cancel();
          _onTimeout();
        }
      });
    });
  }

  void _onTimeout() {
    // tratar como incorrecta
    setState(() {
      _answered = true;
      _selected = null;
    });
    Future.delayed(const Duration(milliseconds: 700), () => _nextQuestion());
  }

  void _select(int idx) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selected = idx;
      if (idx == _questions[_index].correctIndex) _score++;
    });
    // animar feedback y luego avanzar
    Future.delayed(const Duration(milliseconds: 1000), () => _nextQuestion());
  }

  void _nextQuestion() {
    _qTimer?.cancel();
    _progressCtr.stop();
    if (_index + 1 >= _questions.length) {
      setState(() {
        _showResult = true;
      });
      return;
    }
    setState(() {
      _index++;
      _answered = false;
      _selected = null;
    });
    if (widget.config.timed) _startTimer();
  }

  void _restart() {
    setState(() {
      _questions.clear();
    });
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const QuizLauncher()));
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressCtr,
      builder: (context, child) {
        final pct = widget.config.timed ? _progressCtr.value : (_index / max(1, _questions.length));
        return LinearProgressIndicator(value: pct, minHeight: 8, color: pct > 0.6 ? Colors.green : Colors.orange);
      },
    );
  }

  Widget _buildQuestionCard(Question q) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Pregunta ${_index + 1} / ${_questions.length}', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(q.prompt, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Column(
          children: List.generate(q.options.length, (i) {
            final correct = i == q.correctIndex;
            final selected = _selected == i;
            Color? color;
            if (_answered) {
              if (selected) color = correct ? Colors.green.shade400 : Colors.red.shade400;
              if (correct && !selected) color = Colors.green.shade200;
            }
            return AnimatedOptionTile(
              key: ValueKey('q_${_index}_opt_$i'),
              text: q.options[i],
              highlightColor: color,
              onTap: () => _select(i),
              disabled: _answered,
            );
          }),
        ),
        const SizedBox(height: 10),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Explicación: ${q.explanation}', style: TextStyle(color: Colors.grey.shade700)),
          ),
          crossFadeState: _answered ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 400),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resultados')),
        body: Center(
          child: ScoreSummary(score: _score, total: _questions.length, onRestart: _restart),
        ),
      );
    }
    final q = _questions[_index];
    return WillPopScope(
      onWillPop: () async {
        // confirmar salida
        final res = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Salir'), content: const Text('¿Deseas abandonar el quiz?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sí'))]));
        return res ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Animado'),
          actions: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Center(child: Text('P: ${_index + 1}/${_questions.length} • S: $_score'))),
          ],
        ),
        body: Column(children: [
          Padding(padding: const EdgeInsets.all(8), child: _buildProgressBar()),
          Expanded(
            child: Stack(children: [
              // AnimatedSwitcher para transición entre preguntas
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, anim) {
                  final inAnim = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(anim);
                  return SlideTransition(position: inAnim, child: FadeTransition(opacity: anim, child: child));
                },
                child: Card(
                  key: ValueKey<int>(_index),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: _buildQuestionCard(q),
                ),
              ),
              // temporizador visual circular
              if (widget.config.timed)
                Positioned(right: 18, top: 18, child: CircularTimer(timeLeft: _timeLeft, total: _progressCtr.duration?.inSeconds ?? 8)),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Tile de opción con animaciones de escala y color.
class AnimatedOptionTile extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool disabled;
  final Color? highlightColor;
  const AnimatedOptionTile({super.key, required this.text, required this.onTap, this.disabled = false, this.highlightColor});

  @override
  State<AnimatedOptionTile> createState() => _AnimatedOptionTileState();
}

class _AnimatedOptionTileState extends State<AnimatedOptionTile> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool _pressed = false;
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.disabled) return;
    _anim.forward();
    setState(() {
      _scale = 0.97;
      _pressed = true;
    });
  }

  void _onTapUp(_) {
    if (widget.disabled) return;
    _anim.reverse();
    setState(() {
      _scale = 1.0;
      _pressed = false;
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.highlightColor ?? (Theme.of(context).colorScheme.surfaceVariant);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: () {
          _anim.reverse();
          setState(() {
            _scale = 1.0;
            _pressed = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(_scale, _scale),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
          child: ListTile(
            title: Text(widget.text),
            trailing: widget.disabled ? const Icon(Icons.lock_clock) : null,
          ),
        ),
      ),
    );
  }
}

/// Temporizador circular simple.
class CircularTimer extends StatelessWidget {
  final int timeLeft;
  final int total;
  const CircularTimer({super.key, required this.timeLeft, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (timeLeft / total).clamp(0.0, 1.0) : 0.0;
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(alignment: Alignment.center, children: [
        CircularProgressIndicator(value: pct, color: pct > 0.4 ? Colors.green : Colors.red),
        Text('$timeLeft', style: const TextStyle(fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/// Resultado: resumen y animación de "confeti" simple con canvas.
class ScoreSummary extends StatefulWidget {
  final int score;
  final int total;
  final VoidCallback onRestart;
  const ScoreSummary({super.key, required this.score, required this.total, required this.onRestart});

  @override
  State<ScoreSummary> createState() => _ScoreSummaryState();
}

class _ScoreSummaryState extends State<ScoreSummary> with SingleTickerProviderStateMixin {
  late final AnimationController _ctr;
  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _ctr = AnimationController(vsync: this, duration: const Duration(seconds: 3))..addListener(() => setState(() {}));
    _spawnParticles();
    _ctr.forward();
  }

  void _spawnParticles() {
    final rnd = Random();
    final n = 40;
    for (var i = 0; i < n; i++) {
      _particles.add(_ConfettiParticle(
        offset: Offset(rnd.nextDouble() * 300, -rnd.nextDouble() * 40),
        velocity: Offset((rnd.nextDouble() - 0.5) * 120, 40 + rnd.nextDouble() * 80),
        color: Colors.primaries[i % Colors.primaries.length],
        size: 6 + rnd.nextDouble() * 8,
        life: 2 + rnd.nextDouble() * 2,
      ));
    }
  }

  @override
  void dispose() {
    _ctr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = _ctr.value;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: 340,
        height: 300,
        child: CustomPaint(
          painter: _ConfettiPainter(particles: _particles, progress: pct),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Puntuación: ${widget.score}/${widget.total}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ElevatedButton.icon(onPressed: widget.onRestart, icon: const Icon(Icons.replay), label: const Text('Volver a iniciar')),
            ]),
          ),
        ),
      ),
    ]);
  }
}

class _ConfettiParticle {
  Offset offset;
  Offset velocity;
  final Color color;
  final double size;
  final double life;

  _ConfettiParticle({required this.offset, required this.velocity, required this.color, required this.size, required this.life});
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 3.0;
    final paint = Paint();
    for (var p in particles) {
      final dt = t;
      final gravity = 120.0;
      final nx = p.offset.dx + p.velocity.dx * dt * 0.6;
      final ny = p.offset.dy + p.velocity.dy * dt * 0.8 + 0.5 * gravity * dt * dt;
      final alpha = ((1 - (dt / p.life)).clamp(0.0, 1.0) * 255).toInt();
      paint.color = p.color.withAlpha(alpha);
      canvas.drawRect(Rect.fromCenter(center: Offset(nx, ny), width: p.size, height: p.size), paint);
    }
  }