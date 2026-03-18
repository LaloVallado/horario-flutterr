// ...existing code...
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const StartupNamerApp());
}

/// App principal con soporte a tema dinámico mediante ValueNotifier.
class StartupNamerApp extends StatelessWidget {
  const StartupNamerApp({super.key});

  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Generador de nombres',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
            brightness: Brightness.dark,
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}

/// Pantalla principal: generador, favoritos y panel responsivo.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  static const _adjectives = [
    'quick', 'bright', 'silent', 'warm', 'frost', 'cloud', 'neo', 'prime', 'nova', 'lumen', 'urban', 'wild'
  ];
  static const _nouns = [
    'stream', 'nest', 'bridge', 'pixel', 'garden', 'core', 'cafe', 'haven', 'shift', 'pulse', 'forge', 'root'
  ];

  final Random _rnd = Random();
  final List<String> _suggestions = <String>[];
  final Set<String> _favorites = <String>{};
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _autoGenerate = false;
  Timer? _autoTimer;
  String _style = 'camel'; // camel | dash | underscore
  String? _selected; // para vista de detalles en modo ancho
  late final AnimationController _favAnim;

  @override
  void initState() {
    super.initState();
    _favAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _generateBatch(20);
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _favAnim.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _generateBatch(int count) {
    final newItems = List<String>.generate(count, (_) => _composeName());
    setState(() => _suggestions.insertAll(0, newItems));
  }

  String _composeName() {
    final a = _adjectives[_rnd.nextInt(_adjectives.length)];
    final n = _nouns[_rnd.nextInt(_nouns.length)];
    return _formatName('$a$n');
  }

  String _formatName(String raw) {
    switch (_style) {
      case 'dash':
        return raw.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}-${m[2]}').toLowerCase();
      case 'underscore':
        return raw.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]}_${m[2]}').toLowerCase();
      case 'camel':
      default:
        return raw[0].toLowerCase() + raw.substring(1);
    }
  }

  void _toggleFavorite(String name) {
    setState(() {
      if (!_favorites.remove(name)) {
        _favorites.add(name);
        _favAnim.forward(from: 0);
      }
    });
  }

  void _startAuto() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _generateBatch(1);
    });
    setState(() => _autoGenerate = true);
  }

  void _stopAuto() {
    _autoTimer?.cancel();
    setState(() => _autoGenerate = false);
  }

  Iterable<String> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _suggestions;
    return _suggestions.where((s) => s.contains(q));
  }

  int _pronounceabilityScore(String name) {
    final vowels = RegExp(r'[aeiou]');
    final v = vowels.allMatches(name).length;
    final score = (v / max(1, name.length) * 100).round();
    return min(100, score + (_rnd.nextInt(10) - 3));
  }

  Widget _buildSuggestionTile(String s) {
    final fav = _favorites.contains(s);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.primaries[s.hashCode % Colors.primaries.length].shade400,
        child: Text(s[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
      ),
      title: Text(s, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('Disponible: ${_rnd.nextBool() ? "Probable" : "Desconocido"}'),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? Colors.redAccent : null),
          onPressed: () => _toggleFavorite(s),
          tooltip: fav ? 'Quitar favorito' : 'Agregar favorito',
        ),
        IconButton(
          icon: const Icon(Icons.copy_outlined),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: s));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre copiado al portapapeles')));
          },
        ),
      ]),
      onTap: () {
        if (MediaQuery.of(context).size.width > 800) {
          setState(() => _selected = s);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(name: s, favorite: _favorites.contains(s), onFav: _toggleFavorite)));
        }
      },
    );
  }

  void _openFavorites() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesScreen(favorites: _favorites.toList(), onRemove: (n) => _toggleFavorite(n))));
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (c) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Wrap(children: [
            ListTile(title: const Text('Apariencia'), trailing: Switch(
              value: StartupNamerApp.themeMode.value == ThemeMode.dark,
              onChanged: (v) => StartupNamerApp.themeMode.value = v ? ThemeMode.dark : ThemeMode.light,
            )),
            const Divider(),
            ListTile(title: const Text('Formato de nombre'), subtitle: Text(_style), onTap: () {}),
            RadioListTile<String>(title: const Text('camelCase'), value: 'camel', groupValue: _style, onChanged: (v) => setState(() => _style = v!)),
            RadioListTile<String>(title: const Text('kebab-case'), value: 'dash', groupValue: _style, onChanged: (v) => setState(() => _style = v!)),
            RadioListTile<String>(title: const Text('snake_case'), value: 'underscore', groupValue: _style, onChanged: (v) => setState(() => _style = v!)),
            const SizedBox(height: 8),
            ElevatedButton.icon(onPressed: () { Navigator.pop(c); _generateBatch(10); }, icon: const Icon(Icons.shuffle), label: const Text('Generar 10 nombres')),
            const SizedBox(height: 6),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi primera app - Generador'),
        actions: [
          IconButton(icon: const Icon(Icons.favorite), onPressed: _openFavorites, tooltip: 'Favoritos'),
          IconButton(icon: const Icon(Icons.settings), onPressed: _openSettings, tooltip: 'Ajustes'),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar sugerencias...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchCtrl.clear())),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
      ),
      body: isWide ? Row(children: [
        Flexible(flex: 1, child: _buildListPane()),
        VerticalDivider(width: 1),
        Flexible(flex: 1, child: _buildDetailPane()),
      ]) : _buildListPane(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _generateBatch(5);
          _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
        },
        label: const Text('Generar más'),
        icon: const Icon(Icons.add),
      ),
      persistentFooterButtons: [
        TextButton.icon(
          onPressed: _autoGenerate ? _stopAuto : _startAuto,
          icon: Icon(_autoGenerate ? Icons.pause_circle : Icons.play_circle),
          label: Text(_autoGenerate ? 'Detener auto' : 'Auto generar'),
        ),
        TextButton.icon(onPressed: _openFavorites, icon: const Icon(Icons.list), label: Text('Favoritos (${_favorites.length})')),
      ],
    );
  }

  Widget _buildListPane() {
    final items = _filtered.toList();
    return RefreshIndicator(
      onRefresh: () async {
        _generateBatch(8);
      },
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length + 1,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              child: Center(child: Text('Fin de la lista. Total: ${_suggestions.length}')),
            );
          }
          final s = items[index];
          return _buildSuggestionTile(s);
        },
      ),
    );
  }

  Widget _buildDetailPane() {
    final name = _selected ?? (_suggestions.isNotEmpty ? _suggestions.first : null);
    if (name == null) {
      return const Center(child: Text('Selecciona un nombre para ver detalles'));
    }
    final score = _pronounceabilityScore(name);
    return Padding(
      padding: const EdgeInsets.all(22.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Hero(tag: 'logo_$name', child: _mockLogo(name, size: 64)),
              const SizedBox(width: 12),
              Expanded(child: Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
              IconButton(icon: Icon(_favorites.contains(name) ? Icons.favorite : Icons.favorite_border, color: _favorites.contains(name) ? Colors.red : null), onPressed: () => _toggleFavorite(name)),
            ]),
            const SizedBox(height: 12),
            Text('Pronunciación: $score%', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: score / 100),
            const SizedBox(height: 18),
            const Text('Mock preview', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _mockCard(name)),
              const SizedBox(width: 12),
              Expanded(child: _mockCard('$name.dev')),
            ]),
            const SizedBox(height: 18),
            Text('Detalles técnicos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Hash: ${name.hashCode.toRadixString(16)}'),
            Text('Lenguaje: ${name.contains(RegExp(r'[aeiou]')) ? "Con vocales" : "Sin vocales"}'),
            const Spacer(),
            Row(children: [
              OutlinedButton.icon(onPressed: () async { await Clipboard.setData(ClipboardData(text: name)); _showCopySnack(); }, icon: const Icon(Icons.copy), label: const Text('Copiar')),
              const SizedBox(width: 8),
              ElevatedButton.icon(onPressed: () { setState(() => _favorites.add(name)); _showCopySnack(text: 'Agregado a favoritos'); }, icon: const Icon(Icons.favorite), label: const Text('Favorito')),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _mockLogo(String name, {double size = 48}) {
    final color = Colors.primaries[name.hashCode % Colors.primaries.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color.shade600, borderRadius: BorderRadius.circular(12)),
      child: Center(child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 22))),
    );
  }

  Widget _mockCard(String title) {
    return Container(
      height: 110,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.withOpacity(0.08)),
      child: Center(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
    );
  }

  void _showCopySnack({String text = 'Copiado'}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

/// Pantalla de detalle simple usada en móvil.
class DetailScreen extends StatelessWidget {
  final String name;
  final bool favorite;
  final void Function(String) onFav;
  const DetailScreen({super.key, required this.name, required this.favorite, required this.onFav});

  @override
  Widget build(BuildContext context) {
    final color = Colors.primaries[name.hashCode % Colors.primaries.length];
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(children: [
          Hero(tag: 'logo_$name', child: Container(width: 80, height: 80, decoration: BoxDecoration(color: color.shade600, borderRadius: BorderRadius.circular(14)), child: Center(child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 30))))),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Vista previa básica y acciones', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(onPressed: () => onFav(name), icon: Icon(favorite ? Icons.favorite : Icons.favorite_border), label: Text(favorite ? 'Quitar favorito' : 'Agregar')),
            const SizedBox(width: 12),
            OutlinedButton.icon(onPressed: () async { await Clipboard.setData(ClipboardData(text: name)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copiado'))); }, icon: const Icon(Icons.copy), label: const Text('Copiar')),
          ]),
        ]),
      ),
    );
  }
}

