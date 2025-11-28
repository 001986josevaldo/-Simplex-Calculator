import 'package:flutter/material.dart';
import 'simplex_solver.dart'; // Importe seu arquivo de lógica matemática

class CalculatorController {
  final int numVariaveis;
  final int numRestricoes;

  // Listas de controladores de texto
  List<TextEditingController> zControllers = [];
  List<List<TextEditingController>> restricoesControllers = [];
  List<TextEditingController> bControllers = [];

  CalculatorController(this.numVariaveis, this.numRestricoes) {
    _inicializarControladores();
  }

  // Cria os campos dinamicamente
  void _inicializarControladores() {
    // Função Objetivo
    for (int i = 0; i < numVariaveis; i++) {
      zControllers.add(TextEditingController());
    }

    // Restrições e Limites (b)
    for (int i = 0; i < numRestricoes; i++) {
      List<TextEditingController> linha = [];
      for (int j = 0; j < numVariaveis; j++) {
        linha.add(TextEditingController());
      }
      restricoesControllers.add(linha);
      bControllers.add(TextEditingController());
    }
  }

  // Faz o parsing dos textos e chama o Solver
  String calcular() {
    try {
      // Converte textos para double
      List<double> C = zControllers
          .map((c) => double.tryParse(c.text) ?? 0.0)
          .toList();

      List<List<double>> A = [];
      for (var linha in restricoesControllers) {
        A.add(linha.map((c) => double.tryParse(c.text) ?? 0.0).toList());
      }

      List<double> b = bControllers
          .map((c) => double.tryParse(c.text) ?? 0.0)
          .toList();

      // Chama a matemática pura
      ResultadoSimplex res = SimplexSolver.resolver(C, A, b);

      // Formata o resultado
      if (res.sucesso) {
        String vars = "";
        for (int i = 0; i < res.variaveis.length; i++) {
          vars += "• x${i + 1}: ${res.variaveis[i].toStringAsFixed(2)}\n";
        }
        return "LUCRO MÁXIMO (Z): ${res.z.toStringAsFixed(2)}\n\nValores ótimos:\n$vars";
      } else {
        return "Sem solução ótima encontrada.";
      }
    } catch (e) {
      return "Erro nos dados. Verifique se digitou apenas números.";
    }
  }

  // Limpa a memória (Dispose)
  void dispose() {
    for (var c in zControllers) c.dispose();
    for (var list in restricoesControllers) {
      for (var c in list) c.dispose();
    }
    for (var c in bControllers) c.dispose();
  }
}
