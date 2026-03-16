import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // Requiere: flutter pub add sqflite
import 'package:path/path.dart';       // Requiere: flutter pub add path

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SQLMonitorScreen(),
    ));

// --- MODELO DE DATOS ---
class SensorLog {
  final int? id;
  final double value;
  final String date;

  SensorLog({this.id, required this.value, required this.date});

  Map<String, dynamic> toMap() => {'id': id, 'value': value, 'date': date};
}

// --- SERVICIO DE BASE DE DATOS (CORREGIDO) ---
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sensors_v1.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    // Obtiene la ruta del directorio de bases de datos según el OS
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    // openDatabase es la función que te marcaba error
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            value REAL NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insert(SensorLog log) async {
    final db = await instance.database;
    await db.insert('logs', log.toMap());
  }

  Future<List<SensorLog>> readAll() async {
    final db = await instance.database;
    final result = await db.query('logs', orderBy: 'date DESC');
    return result.map((json) => SensorLog(
      id: json['id'] as int,
      value: json['value'] as double,
      date: json['date'] as String,
    )).toList();
  }
}

// --- INTERFAZ DE USUARIO ---
class SQLMonitorScreen extends StatefulWidget {
  const SQLMonitorScreen({super.key});

  @override
  State<SQLMonitorScreen> createState() => _SQLMonitorScreenState();
}

class _SQLMonitorScreenState extends State<SQLMonitorScreen> {
  List<SensorLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _refreshLogs();
  }

  Future<void> _refreshLogs() async {
    final data = await DatabaseHelper.instance.readAll();
    setState(() => _logs = data);
  }

  Future<void> _addLog() async {
    final newLog = SensorLog(
      value: 20.0 + (DateTime.now().second % 10),
      date: DateTime.now().toString().substring(0, 19),
    );
    await DatabaseHelper.instance.insert(newLog);
    _refreshLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        title: const Text('SQL ENGINE • DB_V1', style: TextStyle(fontFamily: 'monospace', fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeroStats(),
          Expanded(child: _buildLogList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        onPressed: _addLog,
        child: const Icon(Icons.bolt, color: Colors.black),
      ),
    );
  }

  Widget _buildHeroStats() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Text("REGISTROS TOTALES", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2)),
          const SizedBox(height: 10),
          Text("${_logs.length}", style: const TextStyle(color: Colors.cyanAccent, fontSize: 50, fontWeight: FontWeight.bold)),
          const Text("STORAGE: OK", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final log = _logs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: const Icon(Icons.data_exploration, color: Colors.cyanAccent, size: 18),
            title: Text("${log.value}°C", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(log.date, style: const TextStyle(color: Colors.white24, fontSize: 12)),
            trailing: Text("#${log.id}", style: const TextStyle(color: Colors.white10)),
          ),
        );
      },
    );
  }
}