import 'package:flutter/material.dart';

void main() {
  runApp(const SimplexApp());
}

class SimplexApp extends StatelessWidget {
  const SimplexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simplex Dinâmico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const SimplexScreen(),
    );
  }
}

class SimplexScreen extends StatefulWidget {
  const SimplexScreen({super.key});

  @override
  State<SimplexScreen> createState() => _SimplexScreenState();
}

class _SimplexScreenState extends State<SimplexScreen> {
  // --- ESTADO DA APLICAÇÃO ---
  bool _configurado = false;
  int _numVariaveis = 2; // Valor padrão
  int _numRestricoes = 3; // Valor padrão

  // Controladores Dinâmicos
  // Para Z: coeficientes da função objetivo
  List<TextEditingController> _zControllers = [];

  // Para as Restrições: Matriz de coeficientes [Restrição][Variavel]
  List<List<TextEditingController>> _restricoesControllers = [];

  // Para os limites (Lado direito das restrições: b)
  List<TextEditingController> _bControllers = [];

  String _resultado = "";

  // --- PASSO 1: CONFIGURAÇÃO INICIAL ---
  void _gerarCampos() {
    // Limpa controladores antigos se houver
    _zControllers.clear();
    _restricoesControllers.clear();
    _bControllers.clear();

    // 1. Gera controladores para Função Objetivo (c1, c2, c3...)
    for (int i = 0; i < _numVariaveis; i++) {
      _zControllers.add(TextEditingController());
    }

    // 2. Gera controladores para Restrições
    for (int i = 0; i < _numRestricoes; i++) {
      List<TextEditingController> linha = [];
      for (int j = 0; j < _numVariaveis; j++) {
        linha.add(TextEditingController());
      }
      _restricoesControllers.add(linha);
      _bControllers.add(TextEditingController()); // O valor 'b' da restrição
    }

    setState(() {
      _configurado = true;
      _resultado = "";
    });
  }

  void _resetar() {
    setState(() {
      _configurado = false;
      _resultado = "";
    });
  }

