import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Capa de Datos: Inicializamos el servicio
  final prefsService = SharedPreferencesService();
  final themeRepository = ThemeRepository(prefsService);

  runApp(MainApp(themeRepository: themeRepository));
}

// --- CAPA DE DATOS (SERVICE & REPOSITORY) ---

class SharedPreferencesService {
  static const String _kDarkModeKey = 'isDarkMode';

  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkModeKey, isDark);
  }

  Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kDarkModeKey) ?? false;
  }
}

class ThemeRepository {
  final SharedPreferencesService _service;
  ThemeRepository(this._service);

  Future<bool> getDarkMode() => _service.loadTheme();
  Future<void> setDarkMode(bool value) => _service.saveTheme(value);
}

// --- CAPA DE PRESENTACIÓN (VIEWMODEL) ---

class ThemeViewModel extends ChangeNotifier {
  final ThemeRepository _repository;
  bool _isDarkMode = false;

  ThemeViewModel(this._repository) {
    _loadInitialTheme();
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> _loadInitialTheme() async {
    _isDarkMode = await _repository.getDarkMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _repository.setDarkMode(_isDarkMode);
    notifyListeners();
  }
}

// --- CAPA DE INTERFAZ (UI) ---

class MainApp extends StatefulWidget {
  final ThemeRepository themeRepository;
  const MainApp({super.key, required this.themeRepository});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late ThemeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ThemeViewModel(widget.themeRepository);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _viewModel.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          home: Scaffold(
            appBar: AppBar(title: const Text('Proyecto 20: Persistencia')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Persistencia con SharedPreferences', 
                    style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Modo Oscuro'),
                      Switch(
                        value: _viewModel.isDarkMode,
                        onChanged: (value) => _viewModel.toggleTheme(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}