/// Pantalla de favoritos con posibilidad de remover.
class FavoritesScreen extends StatefulWidget {
  final List<String> favorites;
  final void Function(String) onRemove;
  const FavoritesScreen({super.key, required this.favorites, required this.onRemove});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final List<String> _list;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.favorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        actions: [
          IconButton(onPressed: () { setState(() { _list.clear(); widget.favorites.toList().forEach((n) => widget.onRemove(n)); }); }, icon: const Icon(Icons.delete_sweep), tooltip: 'Limpiar todos'),
        ],
      ),
      body: _list.isEmpty ? const Center(child: Text('No hay favoritos aún')) : ListView.builder(
        itemCount: _list.length,
        itemBuilder: (context, i) {
          final n = _list[i];
          return Dismissible(
            key: ValueKey(n),
            onDismissed: (_) {
              setState(() => _list.removeAt(i));
              widget.onRemove(n);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removido $n')));
            },
            background: Container(color: Colors.redAccent, child: const Align(alignment: Alignment.centerRight, child: Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.delete, color: Colors.white)))),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.primaries[n.hashCode % Colors.primaries.length].shade300, child: Text(n[0].toUpperCase())),
              title: Text(n),
              trailing: IconButton(icon: const Icon(Icons.copy_outlined), onPressed: () async { await Clipboard.setData(ClipboardData(text: n)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copiado'))); }),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(name: n, favorite: true, onFav: widget.onRemove))),
            ),
          );
        },
      ),
    );
  }
}