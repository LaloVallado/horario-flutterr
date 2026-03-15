import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const MaterialApp(home: ExampleTypingIndicator()));

class ExampleTypingIndicator extends StatefulWidget {
  const ExampleTypingIndicator({super.key});

  @override
  State<ExampleTypingIndicator> createState() => _ExampleTypingIndicatorState();
}

class _ExampleTypingIndicatorState extends State<ExampleTypingIndicator> {
  bool _isTyping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proyecto 13 - Typing Indicator')),
      body: Column(
        children: [
          const Expanded(child: Center(child: Text('Chat vacío'))),
          // Aquí usamos nuestro widget personalizado
          TypingIndicator(showIndicator: _isTyping),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() => _isTyping = !_isTyping),
            child: Text(_isTyping ? 'Detener Escritura' : 'Simular Escritura'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({
    super.key,
    this.showIndicator = false,
    this.bubbleColor = const Color(0xFF646b7f),
    this.flashingCircleDarkColor = const Color(0xFF333333),
    this.flashingCircleBrightColor = const Color(0xFFaec1dd),
  });

  final bool showIndicator;
  final Color bubbleColor;
  final Color flashingCircleDarkColor;
  final Color flashingCircleBrightColor;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with TickerProviderStateMixin {
  late AnimationController _appearanceController;
  late AnimationController _repeatingController;
  late Animation<double> _indicatorSpaceAnimation;
  late Animation<double> _smallBubbleAnimation;
  late Animation<double> _mediumBubbleAnimation;
  late Animation<double> _largeBubbleAnimation;

  final List<Interval> _dotIntervals = const [
    Interval(0.25, 0.8),
    Interval(0.35, 0.9),
    Interval(0.45, 1.0),
  ];

  @override
  void initState() {
    super.initState();

    _appearanceController = AnimationController(vsync: this);
    _repeatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _indicatorSpaceAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    ).drive(Tween<double>(begin: 0.0, end: 60.0));

    _smallBubbleAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      reverseCurve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _mediumBubbleAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      reverseCurve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _largeBubbleAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    if (widget.showIndicator) _showIndicator();
  }

  @override
  void didUpdateWidget(TypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showIndicator != oldWidget.showIndicator) {
      widget.showIndicator ? _showIndicator() : _hideIndicator();
    }
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    _repeatingController.dispose();
    super.dispose();
  }

  void _showIndicator() {
    _appearanceController.duration = const Duration(milliseconds: 750);
    _appearanceController.forward();
    _repeatingController.repeat();
  }

  void _hideIndicator() {
    _appearanceController.duration = const Duration(milliseconds: 150);
    _appearanceController.reverse();
    _repeatingController.stop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _indicatorSpaceAnimation,
      builder: (context, child) => SizedBox(height: _indicatorSpaceAnimation.value, child: child),
      child: Stack(
        children: [
          AnimatedBubble(animation: _smallBubbleAnimation, left: 8, bottom: 8, child: CircleBubble(size: 8, color: widget.bubbleColor)),
          AnimatedBubble(animation: _mediumBubbleAnimation, left: 10, bottom: 10, child: CircleBubble(size: 16, color: widget.bubbleColor)),
          AnimatedBubble(
            animation: _largeBubbleAnimation,
            left: 12,
            bottom: 12,
            child: StatusBubble(
              repeatingController: _repeatingController,
              dotIntervals: _dotIntervals,
              darkColor: widget.flashingCircleDarkColor,
              brightColor: widget.flashingCircleBrightColor,
              bubbleColor: widget.bubbleColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CircleBubble extends StatelessWidget {
  const CircleBubble({super.key, required this.size, required this.color});
  final double size; final Color color;
  @override Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}

class AnimatedBubble extends StatelessWidget {
  const AnimatedBubble({super.key, required this.animation, required this.left, required this.bottom, required this.child});
  final Animation<double> animation; final double left; final double bottom; final Widget child;
  @override Widget build(BuildContext context) => Positioned(left: left, bottom: bottom, child: AnimatedBuilder(animation: animation, builder: (context, child) => Transform.scale(scale: animation.value, alignment: Alignment.bottomLeft, child: child), child: child));
}

class StatusBubble extends StatelessWidget {
  const StatusBubble({super.key, required this.repeatingController, required this.dotIntervals, required this.darkColor, required this.brightColor, required this.bubbleColor});
  final AnimationController repeatingController; final List<Interval> dotIntervals; final Color darkColor; final Color brightColor; final Color bubbleColor;
  @override Widget build(BuildContext context) => Container(width: 85, height: 44, decoration: BoxDecoration(borderRadius: BorderRadius.circular(27), color: bubbleColor), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(3, (i) => FlashingCircle(index: i, repeatingController: repeatingController, dotIntervals: dotIntervals, darkColor: darkColor, brightColor: brightColor))));
}

class FlashingCircle extends StatelessWidget {
  const FlashingCircle({super.key, required this.index, required this.repeatingController, required this.dotIntervals, required this.darkColor, required this.brightColor});
  final int index; final AnimationController repeatingController; final List<Interval> dotIntervals; final Color darkColor; final Color brightColor;
  @override Widget build(BuildContext context) => AnimatedBuilder(animation: repeatingController, builder: (context, child) {
    final percent = dotIntervals[index].transform(repeatingController.value);
    final colorPercent = sin(pi * percent);
    return Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: Color.lerp(darkColor, brightColor, colorPercent)));
  });
}