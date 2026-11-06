import 'dart:convert';
import 'dart:typed_data';

import 'aquario_logic.dart';

/// Mesma ordem das colunas do modelo de importação do Cortecloud.
const cortecloudColunas = [
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
];

List<List<Object>> linhasCortecloud(List<Movel> moveis) {
  return [
    for (final movel in moveis)
      for (final peca in movel.pecas)
        [
          peca.qtd,
          peca.comp,
          peca.larg,
          peca.nome,
          for (final borda in peca.bordas)
            borda == '0' || borda.isEmpty
                ? ''
                : '${peca.tipo == TipoMDF.colorido ? 'Colorido' : 'Branco'} $borda',
          peca.tipo == TipoMDF.fundo3mm
              ? 'MDF 3mm Branco'
              : 'MDF ${movel.espessuraMDF} mm ${peca.tipo == TipoMDF.branco ? 'Branco' : 'Colorido'}',
          movel.nome,
          '', // Sem autorização para ignorar o veio do material.
        ],
  ];
}

/// O Cortecloud recebe somente as linhas de peças, sem o cabeçalho.
String textoCortecloud(List<Movel> moveis) => linhasCortecloud(moveis)
    .map((linha) => linha
        .map((valor) => valor.toString().replaceAll(RegExp(r'[\t\r\n]'), ' '))
        .join('\t'))
    .join('\r\n');

/// Planilha OOXML (.xlsx), com medidas e quantidades em células numéricas.
/// Usa ZIP sem compressão para não adicionar dependências ao aplicativo web.
Uint8List planilhaCortecloud(List<Movel> moveis) {
  final linhas = <List<Object>>[cortecloudColunas, ...linhasCortecloud(moveis)];
  final celulas = StringBuffer();
  for (var linha = 0; linha < linhas.length; linha++) {
    celulas.write('<row r="${linha + 1}">');
    for (var coluna = 0; coluna < linhas[linha].length; coluna++) {
      final valor = linhas[linha][coluna];
      final referencia = '${String.fromCharCode(65 + coluna)}${linha + 1}';
      if (valor is num) {
        if (!valor.isFinite)
          throw ArgumentError('Medida inválida na planilha.');
        celulas.write('<c r="$referencia"><v>$valor</v></c>');
      } else {
        celulas.write(
            '<c r="$referencia" t="inlineStr"${linha == 0 ? ' s="1"' : ''}>'
            '<is><t xml:space="preserve">${_xml(valor.toString())}</t></is></c>');
      }
    }
    celulas.write('</row>');
  }
  return _zip({
    '[Content_Types].xml':
        '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/><Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/></Types>''',
    '_rels/.rels': '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>''',
    'xl/workbook.xml':
        '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="Sheet1" sheetId="1" r:id="rId1"/></sheets></workbook>''',
    'xl/_rels/workbook.xml.rels':
        '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/></Relationships>''',
    'xl/styles.xml': '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><fonts count="2"><font><sz val="11"/><name val="Calibri"/></font><font><b/><sz val="11"/><name val="Calibri"/></font></fonts><fills count="2"><fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill></fills><borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders><cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs><cellXfs count="2"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/></cellXfs><cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles></styleSheet>''',
    'xl/worksheets/sheet1.xml':
        '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><dimension ref="A1:K${linhas.length}"/><sheetViews><sheetView workbookViewId="0"><pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/></sheetView></sheetViews><sheetFormatPr defaultRowHeight="15"/><cols><col min="1" max="3" width="15" customWidth="1"/><col min="4" max="4" width="28" customWidth="1"/><col min="5" max="8" width="18" customWidth="1"/><col min="9" max="10" width="28" customWidth="1"/><col min="11" max="11" width="10" customWidth="1"/></cols><sheetData>$celulas</sheetData><autoFilter ref="A1:K${linhas.length}"/></worksheet>''',
  });
}

String _xml(String texto) => texto
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;')
    .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');

Uint8List _zip(Map<String, String> arquivos) {
  final saida = BytesBuilder(copy: false);
  final diretorio = BytesBuilder(copy: false);
  for (final arquivo in arquivos.entries) {
    final nome = utf8.encode(arquivo.key);
    final dados = utf8.encode(arquivo.value);
    final crc = _crc32(dados);
    final posicao = saida.length;
    final local = ByteData(30)
      ..setUint32(0, 0x04034b50, Endian.little)
      ..setUint16(4, 20, Endian.little)
      ..setUint16(6, 0x0800, Endian.little)
      ..setUint16(12, 0x0021, Endian.little)
      ..setUint32(14, crc, Endian.little)
      ..setUint32(18, dados.length, Endian.little)
      ..setUint32(22, dados.length, Endian.little)
      ..setUint16(26, nome.length, Endian.little);
    saida
      ..add(local.buffer.asUint8List())
      ..add(nome)
      ..add(dados);
    final central = ByteData(46)
      ..setUint32(0, 0x02014b50, Endian.little)
      ..setUint16(4, 20, Endian.little)
      ..setUint16(6, 20, Endian.little)
      ..setUint16(8, 0x0800, Endian.little)
      ..setUint16(14, 0x0021, Endian.little)
      ..setUint32(16, crc, Endian.little)
      ..setUint32(20, dados.length, Endian.little)
      ..setUint32(24, dados.length, Endian.little)
      ..setUint16(28, nome.length, Endian.little)
      ..setUint32(42, posicao, Endian.little);
    diretorio
      ..add(central.buffer.asUint8List())
      ..add(nome);
  }
  final fim = ByteData(22)
    ..setUint32(0, 0x06054b50, Endian.little)
    ..setUint16(8, arquivos.length, Endian.little)
    ..setUint16(10, arquivos.length, Endian.little)
    ..setUint32(12, diretorio.length, Endian.little)
    ..setUint32(16, saida.length, Endian.little);
  saida
    ..add(diretorio.takeBytes())
    ..add(fim.buffer.asUint8List());
  return saida.takeBytes();
}

int _crc32(List<int> dados) {
  var crc = 0xffffffff;
  for (final byte in dados) {
    crc ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc >>> 1) ^ ((crc & 1) == 0 ? 0 : 0xedb88320);
    }
  }
  return (crc ^ 0xffffffff) & 0xffffffff;
}
