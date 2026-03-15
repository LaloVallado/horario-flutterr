import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// 1. Modelo de Datos
class Dog {
  final int id;
  final String name;
  final int age;

  Dog({required this.id, required this.name, required this.age});

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'age': age};
  }

  @override
  String toString() => 'Dog{id: $id, name: $name, age: $age}';
}

void main() => runApp(const MaterialApp(home: DogListScreen()));

class DogListScreen extends StatefulWidget {
  const DogListScreen({super.key});

  @override
  State<DogListScreen> createState() => _DogListScreenState();
}

class _DogListScreenState extends State<DogListScreen> {
  late Future<Database> database;
  List<Dog> _dogs = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  // 2. Abrir y Crear la Base de Datos
  Future<void> _initDatabase() async {
    database = openDatabase(
      join(await getDatabasesPath(), 'doggie_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
        );
      },
      version: 1,
    );
    _refreshDogs();
  }

  // 3. Operaciones CRUD
  Future<void> _insertDog(Dog dog) async {
    final db = await database;
    await db.insert('dogs', dog.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    _refreshDogs();
  }

  Future<void> _refreshDogs() async {
    final db = await database;
    final List<Map<String, Object?>> dogMaps = await db.query('dogs');
    setState(() {
      _dogs = [
        for (final map in dogMaps)
          Dog(id: map['id'] as int, name: map['name'] as String, age: map['age'] as int),
      ];
    });
  }

  Future<void> _deleteDog(int id) async {
    final db = await database;
    await db.delete('dogs', where: 'id = ?', whereArgs: [id]);
    _refreshDogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proyecto 21: SQLite Dogs')),
      body: ListView.builder(
        itemCount: _dogs.length,
        itemBuilder: (context, index) {
          final dog = _dogs[index];
          return ListTile(
            title: Text(dog.name),
            subtitle: Text('Edad: ${dog.age}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteDog(dog.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Agregamos un perro con ID basado en el timestamp para evitar duplicados
          _insertDog(Dog(
            id: DateTime.now().millisecondsSinceEpoch,
            name: 'Perrito ${_dogs.length + 1}',
            age: 2,
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}