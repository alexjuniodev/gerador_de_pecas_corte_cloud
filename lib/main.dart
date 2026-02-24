import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web_dom;

import 'aquario_logic.dart';

void main() => runApp(const AppAquario());

class AppAquario extends StatelessWidget {
  const AppAquario({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Configurador Alex Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
      home: const CalculadoraMovel(),
    );
  }
}

class CalculadoraMovel extends StatefulWidget {
  const CalculadoraMovel({super.key});
  @override
  State<CalculadoraMovel> createState() => _CalculadoraMovelState();
}

class _CalculadoraMovelState extends State<CalculadoraMovel> {
  // --- CONFIGURAÇÕES DE PREÇO (EDITÁVEIS) ---
  double precoRoloFita = 40.0;
  double precoChapaBranca = 350.0;
  double precoChapaColorida = 550.0;
  double precoCorte = 2.50;
  double precoAplicacaoFita = 2.50;
  double fatorCorte = 1.9;

  // Preços fixos
  double precoDobComum = 3.00;
  double precoDobCantoCego = 12.50;

  // --- ESTADO DO MÓVEL ATUAL ---
  double comprimento = 1000;
  double largura = 400;
  int qtdPortas = 3;
  int espessuraMDF = 15;
  bool temTampa = true;
  bool temPrateleira = true;
  bool portinhaMenor = true; // AQUI ESTÁ ELA!
  bool internoBrancoPadrao = true;

  List<Peca> pecasEdicao = [];
  List<Movel> orcamentoTotal = [];

  @override
  void initState() {
    super.initState();
    _atualizarPecas();
  }

  void _atualizarPecas() {
    setState(() {
      pecasEdicao = _gerarPecasLogica();
    });
  }

