import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gerador_de_pecas_corte_cloud/aquario_logic.dart';
import 'package:gerador_de_pecas_corte_cloud/cortecloud_export.dart';

Peca peca({TipoMDF tipo = TipoMDF.branco, String nome = 'Rodapé Interno'}) =>
    Peca(
        nome: nome,
        comp: 1174,
        larg: 100.5,
        qtd: 2,
        bordas: ['0.4', '0', '0.4', '0'],
        tipo: tipo);

void main() {
  test('segue as 11 colunas do modelo e deixa lados sem fita vazios', () {
    expect(cortecloudColunas, [
      'Quantidade',
      'Comprimento',
      'Largura',
      'Função',
      'Fita C1',
      'Fita C2',
      'Fita L1',
      'Fita L2',
      'Material',
      'Complemento',
      'Girar',
    ]);
    final linhas = linhasCortecloud([
      Movel('Aquário 1200x400', [peca()], 3, false)
    ]);
    expect(linhas.single, [
      2,
      1174.0,
      100.5,
      'Rodapé Interno',
      'Branco 0.4',
      '',
      'Branco 0.4',
      '',
      'MDF 15 mm Branco',
      'Aquário 1200x400',
      '',
    ]);
  });

  test('preserva a espessura de cada móvel e o fundo de 3 mm', () {
    final linhas = linhasCortecloud([
      Movel('Móvel 15', [peca()], 3, true, espessuraMDF: 15),
      Movel('Móvel 18', [peca(tipo: TipoMDF.colorido)], 3, true,
          espessuraMDF: 18),
      Movel('Fundo', [peca(tipo: TipoMDF.fundo3mm)], 3, true, espessuraMDF: 18),
    ]);
    expect(linhas.map((linha) => linha[8]), [
      'MDF 15 mm Branco',
      'MDF 18 mm Colorido',
      'MDF 3mm Branco',
    ]);
    expect(linhas[1][4], 'Colorido 0.4');
  });

  test('texto para colar contém só peças, tabulações e 11 campos por linha',
      () {
    final texto = textoCortecloud([
      Movel('Aquário\tA\nB', [peca(), peca()], 3, true),
    ]);
    final linhas = texto.split('\r\n');
    expect(linhas, hasLength(2));
    expect(linhas.every((linha) => linha.split('\t').length == 11), isTrue);
    expect(linhas.first.startsWith('2\t1174.0\t100.5\t'), isTrue);
    expect(texto, isNot(contains('Quantidade')));
    expect(linhas.first.split('\t')[9], 'Aquário A B');
  });

  test('gera XLSX com strings XML escapadas e medidas numéricas', () {
    final bytes = planilhaCortecloud([
      Movel('Aquário & "A"', [peca(nome: '<Lateral>')], 3, true),
    ]);
    expect(bytes.take(4), [0x50, 0x4b, 0x03, 0x04]);
    // O ZIP não é comprimido; o XML pode ser inspecionado diretamente.
    final conteudo = utf8.decode(bytes, allowMalformed: true);
    expect(conteudo, contains('Aquário &amp; &quot;A&quot;'));
    expect(conteudo, contains('&lt;Lateral&gt;'));
    expect(conteudo, contains('<c r="A2"><v>2</v></c>'));
    expect(conteudo, contains('<c r="C2"><v>100.5</v></c>'));
    expect(conteudo, contains('ref="A1:K2"'));
    expect(() => planilhaCortecloud([]), returnsNormally);
  });
}
