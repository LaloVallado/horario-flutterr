import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

void main() {
  runApp(const ShrineBackdropApp());
}

// ── App principal ─────────────────────────────────────────────────────────────
class ShrineBackdropApp extends StatelessWidget {
  const ShrineBackdropApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF6D4C41);
    const pink = Color(0xFFD81B60);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shrine - Componentes avanzados',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: seed).copyWith(secondary: pink),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      ),
      home: const ShrineHome(),
    );
  }
}

// ── Pantalla principal con Backdrop ──────────────────────────────────────────
class ShrineHome extends StatefulWidget {
  const ShrineHome({super.key});

  @override
  State<ShrineHome> createState() => _ShrineHomeState();
}

class _ShrineHomeState extends State<ShrineHome>
    with SingleTickerProviderStateMixin {
  final List<Category> _categories = [
    Category('Todo', Icons.grid_view),
    Category('Ropa', Icons.shopping_bag),
    Category('Hogar', Icons.chair),
    Category('Accesorios', Icons.watch),
    Category('Electrónica', Icons.headphones),
  ];

  late Category _selected;

  late final AnimationController _ctrl;
  late final Animation<double> _frontY;
  bool _isRevealed = false;

  late final List<Product> _allProducts;

  @override
  void initState() {
    super.initState();

    _selected = _categories.first;

    _allProducts = List<Product>.generate(16, (i) {
      final rng = Random(i);
      const cats = ['Ropa', 'Hogar', 'Accesorios', 'Electrónica'];
      final cat = cats[i % cats.length];
      const names = [
        'Almohadón',
        'Chaqueta',
        'Taza',
        'Reloj',
        'Auricular',
        'Lámpara',
        'Bufanda',
        'Silla',
      ];
      return Product(
        id: 'p$i',
        title: '${names[i % 8]} ${i + 1}',
        price: 9 + rng.nextInt(90),
        category: cat,
        color: Colors.primaries[i % Colors.primaries.length].shade300,
      );
    });

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _frontY = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggleBackdrop() {
    setState(() {
      _isRevealed = !_isRevealed;
      if (_isRevealed) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    });
  }

  void _selectCategory(Category c) {
    setState(() {
      _selected = c;
    });
    if (_isRevealed) _toggleBackdrop();
  }

  List<Product> get _filteredProducts {
    if (_selected.name == 'Todo') return _allProducts;
    return _allProducts
        .where((p) => p.category == _selected.name)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenHeight = mq.size.height;
    final frontHeight = screenHeight * 0.78;
    final revealedTop = screenHeight * 0.36;
    final hiddenTop = screenHeight - frontHeight;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ── Back layer ──
            _buildBackLayer(),

            // ── Front layer ──
            AnimatedBuilder(
              animation: _frontY,
              builder: (context, child) {
                final top = lerpDouble(hiddenTop, revealedTop, _frontY.value)!;
                return Positioned(
                  left: 0,
                  right: 0,
                  top: top,
                  bottom: 0,
                  child: child!,
                );
              },
              child: _buildFrontLayer(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackLayer() {
    return Container(
      color: Theme.of(context)
          .colorScheme
          .primaryContainer
          .withOpacity(0.06),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Categorías',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final c = _categories[i];
                final isSelected = c.name == _selected.name;
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tileColor: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.14)
                      : null,
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary,
                    child: Icon(c.icon, color: Colors.white),
                  ),
                  title: Text(
                    c.name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                  onTap: () => _selectCategory(c),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Consejo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Selecciona una categoría para filtrar la cuadrícula asimétrica.',
          ),
        ],
      ),
    );
  }

  Widget _buildFrontLayer(BuildContext context) {
    return Material(
      elevation: 12,
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(18)),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // App bar dentro del front layer
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _frontY,
                  ),
                  onPressed: _toggleBackdrop,
                  tooltip: 'Mostrar categorías',
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Shrine',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      _selected.name,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.search_outlined),
                  onPressed: () => ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(
                          content: Text('Buscar (demo)'))),
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, i) =>
                          _ProductCard(product: _filteredProducts[i]),
                    ),
                  );
                }
                return _AsymmetricHorizontalGrid(
                    products: _filteredProducts);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Modelos ───────────────────────────────────────────────────────────────────
class Category {
  final String name;
  final IconData icon;
  const Category(this.name, this.icon);

  @override
  bool operator ==(Object other) =>
      other is Category && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

class Product {
  final String id;
  final String title;
  final int price;
  final String category;
  final Color color;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.color,
  });
}

// ── Tarjeta de producto ───────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetail(product: product),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'hero_${product.id}',
              child: Container(
                height: 120,
                width: double.infinity,
                color: product.color,
                child: const Center(
                  child: Icon(Icons.crop_square,
                      size: 40, color: Colors.white70),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style:
                        const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price}',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () =>
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text(
                                        'Añadido a favoritos (demo)'))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Página de detalle ─────────────────────────────────────────────────────────
class ProductDetail extends StatelessWidget {
  final Product product;
  const ProductDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'hero_${product.id}',
            child: Container(
              height: 220,
              width: double.infinity,
              color: product.color,
              child: const Center(
                child: Icon(Icons.crop_square,
                    size: 64, color: Colors.white70),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Descripción de ejemplo para el producto. '
                  'Este es un demo de componentes avanzados de Material.',
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(
                          content:
                              Text('Añadido al carrito (demo)'))),
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Comprar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Grid asimétrica horizontal ────────────────────────────────────────────────
class _AsymmetricHorizontalGrid extends StatelessWidget {
  final List<Product> products;
  const _AsymmetricHorizontalGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    final cols = <List<Product>>[];
    final rng = Random(42);
    var idx = 0;
    while (idx < products.length) {
      final take = rng.nextBool() ? 2 : 3;
      cols.add(
        products.sublist(idx, min(products.length, idx + take)),
      );
      idx += take;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: cols.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, colIndex) {
          final column = cols[colIndex];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(column.length, (i) {
              final p = column[i];
              final h =
                  140.0 + (i % 3) * 30 + (colIndex % 2) * 18;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: 220,
                  height: h,
                  child: _ProductCard(product: p),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}