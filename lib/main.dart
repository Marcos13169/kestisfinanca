import 'package:financas_web/componentes.dart';
import 'package:financas_web/pagina_financa.dart';
import 'package:financas_web/pagina_principal.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Componentes().criaTema(),
      initialRoute: "/paginaFinanca",
      routes: {
        "/paginaFinanca": (context) => PaginaPrincipal(),
      },
    );
  }
}
