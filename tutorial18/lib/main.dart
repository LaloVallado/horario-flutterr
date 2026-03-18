import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const PurchaseDemoApp());
}

/// Demo sencillo de "compras dentro de la app".
/// Este main simula la compra de:
///  - consumible: 2000 Dashes (moneda)
///  - no consumible: tema de tablero moderno (compra única)
///  - suscripción: duplica la velocidad de dashes generados automáticamente
///
/// Nota: Es una simulación educativa. Para producción use `in_app_purchase`
/// y verificación en servidor.
class PurchaseDemoApp extends StatelessWidget {
  const PurchaseDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dash Clicker - IAP Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const PurchaseHome(),
    );
  }
}

class PurchaseHome extends StatefulWidget {
  const PurchaseHome({super.key});

  @override
  State<PurchaseHome> createState() => _PurchaseHomeState();
}

class _PurchaseHomeState extends State<PurchaseHome> {
  final FakePurchaseService _service = FakePurchaseService();
  int _dashes = 120; // moneda local
  bool _modernBoard = false; // compra no consumible
  bool _subscribed = false; // suscripción activa
  Timer? _autoTimer;
  int _autoPerTick = 1;

  @override
  void initState() {
    super.initState();
    _service.onPurchaseResult.listen(_handlePurchaseResult);
    _startAutoTicks();
  }

  @override
  void dispose() {
    _service.dispose();
    _autoTimer?.cancel();
    super.dispose();
  }

