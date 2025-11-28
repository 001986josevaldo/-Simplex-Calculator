import 'package:flutter/material.dart';
import 'calculadora_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _numVariaveis = 2;
  int _numRestricoes = 3;

  void _irParaCalculadora() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalculatorScreen(
          numVariaveis: _numVariaveis,
          numRestricoes: _numRestricoes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuração Simplex")),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Definir Tamanho do Problema",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                Text("Variáveis de Decisão: $_numVariaveis"),
                Slider(
                  value: _numVariaveis.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _numVariaveis.toString(),
                  onChanged: (v) => setState(() => _numVariaveis = v.toInt()),
                ),

                const SizedBox(height: 15),

                Text("Quantidade de Restrições: $_numRestricoes"),
                Slider(
                  value: _numRestricoes.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _numRestricoes.toString(),
                  onChanged: (v) => setState(() => _numRestricoes = v.toInt()),
                ),

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: _irParaCalculadora,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("CONTINUAR"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
