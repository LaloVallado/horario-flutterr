// ...existing code...
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const FCMSimApp());
}

/// Aplicación que simula Firebase Cloud Messaging (FCM) por completo
/// dentro de main.dart, sin dependencias externas.
/// - Registro de "token" de dispositivo
/// - Suscripción a temas
/// - Recepción de mensajes en foreground/background/terminated (simulado)
/// - "Enviar" mensajes dirigidos a token o temas desde la propia app
/// - Historial de notificaciones, interacción por tap, y ejemplos de payloads
class FCMSimApp extends StatelessWidget {
  const FCMSimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Simulado',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

/// Modelo de un "mensaje remoto" similar a RemoteMessage de FCM.
class MockRemoteMessage {
  final String messageId;
  final DateTime sentTime;
  final Map<String, String> data;
  final String? title;
  final String? body;
  final String? topic;
  final String? toToken;

  MockRemoteMessage({
    required this.messageId,
    required this.sentTime,
    required this.data,
    this.title,
    this.body,
    this.topic,
    this.toToken,
  });

  @override
  String toString() {
    return 'MockRemoteMessage($messageId, title:$title, body:$body, data:$data, topic:$topic, to:$toToken)';
  }
}

/// Servicio singleton que simula el comportamiento de FCM.
class MockFCMService {
  MockFCMService._internal() {
    _token = _generateToken();
    Future.delayed(const Duration(milliseconds: 300))
        .then((_) => _stateController.add(_token));
  }
  static final MockFCMService instance = MockFCMService._internal();

  final _rand = Random();
  String _token = '';
  final Set<String> _topics = <String>{};
  final List<MockRemoteMessage> _delivered = [];
  final List<MockRemoteMessage> _pendingBackground = [];
  final StreamController<MockRemoteMessage> _onMessageController =
      StreamController<MockRemoteMessage>.broadcast();
  final StreamController<String> _stateController =
      StreamController<String>.broadcast();

  Stream<MockRemoteMessage> get onMessage => _onMessageController.stream;
  Stream<String> get tokenStream => _stateController.stream;
  List<MockRemoteMessage> get deliveredMessages => List.unmodifiable(_delivered);
  List<MockRemoteMessage> get pendingBackgroundMessages =>
      List.unmodifiable(_pendingBackground);
  String get token => _token;
  Set<String> get subscribedTopics => Set.unmodifiable(_topics);

  String _generateToken() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final r = _rand.nextInt(100000);
    return 'mock_token_${now}_$r';
  }

  Future<void> refreshToken() async {
    await Future.delayed(const Duration(milliseconds: 250));
    _token = _generateToken();
    _stateController.add(_token);
  }

  Future<void> subscribeToTopic(String topic) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _topics.add(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _topics.remove(topic);
  }

  /// Simula envío de mensaje desde servidor hacia un token específico.
  Future<MockRemoteMessage> sendMessageToToken({
    required String toToken,
    String? title,
    String? body,
    Map<String, String>? data,
    required AppLifecycleState appState,
  }) async {
    final msg = MockRemoteMessage(
      messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}_${_rand.nextInt(9999)}',
      sentTime: DateTime.now(),
      data: data ?? <String, String>{},
      title: title,
      body: body,
      toToken: toToken,
    );
    return _deliverMessage(msg, appState);
  }

  /// Simula envío de mensaje a un tema.
  Future<MockRemoteMessage> sendMessageToTopic({
    required String topic,
    String? title,
    String? body,
    Map<String, String>? data,
    required AppLifecycleState appState,
  }) async {
    final msg = MockRemoteMessage(
      messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}_${_rand.nextInt(9999)}',
      sentTime: DateTime.now(),
      data: data ?? <String, String>{},
      title: title,
      body: body,
      topic: topic,
    );
    // Si nadie está suscrito, aun así "entregar" para demo (se marcará en history).
    if (!_topics.contains(topic)) {
      // nothing special: still deliver for simulation
    }
    return _deliverMessage(msg, appState);
  }

  /// Entrega mensajes según estado: foreground => stream; background/paused => pending; detached => pendingBackground (terminated).
  Future<MockRemoteMessage> _deliverMessage(MockRemoteMessage msg, AppLifecycleState appState) async {
    // Simulate network latency
    await Future.delayed(Duration(milliseconds: 200 + _rand.nextInt(400)));

    _delivered.insert(0, msg);

    if (appState == AppLifecycleState.resumed) {
      // Foreground -> push via stream immediately
      _onMessageController.add(msg);
    } else {
      // Background/paused/detached -> queue as background notification to simulate system delivery
      _pendingBackground.insert(0, msg);
    }
    return msg;
  }

  /// Marca todos los pendingBackground como "tras pulsar la notificación del sistema".
  /// Retorna los mensajes "tapped" (entregados para apertura)
  Future<List<MockRemoteMessage>> popPendingBackground() async {
    final list = List<MockRemoteMessage>.from(_pendingBackground);
    _pendingBackground.clear();
    return list;
  }

  void dispose() {
    _onMessageController.close();
    _stateController.close();
  }
}