  List<Peca> _gerarPecasLogica() {
    List<Peca> pecas = [];
    double adjC = espessuraMDF == 18 ? 6.0 : 0.0;
    double adjR = espessuraMDF == 18 ? -6.0 : 0.0;
    double adjL = espessuraMDF == 18 ? 3.0 : 0.0;
    TipoMDF tipoInt = internoBrancoPadrao ? TipoMDF.branco : TipoMDF.colorido;

    void addP(String n, double c, double l, int q, List<String> b,
        {TipoMDF? t}) {
      if (q <= 0) return;
      pecas.add(Peca(
          nome: n, comp: c, larg: l, qtd: q, bordas: b, tipo: t ?? tipoInt));
    }

    // --- LÓGICA DA TAMPA ---
    if (temTampa) {
      addP("Trava tampa", largura - 30, 120, 1, ["0.4", "0.4", "0.4", "0"],
          t: TipoMDF.colorido);
      addP("Tampa Lateral", largura + 7, 120, 2, ["0.4", "0.4", "0.4", "0.4"],
          t: TipoMDF.colorido);
      addP("Tampa Superior A", comprimento + 35 + adjC, 120, 1,
          ["0.4", "0.4", "0.4", "0.4"],
          t: TipoMDF.colorido);
      addP("Tampa Superior B", comprimento + 35 + adjC, 135, 1,
          ["0.4", "0.4", "0.4", "0.4"],
          t: TipoMDF.colorido);
      addP("Tampa Superior C", comprimento + 35 + adjC,
          (largura - 115).clamp(0, 600), 1, ["0.4", "0.4", "0.4", "0.4"],
          t: TipoMDF.colorido);
    }

    // --- LÓGICA DO RODAPÉ ---
    int qtdRef = comprimento >= 1000 ? (comprimento - 500) ~/ 500 : 0;
    addP("Rodapé Interno", comprimento - 26 + adjR, 100, 1,
        ["0.4", "0", "0", "0"],
        t: TipoMDF.colorido);
    addP("Rodapé Lateral", largura - 25 + adjR, 100, 2, ["0.4", "0", "0", "0"]);
    addP("Rodapé Externo", comprimento + 5, 100, 2, ["0.4", "0", "0", "0"],
        t: TipoMDF.colorido);
    addP("Rodapé Reforço Sump", largura - 40, 100, qtdRef,
        ["0.4", "0", "0", "0"]);

    // --- LÓGICA DA PRATELEIRA ---
    if (temPrateleira) {
      double cP = 0, lP = 0;
      bool usarPortinha = portinhaMenor && qtdPortas == 3;
      if (usarPortinha) {
        cP = 230;
        lP = 330;
      } else {
        cP = (qtdPortas <= 2) ? (comprimento - 25) : ((comprimento - 55) / 3);
        lP = largura - 70;
      }
      if (cP > 0)
        addP("Prateleira", cP + adjR, lP, 1, ["0.4", "0", "0", "0"],
            t: TipoMDF.colorido);
    }

    // --- ESTRUTURA ---
    addP("Coluna Interna", 735, largura + 2, (qtdPortas >= 3 ? 3 : 2),
        ["0.4", "0", "0", "0"]);
    addP("Lateral Externa", 890, largura + 20 + adjL, 2,
        ["0.4", "0.4", "0.4", "0.4"],
        t: TipoMDF.colorido);
    addP("Base Superior", comprimento + 5, largura + 2, 1,
        ["0.4", "0", "0", "0"],
        t: TipoMDF.colorido);
    addP("Base Inferior", comprimento + 5, largura + 20 + adjL, 1,
        ["0.4", "0.4", "0", "0"],
        t: TipoMDF.colorido);
    addP("Trava Estrutural", comprimento - 25 - adjC, 140, 1,
        ["0.4", "0", "0", "0"],
        t: TipoMDF.colorido);
    addP("Testeira", 120, comprimento + 6, 1, ["0", "0", "0.4", "0.4"],
        t: TipoMDF.colorido);
    addP("Fundo (3mm)", comprimento + 25, 850, 1, ["0", "0", "0", "0"],
        t: TipoMDF.fundo3mm);

    // --- PORTAS ---
    bool usarP = portinhaMenor && qtdPortas == 3;
    if (usarP) {
      addP("Porta Cava (Menor)", 620, 248, 1, ["0.4", "0.4", "0.4", "0.4"],
          t: TipoMDF.colorido);
      double lp =
          (comprimento + 5 - 248 - (qtdPortas + 1) * 4) / (qtdPortas - 1);
      addP("Porta Cava (Principal)", 620, lp.ceilToDouble(), qtdPortas - 1,
          ["0.4", "0.4", "0.4", "0.4"],
          t: TipoMDF.colorido);
    } else {
      double lp = (qtdPortas == 1)
          ? comprimento - 1
          : (qtdPortas == 2)
              ? (comprimento - 4) / 2
              : (comprimento + 5 - (qtdPortas + 1) * 4) / qtdPortas;
      addP("Porta Cava", 620, lp.ceilToDouble(), qtdPortas,
          ["0.4", "0.4", "0.4", "0.4"],
          t: TipoMDF.colorido);
    }
    return pecas;
  }

