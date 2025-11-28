// Lógica pura do Simplex
class ResultadoSimplex {
  final bool sucesso;
  final double z;
  final List<double> variaveis;
  ResultadoSimplex(this.sucesso, this.z, this.variaveis);
}

class SimplexSolver {
  static ResultadoSimplex resolver(
    List<double> C,
    List<List<double>> A,
    List<double> b,
  ) {
    int numVars = C.length;
    int numRestricoes = b.length;

    int numCols = numVars + numRestricoes + 1;
    List<List<double>> tabela = List.generate(
      numRestricoes + 1,
      (_) => List.filled(numCols, 0.0),
    );

    // Preencher restrições
    for (int i = 0; i < numRestricoes; i++) {
      for (int j = 0; j < numVars; j++) {
        tabela[i][j] = A[i][j];
      }
      tabela[i][numVars + i] = 1.0;
      tabela[i][numCols - 1] = b[i];
    }

    // Preencher Z
    for (int j = 0; j < numVars; j++) {
      tabela[numRestricoes][j] = -C[j];
    }

    // Iterações
    while (true) {
      double minVal = 0;
      int colPivo = -1;
      for (int j = 0; j < numCols - 1; j++) {
        if (tabela[numRestricoes][j] < minVal) {
          minVal = tabela[numRestricoes][j];
          colPivo = j;
        }
      }

      if (colPivo == -1) break;

      double menorRazao = double.infinity;
      int linhaPivo = -1;

      for (int i = 0; i < numRestricoes; i++) {
        double valorColPivo = tabela[i][colPivo];
        if (valorColPivo > 0) {
          double razao = tabela[i][numCols - 1] / valorColPivo;
          if (razao < menorRazao) {
            menorRazao = razao;
            linhaPivo = i;
          }
        }
      }

      if (linhaPivo == -1) return ResultadoSimplex(false, 0, []);

      double elementoPivo = tabela[linhaPivo][colPivo];
      for (int j = 0; j < numCols; j++) {
        tabela[linhaPivo][j] /= elementoPivo;
      }

      for (int i = 0; i <= numRestricoes; i++) {
        if (i != linhaPivo) {
          double fator = tabela[i][colPivo];
          for (int j = 0; j < numCols; j++) {
            tabela[i][j] -= fator * tabela[linhaPivo][j];
          }
        }
      }
    }

    List<double> varsResult = List.filled(numVars, 0.0);
    for (int j = 0; j < numVars; j++) {
      int count1 = 0;
      int indexRow = -1;
      for (int i = 0; i < numRestricoes; i++) {
        if ((tabela[i][j] - 1.0).abs() < 1e-6) {
          count1++;
          indexRow = i;
        } else if (tabela[i][j].abs() > 1e-6) {
          count1 = -1;
          break;
        }
      }
      if (count1 == 1 && indexRow != -1) {
        varsResult[j] = tabela[indexRow][numCols - 1];
      }
    }

    return ResultadoSimplex(
      true,
      tabela[numRestricoes][numCols - 1],
      varsResult,
    );
  }
}
