import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SimplexApp());
}

class SimplexApp extends StatelessWidget {
  const SimplexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simplex Solver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
