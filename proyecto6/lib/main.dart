import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 1. Definimos el modelo de datos
class Album {
  final int userId;
  final int id;
  final String title;

  const Album({required this.userId, required this.id, required this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'userId': int userId, 'id': int id, 'title': String title} => Album(
          userId: userId,
          id: id,
          title: title,
        ),
      _ => throw const FormatException('Error al cargar el álbum.'),
    };
  }
}

// 2. Función para obtener los datos con "Autorización"
Future<Album> fetchAlbum() async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/albums/1'),
    // Aquí es donde enviamos la "llave" al servidor
    headers: {
      HttpHeaders.authorizationHeader: 'Basic tu_token_de_api_aqui',
    },
  );

  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Falló la conexión con el servidor');
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proyecto 6 - Peticiones HTTP',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: Scaffold(
        appBar: AppBar(title: const Text('Fetch Data Autorizado')),
        body: Center(
          child: FutureBuilder<Album>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  'Título del álbum:\n${snapshot.data!.title}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // Por defecto, muestra un circulito de carga
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}