/// Página principal con dashboard para simular FCM.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final MockFCMService _fcm;
  late AppLifecycleState _appState;
  late final StreamSubscription<MockRemoteMessage> _msgSub;
  final List<MockRemoteMessage> _inbox = [];

  final _targetController = TextEditingController();
  final _topicController = TextEditingController(text: 'news');
  final _titleController = TextEditingController(text: 'Hola desde servidor');
  final _bodyController = TextEditingController(text: 'Este es un mensaje simulado.');
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _fcm = MockFCMService.instance;
    WidgetsBinding.instance.addObserver(this);
    _appState = WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
    _msgSub = _fcm.onMessage.listen((msg) {
      // Mensaje entrante en foreground
      _handleForegroundMessage(msg);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _msgSub.cancel();
    _targetController.dispose();
    _topicController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appState = state;
    });
    // Si volvemos a foreground, recuperar mensajes pendientes para que el usuario pueda "tocar" las notificaciones
    if (state == AppLifecycleState.resumed) {
      _recoverBackgroundDeliveries();
    }
  }

  void _handleForegroundMessage(MockRemoteMessage msg) {
    setState(() {
      _inbox.insert(0, msg);
    });
    // Notificar visualmente: SnackBar con acción para abrir detalle
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${msg.title ?? 'Notificación'} — ${msg.body ?? ''}'),
        action: SnackBarAction(
          label: 'Abrir',
          onPressed: () => _openMessage(msg),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _recoverBackgroundDeliveries() async {
    final pending = MockFCMService.instance.pendingBackgroundMessages;
    if (pending.isNotEmpty) {
      // Mostrar dialogo que simula "persistentes del sistema"
      final cnt = pending.length;
      final tapped = await showDialog<List<MockRemoteMessage>>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Notificaciones recibidas en ${_describeState(_appState)}'),
          content: Text('Hay $cnt notificación(es) que se entregaron mientras la app no estaba activa. ¿Desea procesarlas?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, <MockRemoteMessage>[]), child: const Text('Ignorar')),
            TextButton(onPressed: () => Navigator.pop(c, pending), child: const Text('Procesar')),
          ],
        ),
      );
      if (tapped != null && tapped.isNotEmpty) {
        // mover a inbox y abrir el primero
        setState(() {
          _inbox.insertAll(0, tapped.reversed);
        });
        _openMessage(tapped.first);
        // simular que fueron consumidas por el sistema
        await MockFCMService.instance.popPendingBackground();
      }
    }
  }

  String _describeState(AppLifecycleState s) {
    switch (s) {
      case AppLifecycleState.resumed:
        return 'foreground';
      case AppLifecycleState.inactive:
        return 'inactive';
      case AppLifecycleState.paused:
        return 'background';
      case AppLifecycleState.detached:
        return 'terminated';
      case AppLifecycleState.hidden:
        return 'hidden';
    }
  }

  void _openMessage(MockRemoteMessage msg) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => MessageDetailPage(message: msg)));
  }

  Future<void> _sendToToken() async {
    final target = _targetController.text.trim();
    if (target.isEmpty) {
      _showInfo('Ingresa un token destino (usa "mi_token" o pulsa "Copiar token").');
      return;
    }
    setState(() => _sending = true);
    try {
      final msg = await _fcm.sendMessageToToken(
        toToken: target,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        data: {'example': 'value', 'env': 'simulado'},
        appState: _appState,
      );
      _showInfo('Mensaje enviado al token: ${msg.messageId}');
    } catch (e) {
      _showInfo('Error al enviar: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendToTopic() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      _showInfo('Ingresa un tema');
      return;
    }
    setState(() => _sending = true);
    try {
      final msg = await _fcm.sendMessageToTopic(
        topic: topic,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        data: {'topic': topic},
        appState: _appState,
      );
      _showInfo('Mensaje enviado al tema (${topic}): ${msg.messageId}');
    } catch (e) {
      _showInfo('Error al enviar: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showInfo(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _refreshToken() async {
    await _fcm.refreshToken();
    setState(() {});
  }

  Future<void> _subscribeTopic() async {
    final t = _topicController.text.trim();
    if (t.isEmpty) return;
    await _fcm.subscribeToTopic(t);
    setState(() {});
    _showInfo('Suscrito a $t (simulado)');
  }

  Future<void> _unsubscribeTopic() async {
    final t = _topicController.text.trim();
    if (t.isEmpty) return;
    await _fcm.unsubscribeFromTopic(t);
    setState(() {});
    _showInfo('Desuscrito de $t (simulado)');
  }

  void _copyTokenToTarget() {
    _targetController.text = _fcm.token;
    _showInfo('Token copiado al campo destino (simulado).');
  }

  @override
  Widget build(BuildContext context) {
    final token = _fcm.token;
    final topics = _fcm.subscribedTopics.join(', ');
    final lifecycle = _describeState(_appState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM - Simulador'),
        actions: [
          IconButton(
            tooltip: 'Historial',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryPage())),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: ListView(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estado del dispositivo', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Token:'),
                    SelectableText(token, style: const TextStyle(fontFamily: 'monospace')),
                    const SizedBox(height: 8),
                    Row(children: [
                      ElevatedButton.icon(onPressed: _refreshToken, icon: const Icon(Icons.refresh), label: const Text('Refrescar token')),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(onPressed: _copyTokenToTarget, icon: const Icon(Icons.copy), label: const Text('Copiar token')),
                    ]),
                    const SizedBox(height: 8),
                    Text('Suscripciones: ${topics.isEmpty ? '(ninguna)' : topics}'),
                    const SizedBox(height: 4),
                    Row(children: [
                      SizedBox(
                        width: 140,
                        child: TextField(controller: _topicController, decoration: const InputDecoration(labelText: 'Tema')),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: _subscribeTopic, child: const Text('Suscribir')),
                      const SizedBox(width: 6),
                      OutlinedButton(onPressed: _unsubscribeTopic, child: const Text('Desuscribir')),
                    ]),
                    const SizedBox(height: 8),
                    Text('Lifecycle: $lifecycle'),
                    const SizedBox(height: 4),
                    Text('Mensajes recibidos (in-app): ${_inbox.length}'),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _inbox.take(6).map((m) {
                        return ActionChip(label: Text(m.title ?? 'Notificación'), onPressed: () => _openMessage(m));
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Enviar mensaje (simulado)', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  TextField(controller: _targetController, decoration: const InputDecoration(labelText: 'Token destino (opcional)')),
                  const SizedBox(height: 8),
                  TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Título')),
                  const SizedBox(height: 8),
                  TextField(controller: _bodyController, decoration: const InputDecoration(labelText: 'Cuerpo')),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _sending ? null : _sendToToken,
                        child: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator()) : const Text('Enviar a token'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _sending ? null : _sendToTopic,
                        child: const Text('Enviar a tema'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text('Consejo: cambia al modo background (pausar app) y envía otro mensaje; se acumulará como notificación del sistema.'),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            if (_fcm.pendingBackgroundMessages.isNotEmpty)
              Card(
                color: Colors.yellow.shade50,
                child: ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: Text('${_fcm.pendingBackgroundMessages.length} notificación(es) pendientes (simuladas)'),
                  subtitle: const Text('Pulsa para "ver" y procesar desde el sistema.'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final list = await MockFCMService.instance.popPendingBackground();
                      setState(() {
                        _inbox.insertAll(0, list.reversed);
                      });
                      _showInfo('Procesadas ${list.length} notificación(es)');
                    },
                    child: const Text('Procesar'),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Historial breve', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  for (final m in _fcm.deliveredMessages.take(6))
                    ListTile(
                      dense: true,
                      title: Text(m.title ?? '(sin título)'),
                      subtitle: Text(m.body ?? '(sin cuerpo)'),
                      trailing: Text('${m.sentTime.hour}:${m.sentTime.minute.toString().padLeft(2, '0')}'),
                      onTap: () => _openMessage(m),
                    ),
                  if (_fcm.deliveredMessages.isEmpty)
                    const Text('Sin mensajes entregados todavía.'),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            Text('Este simulador no envía notificaciones reales. Emula comportamientos de FCM para desarrollo y pruebas.', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

/// Página de detalle de mensaje.
class MessageDetailPage extends StatelessWidget {
  final MockRemoteMessage message;
  const MessageDetailPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final sent = message.sentTime;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de notificación')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(message.title ?? '(sin título)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(message.body ?? '(sin cuerpo)'),
              const SizedBox(height: 12),
              Text('MensajeId: ${message.messageId}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              const SizedBox(height: 6),
              Text('Enviado: ${sent.toLocal()}'),
              const SizedBox(height: 12),
              const Text('Payload (data):', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              for (final e in message.data.entries)
                Text('${e.key}: ${e.value}', style: const TextStyle(fontFamily: 'monospace')),
              const SizedBox(height: 14),
              ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text('Volver')),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Página con historial completo de mensajes entregados.
class HistoryPage extends StatelessWidget {
  HistoryPage({super.key});
  final _fcm = MockFCMService.instance;

  @override
  Widget build(BuildContext context) {
    final messages = _fcm.deliveredMessages;
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de mensajes')),
        body: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: messages.length,
          itemBuilder: (context, i) {
            final m = messages[i];
            return Card(
              child: ListTile(
                title: Text(m.title ?? '(sin título)'),
                subtitle: Text(m.body ?? '(sin cuerpo)'),
                trailing: Text('${m.sentTime.hour}:${m.sentTime.minute.toString().padLeft(2, '0')}'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MessageDetailPage(message: m))),
              ),
            );
          },
        ),
      );
    }
  }