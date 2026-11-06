enum TipoMDF { branco, colorido, fundo3mm }

class Peca {
  final String nome;
  final double comp;
  final double larg;
  final int qtd;
  final List<String> bordas;
  TipoMDF tipo;

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
