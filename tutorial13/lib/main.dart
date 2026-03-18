// ...existing code...
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ShrineApp());
}

/// App principal que configura Material (Material 3) y la página de login.
class ShrineApp extends StatelessWidget {
  const ShrineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine - MDC-101',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const LoginPage(),
    );
  }
}

/// Página de inicio de sesión con un formulario robusto, controladores y feedback.
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _userFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _obscure = true;
  bool _loading = false;

  late final AnimationController _logoController;
  late final Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _logoAnimation = CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack);
    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _userController.dispose();
    _passController.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _submit({required bool iosStyle}) async {
    // Trigger validation
    if (!_formKey.currentState!.validate()) {
      // Focus the first invalid field
      if (_userController.text.trim().isEmpty) {
        _userFocus.requestFocus();
      } else {
        _passFocus.requestFocus();
      }
      return;
    }

    // Simular proceso de inicio de sesión con indicador de carga
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _loading = false);

    // Mostrar feedback y navegar a una pantalla ficticia
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sesión iniciada como "${_userController.text}" (${iosStyle ? "iOS" : "Android"})'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.of(context).push(_createRouteToHome());
  }

  Route _createRouteToHome() {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => const HomePage(),
      transitionsBuilder: (_, anim, __, child) {
        return FadeTransition(opacity: anim, child: child);
      },
    );
  }

  Widget _buildLogo(double size) {
    // Logo simulado con degradado y hero animation
    return ScaleTransition(
      scale: _logoAnimation,
      child: Hero(
        tag: 'shrineLogo',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepPurple.shade400, Colors.pink.shade300]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Center(
            child: Icon(
              Icons.storefront_outlined,
              size: size * 0.5,
              color: Colors.white,
              semanticLabel: 'Logo de Shrine',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platform = defaultTargetPlatform;
    final isLarge = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isLarge ? 520 : double.infinity),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(isLarge ? 140 : 110),
                  const SizedBox(height: 18),
                  const Text('Shrine',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
                  const SizedBox(height: 8),
                  const Text('Inicia sesión para continuar',
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                  const SizedBox(height: 20),

                  // Formulario de acceso
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _userController,
                          focusNode: _userFocus,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Nombre de usuario',
                            hintText: 'ej. maria@ejemplo.com',
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username, AutofillHints.email],
                          validator: (v) {
                            final s = v?.trim() ?? '';
                            if (s.isEmpty) return 'Ingresa un nombre de usuario';
                            if (!s.contains('@') && s.length < 3) return 'Nombre demasiado corto';
                            return null;
                          },
                          onFieldSubmitted: (_) => _passFocus.requestFocus(),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passController,
                          focusNode: _passFocus,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: Semantics(
                              container: true,
                              label: 'Mostrar u ocultar contraseña',
                              child: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                          ),
                          obscureText: _obscure,
                          autofillHints: const [AutofillHints.password],
                          validator: (v) {
                            final s = v ?? '';
                            if (s.isEmpty) return 'Ingresa tu contraseña';
                            if (s.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                            return null;
                          },
                          onFieldSubmitted: (_) => _submit(iosStyle: false),
                        ),
                        const SizedBox(height: 8),

                        // Línea con "¿Olvidaste?" y demo de InkWell (ondas de tinta)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                // Acción de "Crear cuenta" simulada con diálogo
                                showDialog(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('Crear cuenta'),
                                    content: const Text('Este es un ejemplo. Implementa tu flujo real aquí.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cerrar'))
                                    ],
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                child: Text(
                                  'Crear cuenta',
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Acción "Olvidé contraseña"
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Correo de recuperación enviado (simulado)')),
                                );
                              },
                              child: const Text('¿Olvidaste?'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Botones: estilo Android (Elevated) y iOS (outlined/flat)
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: _loading ? null : () => _submit(iosStyle: false),
                                  icon: _loading ? const SizedBox.shrink() : const Icon(Icons.login),
                                  label: _loading
                                      ? const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Iniciar (Android)'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed: _loading ? null : () => _submit(iosStyle: true),
                                  icon: const Icon(Icons.phone_iphone_outlined),
                                  label: const Text('Iniciar (iOS)'),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Separador con texto
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text('o', style: TextStyle(color: Colors.black54)),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 12),
                        // Botón alternativo: login con huella (simulado)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Demostración de retroalimentación e interacción táctil
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Autenticación biométrica (simulada)')),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.fingerprint, size: 20),
                                  SizedBox(width: 8),
                                  Text('Iniciar con huella'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Pie con información y micro-interacción
                  TextButton.icon(
                    onPressed: () {
                      showAboutDialog(
                        context: context,
                        applicationIcon: _buildLogo(40),
                        applicationName: 'Shrine (demo)',
                        applicationVersion: 'MDC-101 • actualización: 2023-05-09',
                        children: const [Text('Ejemplo educativo de componentes Material sin dependencias externas.')],
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Acerca de MDC-101'),
                  ),

                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Página objetivo tras el login: pequeña cuadrícula de productos simulada
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  static const items = [
    'Almohadón',
    'Cafetera',
    'Chaqueta',
    'Lámpara',
    'Taza',
    'Silla',
    'Alfombra',
    'Cuadro',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shrine'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.search_outlined),
              onPressed: () {},
              tooltip: 'Buscar',
            ),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.9),
        itemCount: items.length,
        itemBuilder: (context, i) {
          return Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductPage(name: items[i])));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.primaries[i % Colors.primaries.length].shade300, Colors.white]),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Center(
                        child: Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.black54),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(items[i], style: const TextStyle(fontWeight: FontWeight.w600)),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Página de detalle de producto simple que muestra animación de hero del logo (demo).
class ProductPage extends StatelessWidget {
  final String name;
  const ProductPage({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Hero(
            tag: 'shrineLogo',
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.pink.shade200, Colors.deepPurple.shade300]),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Icon(Icons.storefront, color: Colors.white, size: 36)),
            ),
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Descripción del producto de ejemplo. Aquí se mostrarían los detalles reales.'),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text('Volver')),
        ],
      ),
    );
  }
}