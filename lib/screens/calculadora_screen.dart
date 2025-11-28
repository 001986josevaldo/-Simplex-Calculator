import 'package:flutter/material.dart';
import '../utils/calculator_controller.dart'; // Importe o novo controller

class CalculatorScreen extends StatefulWidget {
  final int numVariaveis;
  final int numRestricoes;

  const CalculatorScreen({
    super.key,
    required this.numVariaveis,
    required this.numRestricoes,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late CalculatorController _controller;
  String _textoResultado = "";

  @override
  void initState() {
    super.initState();
    // Inicializa a lógica separada
    _controller = CalculatorController(
      widget.numVariaveis,
      widget.numRestricoes,
    );
  }

  @override
  void dispose() {
    // Apenas manda o controller se limpar
    _controller.dispose();
    super.dispose();
  }

  void _aoClicarCalcular() {
    // Pede ao controller o resultado e atualiza a tela
    setState(() {
      _textoResultado = _controller.calcular();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inserir Dados")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BLOCO 1: FUNÇÃO OBJETIVO ---
            const Text(
              "Função Objetivo (Max Z)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(widget.numVariaveis, (index) {
                return SizedBox(
                  width: 100,
                  child: TextField(
                    // Acessa o controller da lista que está no outro arquivo
                    controller: _controller.zControllers[index],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "x${index + 1}",
                      border: const OutlineInputBorder(),
                      prefixText: "C${index + 1}: ",
                    ),
                  ),
                );
              }),
            ),

            const Divider(height: 30),

            // --- BLOCO 2: RESTRIÇÕES ---
            const Text(
              "Restrições",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.numRestricoes,
              itemBuilder: (context, i) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Restrição ${i + 1}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              ...List.generate(widget.numVariaveis, (j) {
                                return Container(
                                  width: 80,
                                  margin: const EdgeInsets.only(right: 5),
                                  child: TextField(
                                    // Acessa a matriz de controladores
                                    controller:
                                        _controller.restricoesControllers[i][j],
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: "x${j + 1}",
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 5,
                                          ),
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                );
                              }),
                              const Text(
                                " ≤ ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: _controller.bControllers[i],
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Limite",
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // --- BLOCO 3: BOTÃO E RESULTADO ---
            Center(
              child: ElevatedButton(
                onPressed: _aoClicarCalcular,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text("CALCULAR"),
              ),
            ),

            if (_textoResultado.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 40),
                padding: const EdgeInsets.all(15),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _textoResultado,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