  // --- PASSO 2: CALCULAR (Solver Simplex Simples) ---
  void _calcularSimplex() {
    try {
      // 1. Extrair dados dos controladores
      List<double> C = _zControllers
          .map((c) => double.tryParse(c.text) ?? 0.0)
          .toList();

      List<List<double>> A = [];
      for (var linha in _restricoesControllers) {
        A.add(linha.map((c) => double.tryParse(c.text) ?? 0.0).toList());
      }

      List<double> b = _bControllers
          .map((c) => double.tryParse(c.text) ?? 0.0)
          .toList();

      // 2. Executar Algoritmo Simplex
      ResultadoSimplex res = SimplexSolver.resolver(C, A, b);

      // 3. Exibir
      setState(() {
        if (res.sucesso) {
          String vars = "";
          for (int i = 0; i < res.variaveis.length; i++) {
            vars += "• x${i + 1}: ${res.variaveis[i].toStringAsFixed(2)}\n";
          }
          _resultado =
              "LUCRO MÁXIMO (Z): ${res.z.toStringAsFixed(2)}\n\nValores ótimos:\n$vars";
        } else {
          _resultado =
              "Não foi possível encontrar solução ótima (Ilimitado ou Impossível).";
        }
      });
    } catch (e) {
      setState(() {
        _resultado = "Erro nos dados. Verifique os números.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Simplex Dinâmico"),
        actions: [
          if (_configurado)
            IconButton(onPressed: _resetar, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _configurado ? _buildFormulario() : _buildConfiguracao(),
    );
  }

  // --- TELA 1: CONFIGURAÇÃO ---
  Widget _buildConfiguracao() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Configurar Problema",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text("Quantidade de Variáveis de Decisão (n): $_numVariaveis"),
              Slider(
                value: _numVariaveis.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: _numVariaveis.toString(),
                onChanged: (v) => setState(() => _numVariaveis = v.toInt()),
              ),
              const SizedBox(height: 10),
              Text("Quantidade de Restrições (m): $_numRestricoes"),
              Slider(
                value: _numRestricoes.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: _numRestricoes.toString(),
                onChanged: (v) => setState(() => _numRestricoes = v.toInt()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _gerarCampos,
                child: const Text("GERAR CAMPOS"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TELA 2: FORMULÁRIO ---
  Widget _buildFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "1. Função Objetivo (Max Z)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          // Gera os campos de Z dinamicamente
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_numVariaveis, (index) {
              return SizedBox(
                width: 100,
                child: TextField(
                  controller: _zControllers[index],
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
          const Text(
            "2. Restrições (≤)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          // Gera as linhas de restrição
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _numRestricoes,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...List.generate(_numVariaveis, (j) {
                              return Container(
                                width: 80,
                                margin: const EdgeInsets.only(right: 5),
                                child: TextField(
                                  controller: _restricoesControllers[i][j],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "x${j + 1}",
                                    contentPadding: const EdgeInsets.symmetric(
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
                                controller: _bControllers[i],
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
          Center(
            child: ElevatedButton.icon(
              onPressed: _calcularSimplex,
              icon: const Icon(Icons.calculate),
              label: const Text("CALCULAR OTIMIZAÇÃO"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),
          ),
          if (_resultado.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              color: Colors.green[100],
              child: Text(
                _resultado,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// --- CLASSE AUXILIAR: SOLVER SIMPLEX (Lógica Matemática) ---
class ResultadoSimplex {
  final bool sucesso;
  final double z;
  final List<double> variaveis;
  ResultadoSimplex(this.sucesso, this.z, this.variaveis);
}

class SimplexSolver {
  // Implementação simplificada do Simplex Tabular (Maximização com restrições <=)
  static ResultadoSimplex resolver(
    List<double> C,
    List<List<double>> A,
    List<double> b,
  ) {
    int numVars = C.length;
    int numRestricoes = b.length;

    // Montar Tabela Simplex (Tableau)
    // Linhas = numRestricoes + 1 (Função Z)
    // Colunas = numVars + numRestricoes (Folgas) + 1 (b)
    int numCols = numVars + numRestricoes + 1;
    List<List<double>> tabela = List.generate(
      numRestricoes + 1,
      (_) => List.filled(numCols, 0.0),
    );

    // Preencher restrições e variáveis de folga
    for (int i = 0; i < numRestricoes; i++) {
      for (int j = 0; j < numVars; j++) {
        tabela[i][j] = A[i][j];
      }
      tabela[i][numVars + i] = 1.0; // Variável de folga
      tabela[i][numCols - 1] = b[i]; // Lado direito (b)
    }

    // Preencher linha Z (Invertendo sinais para maximização na forma padrão)
    for (int j = 0; j < numVars; j++) {
      tabela[numRestricoes][j] = -C[j];
    }

    // --- ITERAÇÕES DO SIMPLEX ---
    while (true) {
      // 1. Encontrar Coluna Pivô (Menor valor negativo na linha Z)
      double minVal = 0;
      int colPivo = -1;
      for (int j = 0; j < numCols - 1; j++) {
        if (tabela[numRestricoes][j] < minVal) {
          minVal = tabela[numRestricoes][j];
          colPivo = j;
        }
      }

      if (colPivo == -1) break; // Ótimo encontrado (não há negativos em Z)

      // 2. Encontrar Linha Pivô (Teste da Razão)
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

      if (linhaPivo == -1)
        return ResultadoSimplex(false, 0, []); // Problema Ilimitado

      // 3. Pivoteamento
      double elementoPivo = tabela[linhaPivo][colPivo];

      // Dividir linha pivô pelo elemento pivô
      for (int j = 0; j < numCols; j++) {
        tabela[linhaPivo][j] /= elementoPivo;
      }

      // Zerar a coluna nas outras linhas
      for (int i = 0; i <= numRestricoes; i++) {
        if (i != linhaPivo) {
          double fator = tabela[i][colPivo];
          for (int j = 0; j < numCols; j++) {
            tabela[i][j] -= fator * tabela[linhaPivo][j];
          }
        }
      }
    }

    // Extrair Solução
    List<double> varsResult = List.filled(numVars, 0.0);
    // Identificar variáveis básicas
    for (int j = 0; j < numVars; j++) {
      int count1 = 0;
      int indexRow = -1;
      for (int i = 0; i < numRestricoes; i++) {
        if ((tabela[i][j] - 1.0).abs() < 1e-6) {
          count1++;
          indexRow = i;
        } else if (tabela[i][j].abs() > 1e-6) {
          count1 = -1; // Não é coluna identidade limpa
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
