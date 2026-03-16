import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto40/main.dart'; // Ajusta según tu nombre de proyecto

void main() {
  testWidgets('Prueba de ingreso de texto y tap en botón', (WidgetTester tester) async {
    // 1. Cargamos el widget
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ConfigForm())));

    // 2. Verificamos el estado inicial
    expect(find.text('Esperando configuración...'), findsOneWidget);

    // 3. Ingresamos texto en el TextField
    await tester.enterText(find.byType(TextField), '25');
    
    // 4. Simulamos el Tap en el botón
    await tester.tap(find.text('ACTUALIZAR'));

    // 5. IMPORTANTE: Re-renderizamos el widget para ver los cambios de estado
    await tester.pump();

    // 6. Verificamos que el mensaje cambió
    expect(find.text('Set: 25°C'), findsOneWidget);
    expect(find.text('Esperando configuración...'), findsNothing);
  });
}