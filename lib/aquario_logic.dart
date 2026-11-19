enum TipoMDF { branco, fundo3mm }

class Peca {
  final String nome;
  final double comp;
  final double larg;
  final int qtd;
  final List<String> bordas;
  final TipoMDF tipo;

  Peca(
      {required this.nome,
      required this.comp,
      required this.larg,
      required this.qtd,
      required this.bordas,
      required this.tipo});

  double get areaM2 => (comp / 1000) * (larg / 1000) * qtd;

  double get metrosFita {
    double total = 0;
    if (bordas[0] == "0.4") total += (comp / 1000) * qtd;
    if (bordas[1] == "0.4") total += (comp / 1000) * qtd;
    if (bordas[2] == "0.4") total += (larg / 1000) * qtd;
    if (bordas[3] == "0.4") total += (larg / 1000) * qtd;
    return total;
  }
}

class Movel {
  final String nome;
  final List<Peca> pecas;
  final int portas;
  final bool temTampa;
  final int espessuraMDF;
  Movel(this.nome, this.pecas, this.portas, this.temTampa,
      {this.espessuraMDF = 15});

  int get dobradicaReta => (portas == 3) ? 4 : (portas * 2);
  int get dobradicaCurva => (portas == 3) ? 2 : 0;
  int get dobradicaCantoCego => temTampa ? 2 : 0;
}

List<Peca> gerarPecas({
  double comprimento = 1000,
  double largura = 400,
  double altura = 890,
  int qtdPortas = 3,
  int espessuraMDF = 15,
  bool temTampa = true,
  bool temPrateleira = true,
  bool portinhaMenor = true,
}) {
  List<Peca> pecas = [];
  double adjC = espessuraMDF == 18 ? 6.0 : 0.0;
  double adjR = espessuraMDF == 18 ? -6.0 : 0.0;
  double adjL = espessuraMDF == 18 ? 3.0 : 0.0;

  void addP(String n, double c, double l, int q, List<String> b, {TipoMDF? t}) {
    if (q <= 0) return;
    pecas.add(Peca(
        nome: n,
        comp: c,
        larg: l,
        qtd: q,
        bordas: b,
        tipo: t ?? TipoMDF.branco));
  }

  // --- LÓGICA DA TAMPA ---
  if (temTampa) {
    addP("Trava tampa", largura - 30, 120, 1, ["0.4", "0.4", "0.4", "0"]);
    addP("Tampa Lateral", largura + 7, 120, 2, ["0.4", "0.4", "0.4", "0.4"]);
    addP("Tampa Superior A", comprimento + 35 + adjC, 120, 1,
        ["0.4", "0.4", "0.4", "0.4"]);
    addP("Tampa Superior B", comprimento + 35 + adjC, 135, 1,
        ["0.4", "0.4", "0.4", "0.4"]);
    addP("Tampa Superior C", comprimento + 35 + adjC,
        (largura - 115).clamp(0, 600), 1, ["0.4", "0.4", "0.4", "0.4"]);
  }

  // --- LÓGICA DO RODAPÉ ---
  int qtdRef = comprimento >= 1000 ? (comprimento - 500) ~/ 500 : 0;
  addP("Rodapé Interno", comprimento - 26 + adjR, 100, 1,
      ["0.4", "0", "0", "0"]);
  addP("Rodapé Lateral", largura - 25 + adjR, 100, 2, ["0.4", "0", "0", "0"]);
  addP("Rodapé Externo", comprimento + 5, 100, 2, ["0.4", "0", "0", "0"]);
  addP(
      "Rodapé Reforço Sump", largura - 40, 100, qtdRef, ["0.4", "0", "0", "0"]);

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
    if (cP > 0) addP("Prateleira", cP + adjR, lP, 1, ["0.4", "0", "0", "0"]);
  }

  // --- ESTRUTURA ---
  addP("Coluna Interna", altura - 155, largura + 2, (qtdPortas >= 3 ? 3 : 2),
      ["0.4", "0", "0", "0"]);
  addP("Lateral Externa", altura, largura + 20 + adjL, 2,
      ["0.4", "0.4", "0.4", "0.4"]);
  addP(
      "Base Superior", comprimento + 5, largura + 2, 1, ["0.4", "0", "0", "0"]);
  addP("Base Inferior", comprimento + 5, largura + 20 + adjL, 1,
      ["0.4", "0.4", "0", "0"]);
  addP("Trava Estrutural", comprimento - 25 - adjC, 140, 1,
      ["0.4", "0", "0", "0"]);
  addP("Testeira", 120, comprimento + 6, 1, ["0", "0", "0.4", "0.4"]);
  addP("Fundo (3mm)", comprimento + 25, 850, 1, ["0", "0", "0", "0"],
      t: TipoMDF.fundo3mm);

  // --- PORTAS ---
  bool usarP = portinhaMenor && qtdPortas == 3;
  if (usarP) {
    addP("Porta Cava (Menor)", altura - 270, 248, 1,
        ["0.4", "0.4", "0.4", "0.4"]);
    double lp = (comprimento + 5 - 248 - (qtdPortas + 1) * 4) / (qtdPortas - 1);
    addP("Porta Cava (Principal)", altura - 270, lp.ceilToDouble(),
        qtdPortas - 1, ["0.4", "0.4", "0.4", "0.4"]);
  } else {
    double lp = (qtdPortas == 1)
        ? comprimento - 1
        : (qtdPortas == 2)
            ? (comprimento - 4) / 2
            : (comprimento + 5 - (qtdPortas + 1) * 4) / qtdPortas;
    addP("Porta Cava", altura - 270, lp.ceilToDouble(), qtdPortas,
        ["0.4", "0.4", "0.4", "0.4"]);
  }
  return pecas;
}
