// ...existing code...
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// App autónoma que simula un flujo de autenticación con FirebaseUI
/// pero sin dependencias externas. Incluye: inicio de sesión, registro,
/// recuperación de contraseña, sign-in con Google simulado y perfil.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth UI (simulado)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const RootPage(),
    );
  }
}

/// Modelo simple de usuario.
class AuthUser {
  final String uid;
  final String email;
  final String? displayName;
  final String provider; // 'password' | 'google' etc.

  AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.provider = 'password',
  });
}

/// Servicio de autenticación simulado en memoria.
/// Expone un stream para el estado de autenticación.
class MockAuthService {
  MockAuthService._internal();
  static final MockAuthService instance = MockAuthService._internal();

  final StreamController<AuthUser?> _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _current;

  Stream<AuthUser?> get authStateChanges => _controller.stream;

  AuthUser? get currentUser => _current;

  Future<void> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Simulación básica de validación/credenciales
    if (password != 'password123' && password != '123456') {
      throw AuthException('auth/wrong-password', 'Contraseña incorrecta (simulada). Usa "password123".');
    }
    _current = AuthUser(uid: 'uid_${email.hashCode}', email: email, displayName: email.split('@').first, provider: 'password');
    _controller.add(_current);
  }

  Future<void> registerWithEmail(String email, String password, String displayName) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (password.length < 6) {
      throw AuthException('auth/weak-password', 'La contraseña debe tener al menos 6 caracteres.');
    }
    // simula que el email ya existe
    if (email.contains('exist')) {
      throw AuthException('auth/email-already-in-use', 'El correo ya está registrado (simulado).');
    }
    _current = AuthUser(uid: 'uid_${email.hashCode}', email: email, displayName: displayName, provider: 'password');
    _controller.add(_current);
  }

  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 900));
    // Simula un usuario de Google
    _current = AuthUser(uid: 'google_${DateTime.now().millisecondsSinceEpoch}', email: 'usuario.google@example.com', displayName: 'Usuario Google', provider: 'google');
    _controller.add(_current);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 700));
    // Simulación: si email no contiene '@' -> error
    if (!email.contains('@')) {
      throw AuthException('auth/invalid-email', 'Correo no válido (simulado).');
    }
    // Si ok, no cambia estado, sólo "envía" el correo
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _current = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}

class AuthException implements Exception {
  final String code;
  final String message;
  AuthException(this.code, this.message);
  @override
  String toString() => 'AuthException($code): $message';
}

/// Página raíz que escucha el estado de autenticación y muestra
/// la interfaz apropiada con transiciones suaves.
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  late final StreamSubscription<AuthUser?> _sub;
  AuthUser? _user;

  @override
  void initState() {
    super.initState();
    _user = MockAuthService.instance.currentUser;
    _sub = MockAuthService.instance.authStateChanges.listen((u) {
      setState(() => _user = u);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _user == null ? const SignInScreen() : ProfileScreen(user: _user!),
    );
  }
}

/// Pantalla de inicio de sesión (simulada FirebaseUI).
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signInEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await MockAuthService.instance.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inicio de sesión correcto (simulado)')));
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInGoogle() async {
    setState(() => _loading = true);
    try {
      await MockAuthService.instance.signInWithGoogle();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inicio con Google (simulado)')));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error en inicio con Google (simulado)')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goRegister() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  void _goForgot() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final widthConstraint = MediaQuery.of(context).size.width > 600 ? 520.0 : double.infinity;
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widthConstraint),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 6),
                    Hero(
                      tag: 'appLogo',
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [Colors.blueGrey.shade700, Colors.teal.shade300]),
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.transparent,
                          child: const Icon(Icons.lock_outline, size: 30, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Auth Demo (simulado)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text('Usa un flujo similar a FirebaseUI sin dependencias externas.', textAlign: TextAlign.center),
                    const SizedBox(height: 14),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email_outlined)),
                            validator: (v) {
                              final s = (v ?? '').trim();
                              if (s.isEmpty) return 'Ingresa tu correo';
                              if (!s.contains('@')) return 'Correo inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) {
                              final s = v ?? '';
                              if (s.isEmpty) return 'Ingresa tu contraseña';
                              if (s.length < 6) return 'Al menos 6 caracteres';
                              return null;
                            },
                            onFieldSubmitted: (_) => _signInEmail(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(onPressed: _goRegister, child: const Text('Crear cuenta')),
                              TextButton(onPressed: _goForgot, child: const Text('¿Olvidaste la contraseña?')),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _signInEmail,
                              child: _loading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Iniciar con correo'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: _loading ? null : _signInGoogle,
                              icon: const Icon(Icons.login),
                              label: const Text('Iniciar con Google'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text('Este es un simulador. Contraseña válida: "password123"', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pantalla de registro de usuario (simulada).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await MockAuthService.instance.registerWithEmail(_emailCtrl.text.trim(), _passCtrl.text, _nameCtrl.text.trim());
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro exitoso (simulado)')));
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width > 600 ? 520 : double.infinity),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    const Text('Registro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                          const SizedBox(height: 8),
                          TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Correo')),
                          const SizedBox(height: 8),
                          TextFormField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(onPressed: _loading ? null : _register, child: _loading ? const CircularProgressIndicator() : const Text('Crear cuenta')),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pantalla para recuperar contraseña (simulada).
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await MockAuthService.instance.sendPasswordResetEmail(_emailCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correo de recuperación enviado (simulado)')));
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width > 600 ? 520 : double.infinity),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    const Text('Enviar enlace de recuperación', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailCtrl,
                            decoration: const InputDecoration(labelText: 'Correo'),
                            validator: (v) {
                              final s = (v ?? '').trim();
                              if (s.isEmpty) return 'Ingresa tu correo';
                              if (!s.contains('@')) return 'Correo inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(onPressed: _loading ? null : _sendReset, child: const Text('Enviar')),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pantalla de perfil simple que muestra información del "usuario" y permite cerrar sesión.
class ProfileScreen extends StatelessWidget {
  final AuthUser user;
  const ProfileScreen({super.key, required this.user});

  Future<void> _signOut(BuildContext context) async {
    await MockAuthService.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesión cerrada (simulado)')));
  }

  @override
  Widget build(BuildContext context) {
    final name = user.displayName ?? user.email.split('@').first;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Cerrar sesión',
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'appLogo',
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.blueGrey.shade300,
                      child: Text(name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 24, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 8),
                                    Text(user.email, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('UID: ${user.uid}', style: const TextStyle(fontSize: 12)),
                                          const SizedBox(height: 4),
                                          Text('Proveedor: ${user.provider}', style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.logout),
                                        label: const Text('Cerrar sesión'),
                                        onPressed: () => _signOut(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  }