  void _exportarCSV() {
    String csv =
        "Móvel;Peça;MDF;Comprimento;Largura;Quantidade;FC1;FC2;FL1;FL2\n";
    for (var m in orcamentoTotal) {
      for (var p in m.pecas) {
        String mdf = p.tipo == TipoMDF.fundo3mm
            ? "MDF 3mm Branco"
            : (p.tipo == TipoMDF.branco
                ? "MDF $espessuraMDF mm Branco"
                : "MDF $espessuraMDF mm Colorido");
        csv +=
            "${m.nome};${p.nome};$mdf;${p.comp.toStringAsFixed(1)};${p.larg.toStringAsFixed(1)};${p.qtd};${p.bordas[0]};${p.bordas[1]};${p.bordas[2]};${p.bordas[3]}\n";
      }
    }
    final bytes = utf8.encode(csv);
    final blob = web_dom.Blob([Uint8List.fromList(bytes).toJS].toJS);
    final url = web_dom.URL.createObjectURL(blob);
    web_dom.document.createElement('a') as web_dom.HTMLAnchorElement
      ..href = url
      ..download = "CorteCloud_Alex.csv"
      ..click();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurador Alex Pro"),
        actions: [
          IconButton(
              icon: const Icon(Icons.cloud_download), onPressed: _exportarCSV)
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildConfigPanel(),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: pecasEdicao.length,
                    itemBuilder: (context, i) {
                      final p = pecasEdicao[i];
                      return ListTile(
                        dense: true,
                        title: Text(p.nome,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        subtitle: Text(
                            "${p.comp.toStringAsFixed(1)}x${p.larg.toStringAsFixed(1)} | ${p.qtd} un"),
                        trailing: p.tipo == TipoMDF.fundo3mm
                            ? const Text("3mm")
                            : DropdownButton<TipoMDF>(
                                value: p.tipo,
                                items: const [
                                  DropdownMenuItem(
                                      value: TipoMDF.branco,
                                      child: Text("Branco")),
                                  DropdownMenuItem(
                                      value: TipoMDF.colorido,
                                      child: Text("Color"))
                                ],
                                onChanged: (n) => setState(() => p.tipo = n!),
                              ),
                      );
                    },
                  ),
                ),
                _buildAddButton(),
              ],
            ),
          ),
          Container(
            width: 380,
            color: Colors.blueGrey[50],
            child: SingleChildScrollView(child: _buildFinancialSummary()),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigPanel() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(children: [
              Expanded(
                  child: TextField(
                      decoration: const InputDecoration(labelText: "Comp (mm)"),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        comprimento = double.tryParse(v) ?? 1000;
                        _atualizarPecas();
                      })),
              const SizedBox(width: 8),
              Expanded(
                  child: TextField(
                      decoration: const InputDecoration(labelText: "Larg (mm)"),
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        largura = double.tryParse(v) ?? 400;
                        _atualizarPecas();
                      })),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              DropdownButton<int>(
                  value: qtdPortas,
                  items: [1, 2, 3]
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text("$e Portas")))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      qtdPortas = v!;
                      _atualizarPecas();
                    });
                  }),
              DropdownButton<int>(
                  value: espessuraMDF,
                  items: [15, 18]
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text("${e}mm")))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      espessuraMDF = v!;
                      _atualizarPecas();
                    });
                  }),
              const Text("Tampa:"),
              Switch(
                  value: temTampa,
                  onChanged: (v) {
                    setState(() {
                      temTampa = v;
                      _atualizarPecas();
                    });
                  }),
              const Text("Prat:"),
              Switch(
                  value: temPrateleira,
                  onChanged: (v) {
                    setState(() {
                      temPrateleira = v;
                      _atualizarPecas();
                    });
                  }),
            ]),
            CheckboxListTile(
                title: const Text("Portinha Menor (248mm)?"),
                value: portinhaMenor && qtdPortas == 3,
                onChanged: qtdPortas == 3
                    ? (v) {
                        setState(() {
                          portinhaMenor = v!;
                          _atualizarPecas();
                        });
                      }
                    : null),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 45)),
        onPressed: () => setState(() => orcamentoTotal.add(Movel(
            "Aquário ${comprimento.toInt()}x${largura.toInt()}",
            List.from(pecasEdicao),
            qtdPortas,
            temTampa))),
        child: const Text("ADICIONAR MÓVEL AO ORÇAMENTO"),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    double aB = 0, aC = 0, fitaM = 0;
    int pTotal = 0, dR = 0, dCu = 0, dCe = 0;

    for (var m in orcamentoTotal) {
      dR += m.dobradicaReta;
      dCu += m.dobradicaCurva;
      dCe += m.dobradicaCantoCego;
      for (var p in m.pecas) {
        pTotal += p.qtd;
        fitaM += p.metrosFita;
        if (p.tipo == TipoMDF.branco) aB += p.areaM2;
        if (p.tipo == TipoMDF.colorido) aC += p.areaM2;
      }
    }

    int chB = (aB / 4.5).ceil();
    int chC = (aC / 4.5).ceil();
    int rolos = (fitaM / 20).ceil();
    int cortes = (pTotal * fatorCorte).ceil();

    double ferragens = (dR + dCu) * precoDobComum + (dCe * precoDobCantoCego);
    double custoAplicacao = fitaM * precoAplicacaoFita;
    double custoRolos = rolos * precoRoloFita;
    double total = (chB * precoChapaBranca) +
        (chC * precoChapaColorida) +
        custoRolos +
        (cortes * precoCorte) +
        custoAplicacao +
        ferragens;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("AJUSTE DE PREÇOS",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          _editRow("Chapa Branca", precoChapaBranca,
              (v) => setState(() => precoChapaBranca = v)),
          _editRow("Chapa Color", precoChapaColorida,
              (v) => setState(() => precoChapaColorida = v)),
          _editRow("Rolo Fita (20m)", precoRoloFita,
              (v) => setState(() => precoRoloFita = v)),
          _editRow("Aplicação (m)", precoAplicacaoFita,
              (v) => setState(() => precoAplicacaoFita = v)),
          _editRow(
              "Corte (un)", precoCorte, (v) => setState(() => precoCorte = v)),
          _editRow(
              "Fator Corte", fatorCorte, (v) => setState(() => fatorCorte = v)),
          const Divider(height: 30),
          const Text("CÁLCULO DE MATERIAIS",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          _resRow("Área Branco total", "${aB.toStringAsFixed(2)} m²"),
          _resRow("Chapas Brancas (4.5m²)", "x$chB"),
          _resRow("Área Color total", "${aC.toStringAsFixed(2)} m²"),
          _resRow("Chapas Color (4.5m²)", "x$chC"),
          const Divider(height: 20),
          _resRow("Metragem linear fita", "${fitaM.toStringAsFixed(1)} m"),
          _resRow("Rolos necessários", "x$rolos"),
          _resRow("Custo dos Rolos", "R\$ ${custoRolos.toStringAsFixed(2)}"),
          _resRow(
              "Custo Aplicação", "R\$ ${custoAplicacao.toStringAsFixed(2)}"),
          const Divider(height: 20),
          _resRow("Serviço Cortes ($cortes)",
              "R\$ ${(cortes * precoCorte).toStringAsFixed(2)}"),
          _resRow("Ferragens", "R\$ ${ferragens.toStringAsFixed(2)}"),
          const Divider(height: 30, thickness: 2),
          _resRow("TOTAL DO ORÇAMENTO", "R\$ ${total.toStringAsFixed(2)}",
              destaque: true),
          const SizedBox(height: 20),
          if (orcamentoTotal.isNotEmpty)
            Row(children: [
              TextButton(
                  onPressed: () => setState(() => orcamentoTotal.removeLast()),
                  child: const Text("Remover Último",
                      style: TextStyle(color: Colors.orange, fontSize: 11))),
              TextButton(
                  onPressed: () => setState(() => orcamentoTotal.clear()),
                  child: const Text("Limpar Tudo",
                      style: TextStyle(color: Colors.red, fontSize: 11))),
            ])
        ],
      ),
    );
  }

  Widget _editRow(String lab, double val, Function(double) onU) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Expanded(child: Text(lab, style: const TextStyle(fontSize: 10))),
        SizedBox(
            width: 60,
            height: 25,
            child: TextFormField(
              initialValue: val.toString(),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 11),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onFieldSubmitted: (v) => onU(double.tryParse(v) ?? 0),
            )),
      ]),
    );
  }

  Widget _resRow(String lab, String val, {bool destaque = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(lab,
          style: TextStyle(
              fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
              fontSize: destaque ? 14 : 11)),
      Text(val,
          style: TextStyle(
              fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
              fontSize: destaque ? 14 : 11,
              color: destaque ? Colors.green[800] : Colors.black)),
    ]);
  }
}
