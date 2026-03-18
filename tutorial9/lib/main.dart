import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // Ajuste estético para que la barra de estado sea transparente
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const ShrineApp());
}

// --- MODELO DE DATOS (Entidad de Producto) ---
class Product {
  final int id;
  final String name;
  final int price;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });
}

// Repositorio de datos simulado (Mock Data)
const List<Product> kProducts = [
  Product(id: 0, name: 'Vagabond sack', price: 120, category: 'Accessories'),
  Product(id: 1, name: 'Stella sunglasses', price: 58, category: 'Accessories'),
  Product(id: 2, name: 'Whitney belt', price: 35, category: 'Accessories'),
  Product(id: 3, name: 'Garden strand', price: 98, category: 'Accessories'),
  Product(id: 4, name: 'Strut earrings', price: 34, category: 'Accessories'),
  Product(id: 5, name: 'Varsity socks', price: 12, category: 'Accessories'),
  Product(id: 6, name: 'Weave keyring', price: 16, category: 'Accessories'),
  Product(id: 7, name: 'Gatsby hat', price: 40, category: 'Accessories'),
  Product(id: 8, name: 'Shrug bag', price: 198, category: 'Accessories'),
  Product(id: 9, name: 'Gilt desk trio', price: 58, category: 'Home'),
  Product(id: 10, name: 'Copper wire rack', price: 18, category: 'Home'),
  Product(id: 11, name: 'Soothe ceramic set', price: 28, category: 'Home'),
  Product(id: 12, name: 'Hurray tea set', price: 34, category: 'Home'),
  Product(id: 13, name: 'Planted shapes', price: 36, category: 'Home'),
  Product(id: 14, name: 'Quartet table', price: 175, category: 'Home'),
  Product(id: 15, name: 'Kitchen quattro', price: 129, category: 'Home'),
];

// --- APLICACIÓN PRINCIPAL ---
class ShrineApp extends StatelessWidget {
  const ShrineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/': (context) => const HomePage(),
      },
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFEDBD0), // Color base de Shrine
      ),
    );
  }
}

// --- PANTALLA DE LOGIN (MDC-101) ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                const Icon(Icons.diamond_outlined, size: 60, color: Colors.brown),
                const SizedBox(height: 16.0),
                Text('SHRINE', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 120.0),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(filled: true, labelText: 'Username'),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(filled: true, labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    _usernameController.clear();
                    _passwordController.clear();
                  },
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.popAndPushNamed(context, '/'),
                  child: const Text('NEXT'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- PANTALLA PRINCIPAL: GRID Y CARDS (MDC-102) ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Función para construir la cuadrícula de tarjetas
  List<Card> _buildGridCards(BuildContext context) {
    if (kProducts.isEmpty) return const <Card>[];

    final ThemeData theme = Theme.of(context);

    return kProducts.map((product) {
      return Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 18 / 11,
              child: Container(
                color: Colors.brown[50],
                child: const Icon(Icons.inventory_2_outlined, size: 40, color: Colors.brown),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '\$${product.price}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, semanticLabel: 'menu'),
          onPressed: () {
            // Acción para el menú lateral (implementado en MDC-104)
          },
        ),
        title: const Text('SHRINE'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search, semanticLabel: 'search'),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, semanticLabel: 'filter'),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2, // Dos columnas
          padding: const EdgeInsets.all(16.0),
          childAspectRatio: 8.0 / 9.0, // Proporción de las tarjetas
          children: _buildGridCards(context),
        ),
      ),
    );
  }
}