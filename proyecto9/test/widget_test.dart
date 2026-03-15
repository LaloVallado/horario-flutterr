import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 1. Definimos el widget que queremos probar
class MyWidget extends StatelessWidget {
  const MyWidget({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text(message)),
      ),
    );
  }
}

void main() {
  // 2. Definimos la prueba
  testWidgets('MyWidget tiene un título y un mensaje', (WidgetTester tester) async {
    // 3. Le decimos al "robot" (tester) que renderice el widget
    await tester.pumpWidget(const MyWidget(title: 'Hola', message: 'Mundo'));

    // 4. Creamos los "buscadores" (Finders)
    final titleFinder = find.text('Hola');
    final messageFinder = find.text('Mundo');

    // 5. Verificamos que existan exactamente una vez (Matchers)
    expect(titleFinder, findsOneWidget);
    expect(messageFinder, findsOneWidget);
    
    // Prueba extra: verificamos que NO exista un texto que no pusimos
    expect(find.text('Adiós'), findsNothing);
  });
}