  void _startAutoTicks() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        _dashes += _autoPerTick;
      });
    });
  }

  void _handlePurchaseResult(PurchaseResult res) {
    // se invoca cuando la "tienda" responde
    if (!mounted) return;
    setState(() {
      if (res.success) {
        switch (res.type) {
          case PurchaseType.consumable:
            _dashes += 2000;
            _showSnack('Compra completada: +2000 Dashes');
            break;
          case PurchaseType.nonConsumable:
            _modernBoard = true;
            _showSnack('Tablero actualizado: ahora moderno');
            break;
          case PurchaseType.subscription:
            _subscribed = true;
            _autoPerTick = 2; // doble velocidad
            _showSnack('Suscripción activa: velocidad duplicada');
            _service.simulateSubscriptionExpiry(Duration(seconds: 20)); // demo: caduca después
            break;
          default:
            break;
        }
      } else {
        _showSnack('Compra fallida: ${res.message ?? "error"}');
      }
    });
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _buyConsumable() async {
    await _service.buyConsumable();
  }

  Future<void> _buyNonConsumable() async {
    if (_modernBoard) {
      _showSnack('Ya tienes el tablero moderno');
      return;
    }
    await _service.buyNonConsumable();
  }

  Future<void> _subscribe() async {
    if (_subscribed) {
      _showSnack('Suscripción ya activa');
      return;
    }
    await _service.subscribe();
  }

  Future<void> _restore() async {
    final restored = await _service.restorePurchases();
    if (restored.contains(PurchaseType.nonConsumable)) {
      setState(() => _modernBoard = true);
      _showSnack('Restaurado: tablero moderno');
    }
    if (restored.contains(PurchaseType.subscription)) {
      setState(() {
        _subscribed = true;
        _autoPerTick = 2;
      });
      _showSnack('Restaurada suscripción');
    }
  }

  void _cancelSubscription() {
    _service.cancelSubscription();
    setState(() {
      _subscribed = false;
      _autoPerTick = 1;
    });
    _showSnack('Suscripción cancelada (simulada)');
  }

  @override
  Widget build(BuildContext context) {
    final boardPreview = _modernBoard ? _modernBoardWidget() : _classicBoardWidget();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dash Clicker - Compras in-app (demo)'),
        actions: [
          IconButton(onPressed: _restore, icon: const Icon(Icons.restore)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(children: [
          Row(children: [
            Expanded(child: Text('Dashes: $_dashes', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            ElevatedButton.icon(
              onPressed: () => setState(() => _dashes += 1),
              icon: const Icon(Icons.add),
              label: const Text('Click +1'),
            ),
          ]),
          const SizedBox(height: 12),
          boardPreview,
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Comprar Dashes (consumible)', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Compra 2000 Dashes. Repetible.'),
                const SizedBox(height: 8),
                Row(children: [
                  ElevatedButton(onPressed: _buyConsumable, child: const Text('Comprar 2000 Dashes — \$1.99')),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: () => setState(() => _dashes += 200), child: const Text('Demo añadir 200')),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Actualizar tablero (no consumible)', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(_modernBoard ? 'Comprado — disfruta del tablero moderno' : 'Compra única: tema moderno'),
                const SizedBox(height: 8),
                Row(children: [
                  ElevatedButton(onPressed: _buyNonConsumable, child: const Text('Comprar moderno — \$2.99')),
                  const SizedBox(width: 8),
                  if (_modernBoard)
                    OutlinedButton(onPressed: () => _showSnack('Gracias por comprar'), child: const Text('Gracias')),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Suscripción (mensual) — duplicador', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(_subscribed ? 'Activa — beneficios aplicados' : 'Activa la suscripción para duplicar la generación automática'),
                const SizedBox(height: 8),
                Row(children: [
                  ElevatedButton(onPressed: _subscribe, child: const Text('Suscribirse — \$0.99/mes')),
                  const SizedBox(width: 8),
                  if (_subscribed)
                    OutlinedButton(onPressed: _cancelSubscription, child: const Text('Cancelar')),
                ]),
              ]),
            ),
          ),
          const Spacer(),
          Text('Estado interno (demo): sub=$_subscribed • moderno=$_modernBoard'),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSnack('En producción, aquí iniciaría flujo real con Play/App Store'),
        icon: const Icon(Icons.info_outline),
        label: const Text('Info IAP'),
      ),
    );
  }

  Widget _classicBoardWidget() {
    return Container(
      height: 120,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
      child: Center(child: Text('Tablero clásico', style: TextStyle(color: Colors.grey.shade700))),
    );
  }

  Widget _modernBoardWidget() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.teal.shade400, Colors.green.shade300]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.green.shade200.withOpacity(0.6), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Center(child: Text('Tablero moderno', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
    );
  }
}

/// Servicio simulado de compras: comunica resultados vía stream.
/// En la vida real reemplace por integración con Play / App Store y verificación en servidor.
class FakePurchaseService {
  final StreamController<PurchaseResult> _ctrl = StreamController.broadcast();
  Stream<PurchaseResult> get onPurchaseResult => _ctrl.stream;

  bool _subscribed = false;
  Timer? _subTimer;

  Future<void> buyConsumable() async {
    // simula comunicación con la "tienda"
    await Future.delayed(Duration(seconds: 1 + Random().nextInt(2)));
    _ctrl.add(PurchaseResult(success: true, type: PurchaseType.consumable));
  }

  Future<void> buyNonConsumable() async {
    await Future.delayed(const Duration(seconds: 1));
    _ctrl.add(PurchaseResult(success: true, type: PurchaseType.nonConsumable));
  }

  Future<void> subscribe() async {
    await Future.delayed(const Duration(seconds: 1));
    _subscribed = true;
    _ctrl.add(PurchaseResult(success: true, type: PurchaseType.subscription));
  }

  Future<Set<PurchaseType>> restorePurchases() async {
    // demo: devuelve lo que "existe"
    await Future.delayed(const Duration(seconds: 1));
    final restored = <PurchaseType>{};
    if (_subscribed) restored.add(PurchaseType.subscription);
    // noConsumable hard-coded demo
    // en la práctica, restore consulta la tienda / backend
    restored.add(PurchaseType.nonConsumable);
    return restored;
  }

  void cancelSubscription() {
    _subscribed = false;
    _subTimer?.cancel();
  }

  /// Para demo: caduca la suscripción tras [duration]
  void simulateSubscriptionExpiry(Duration duration) {
    _subTimer?.cancel();
    _subTimer = Timer(duration, () {
      _subscribed = false;
      _ctrl.add(PurchaseResult(success: true, type: PurchaseType.subscription, message: 'expired'));
    });
  }

  void dispose() {
    _ctrl.close();
    _subTimer?.cancel();
  }
}

enum PurchaseType { consumable, nonConsumable, subscription }

class PurchaseResult {
  final bool success;
  final PurchaseType type;
  final String? message;
  PurchaseResult({required this.success, required this.type, this.message});
}