import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gerador_de_pecas_corte_cloud/aquario_logic.dart';
import 'package:gerador_de_pecas_corte_cloud/cortecloud_export.dart';

void main() {
  test('altura padrão mantém as medidas originais', () {
    final pecas = gerarPecas();
    expect(pecas.singleWhere((p) => p.nome == 'Coluna Interna').comp, 735);
    expect(pecas.singleWhere((p) => p.nome == 'Lateral Externa').comp, 890);
    expect(
        pecas
            .where((p) => p.nome.startsWith('Porta Cava'))
            .every((p) => p.comp == 620),
        isTrue);
  });

  for (final altura in [750.0, 1000.0, 1200.5]) {
    for (final espessura in [15, 18]) {
      for (final portas in [1, 2, 3]) {
        for (final portinha in [true, false]) {
          test(
              'altura $altura, MDF $espessura, $portas portas, menor $portinha',
              () {
            final pecas = gerarPecas(
                altura: altura,
                espessuraMDF: espessura,
                qtdPortas: portas,
                portinhaMenor: portinha);
            expect(pecas.singleWhere((p) => p.nome == 'Coluna Interna').comp,
                altura - 155);
            expect(pecas.singleWhere((p) => p.nome == 'Lateral Externa').comp,
                altura);
            final listaPortas =
                pecas.where((p) => p.nome.startsWith('Porta Cava'));
            expect(listaPortas.every((p) => p.comp == altura - 270), isTrue);
            expect(listaPortas.fold<int>(0, (s, p) => s + p.qtd), portas);
            expect(
                pecas
                    .where((p) => p.nome != 'Fundo (3mm)')
                    .every((p) => p.tipo == TipoMDF.branco),
                isTrue);
            expect(pecas.singleWhere((p) => p.nome == 'Fundo (3mm)').tipo,
                TipoMDF.fundo3mm);
            expect(pecas.every((p) => p.comp > 0 && p.larg > 0 && p.qtd > 0),
                isTrue);
          });
        }
      }
    }
  }

  test(
      'altura altera só as peças solicitadas e exporta medidas atuais em branco',
      () {
    final originais = gerarPecas();
    final novas = gerarPecas(altura: 1000);
    for (var i = 0; i < novas.length; i++) {
      if (novas[i].nome == 'Coluna Interna' ||
          novas[i].nome == 'Lateral Externa' ||
          novas[i].nome.startsWith('Porta Cava')) {
        expect(novas[i].comp - originais[i].comp, 110);
      } else {
        expect(novas[i].comp, originais[i].comp);
      }
      expect(novas[i].larg, originais[i].larg);
      expect(novas[i].qtd, originais[i].qtd);
    }
    final movel =
        Movel('Aquário 1000x400x1000 mm', novas, 3, true, espessuraMDF: 18);
    final linhas = linhasCortecloud([movel]);
    expect(
        linhas.every(
            (l) => l[8] == 'MDF 18 mm Branco' || l[8] == 'MDF 3mm Branco'),
        isTrue);
    expect(linhas.singleWhere((l) => l[3] == 'Coluna Interna')[1], 845);
    final xml = utf8.decode(planilhaCortecloud([movel]), allowMalformed: true);
    expect(xml, contains('MDF 18 mm Branco'));
    expect(xml, isNot(contains('Colorido')));
  });

  test('opções de tampa e prateleira continuam funcionando', () {
    final pecas = gerarPecas(temTampa: false, temPrateleira: false);
    expect(pecas.any((p) => p.nome.toLowerCase().contains('tampa')), isFalse);
    expect(pecas.any((p) => p.nome == 'Prateleira'), isFalse);
    expect(Movel('Móvel', pecas, 2, false).dobradicaCantoCego, 0);
  });
}
