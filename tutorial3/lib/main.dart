import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // Forzamos el estilo de la barra de estado para que combine con el branding
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const ShrineApp());
}

// --- CONSTANTES DE BRANDING (Paleta Shrine Oficial) ---
const kShrinePink50 = Color(0xFFFEEAE6);
const kShrinePink100 = Color(0xFFFEDBD0);
const kShrinePink300 = Color(0xFFFBB8AC);
const kShrinePink400 = Color(0xFFEAA4A4);
const kShrineBrown900 = Color(0xFF442B2D);
const kShrineBrown600 = Color(0xFF7D4F52);
const kShrineErrorRed = Color(0xFFC5032B);
const kShrineSurfaceWhite = Color(0xFFFFFBFA);
const kShrineBackgroundWhite = Colors.white;

// --- MODELO DE DATOS PROFESIONAL ---
enum Category { all, accessories, clothing, home }

class Product {
  final Category category;
  final int id;
  final String name;
  final int price;

  const Product({
    required this.category,
    required this.id,
    required this.name,
    required this.price,
  });

  String get assetName => '$id-0.jpg';
}

// Repositorio robusto de productos
const List<Product> kProducts = [
  Product(category: Category.accessories, id: 0, name: 'Vagabond sack', price: 120),
  Product(category: Category.accessories, id: 1, name: 'Stella sunglasses', price: 58),
  Product(category: Category.clothing, id: 2, name: 'Whitney belt', price: 35),
  Product(category: Category.clothing, id: 3, name: 'Garden strand', price: 98),
  Product(category: Category.clothing, id: 4, name: 'Strut earrings', price: 34),
  Product(category: Category.home, id: 5, name: 'Varsity socks', price: 12),
  Product(category: Category.home, id: 6, name: 'Weave keyring', price: 16),
  Product(category: Category.home, id: 7, name: 'Gatsby hat', price: 40),
  Product(category: Category.home, id: 8, name: 'Shrug bag', price: 198),
  Product(category: Category.home, id: 9, name: 'Gilt desk trio', price: 58),
  Product(category: Category.home, id: 10, name: 'Copper wire rack', price: 18),
];

// --- APLICACIÓN ---
class ShrineApp extends StatelessWidget {
  const ShrineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      debugShowCheckedModeBanner: false,
      home: const BackdropPage(), // Usamos Backdrop como contenedor principal
      theme: _buildShrineTheme(),
    );
  }

  ThemeData _buildShrineTheme() {
    final ThemeData base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: kShrinePink100,
        onPrimary: kShrineBrown900,
        secondary: kShrineBrown900,
        error: kShrineErrorRed,
      ),
      scaffoldBackgroundColor: kShrineBackgroundWhite,
      textTheme: _buildShrineTextTheme(base.textTheme),
      textSelectionTheme: const TextSelectionThemeData(selectionColor: kShrinePink100),
    );
  }

  TextTheme _buildShrineTextTheme(TextTheme base) {
    return base.copyWith(
      headlineSmall: base.headlineSmall!.copyWith(fontWeight: FontWeight.w500, color: kShrineBrown900),
      titleLarge: base.titleLarge!.copyWith(fontSize: 18.0, color: kShrineBrown900),
      bodySmall: base.bodySmall!.copyWith(fontWeight: FontWeight.w400, fontSize: 14.0, color: kShrineBrown900),
      bodyLarge: base.bodyLarge!.copyWith(fontWeight: FontWeight.w500, fontSize: 16.0, color: kShrineBrown900),
    ).apply(fontFamily: 'Rubik');
  }
}

// --- WIDGET DE BACKDROP (Capa frontal y trasera) ---
class BackdropPage extends StatefulWidget {
  const BackdropPage({super.key});

  @override
  State<BackdropPage> createState() => _BackdropPageState();
}

class _BackdropPageState extends State<BackdropPage> with SingleTickerProviderStateMixin {
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  late AnimationController _controller;
  Category _currentCategory = Category.all;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      value: 1.0,
      vsync: this,
    );
  }

  bool get _frontLayerVisible => _controller.status == AnimationStatus.completed || _controller.status == AnimationStatus.forward;

  void _toggleBackdropLayerVisibility() {
    _frontLayerVisible ? _controller.reverse() : _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        titleSpacing: 0.0,
        leading: IconButton(
          icon: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: _controller),
          onPressed: _toggleBackdropLayerVisibility,
        ),
        title: const _ShrineAppBarTitle(),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.tune), onPressed: () {}),
        ],
      ),
      body: Stack(
        key: _backdropKey,
        children: [
          // Capa Trasera (Menú)
          _BackLayer(
            currentCategory: _currentCategory,
            onCategoryTap: (category) {
              setState(() => _currentCategory = category);
              _controller.forward();
            },
          ),
          // Capa Frontal (Productos con animación)
          _FrontLayer(
            animation: _controller,
            child: ProductGrid(category: _currentCategory),
          ),
        ],
      ),
    );
  }
}

// --- COMPONENTES DE LA INTERFAZ ---

class _ShrineAppBarTitle extends StatelessWidget {
  const _ShrineAppBarTitle();
  @override
  Widget build(BuildContext context) {
    return const Row(children: [
      Text('SHRINE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2.0)),
    ]);
  }
}

class _BackLayer extends StatelessWidget {
  final Category currentCategory;
  final ValueChanged<Category> onCategoryTap;

  const _BackLayer({required this.currentCategory, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kShrinePink100,
      padding: const EdgeInsets.only(top: 40.0),
      child: ListView(
        children: Category.values.map((cat) => _buildCategory(cat, context)).toList(),
      ),
    );
  }

  Widget _buildCategory(Category category, BuildContext context) {
    final categoryString = category.toString().replaceAll('Category.', '').toUpperCase();
    final bool isSelected = category == currentCategory;

    return GestureDetector(
      onTap: () => onCategoryTap(category),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            Text(
              categoryString,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? kShrineBrown900 : kShrineBrown600,
              ),
            ),
            if (isSelected)
              Container(margin: const EdgeInsets.only(top: 4.0), width: 70.0, height: 2.0, color: kShrineBrown900),
          ],
        ),
      ),
    );
  }
}

class _FrontLayer extends AnimatedWidget {
  final Widget child;
  const _FrontLayer({required Animation<double> animation, required this.child}) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return PositionedTransition(
      rect: RelativeRectTween(
        begin: const RelativeRect.fromLTRB(0.0, 450.0, 0.0, 0.0),
        end: const RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
      child: Material(
        elevation: 16.0,
        color: kShrineSurfaceWhite,
        shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(46.0)),
        ),
        child: child,
      ),
    );
  }
}

// --- GRID DE PRODUCTOS ---
class ProductGrid extends StatelessWidget {
  final Category category;
  const ProductGrid({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = kProducts.where((p) => category == Category.all || p.category == category).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: filteredProducts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        mainAxisSpacing: 15.0,
        crossAxisSpacing: 15.0,
      ),
      itemBuilder: (context, index) => ProductCard(product: filteredProducts[index]),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: kShrinePink50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.shopping_bag_outlined, color: kShrinePink300, size: 50)),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.favorite_border, color: kShrineBrown600.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(product.name, style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 15), textAlign: TextAlign.center, maxLines: 1),
          Text('\$${product.price}', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}