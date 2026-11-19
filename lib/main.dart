import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'aquario_logic.dart';
import 'cortecloud_export.dart';
import 'download.dart';

void main() => runApp(const AppAquario());

class AppAquario extends StatelessWidget {
  const AppAquario({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Configurador Alex Pro',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
  final _formKey = GlobalKey<FormState>();
  double precoRoloFita = 40;
  double precoChapaBranca = 350;
  double precoCorte = 2.50;
  double precoAplicacaoFita = 2.50;
  double fatorCorte = 1.9;
  static const precoDobComum = 3.00;
  static const precoDobCantoCego = 12.50;

  double comprimento = 1000;
  double largura = 400;
  double altura = 890;
  int qtdPortas = 3;
  int espessuraMDF = 15;
  bool temTampa = true;
  bool temPrateleira = true;
  bool portinhaMenor = true;

  List<Peca> get pecas => gerarPecas(
        comprimento: comprimento,
        largura: largura,
        altura: altura,
        qtdPortas: qtdPortas,
        espessuraMDF: espessuraMDF,
        temTampa: temTampa,
        temPrateleira: temPrateleira,
        portinhaMenor: portinhaMenor,
      );

  Movel get movelAtual => Movel(
        'Aquário ${_medida(comprimento)}x${_medida(largura)}x${_medida(altura)} mm',
        pecas,
        qtdPortas,
        temTampa,
        espessuraMDF: espessuraMDF,
      );

  String _medida(double valor) => valor == valor.roundToDouble()
      ? valor.toInt().toString()
      : valor.toString();

  double? _numero(String texto) => double.tryParse(texto.replaceAll(',', '.'));

  bool _validarExportacao() => _formKey.currentState!.validate();

  void _exportarExcel() {
    if (!_validarExportacao()) return;
    try {
      baixarExcel(planilhaCortecloud([movelAtual]));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Não foi possível baixar a planilha. Tente copiar as peças.'),
      ));
    }
  }

  Future<void> _copiarParaCortecloud() async {
    if (!_validarExportacao()) return;
    try {
      await Clipboard.setData(
        ClipboardData(text: textoCortecloud([movelAtual])),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Peças copiadas. No Cortecloud, use Importar peças > '
            'Colar dados da planilha ou Excel e vincule as chapas e fitas.'),
      ));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Não foi possível copiar. Baixe a planilha Excel e '
            'copie as linhas de peças, sem o cabeçalho.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurador Alex Pro')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: LayoutBuilder(builder: (context, constraints) {
            final configuracao = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildConfigPanel(),
                const SizedBox(height: 16),
                _buildPecas(),
              ],
            );
            if (constraints.maxWidth < 1000) {
              return SingleChildScrollView(
                key: const ValueKey('layout-mobile'),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    configuracao,
                    const SizedBox(height: 16),
                    _buildFinancialSummary(),
                  ],
                ),
              );
            }
            return Row(
              key: const ValueKey('layout-desktop'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: configuracao,
                  ),
                ),
                SizedBox(
                  width: 380,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                    child: _buildFinancialSummary(),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildConfigPanel() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Medidas do móvel',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
                'Informe as medidas em milímetros. O orçamento é atualizado automaticamente.'),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, constraints) {
              final campos = [
                _campoMedida('Comprimento (mm)', comprimento, 300,
                    (v) => comprimento = v),
                _campoMedida('Largura (mm)', largura, 150, (v) => largura = v),
                _campoMedida('Altura (mm)', altura, 271, (v) => altura = v),
              ];
              if (constraints.maxWidth < 560) {
                return Column(
                  children: [
                    for (final campo in campos)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: campo,
                      ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < campos.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: campos[i]),
                  ],
                ],
              );
            }),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: qtdPortas,
                    decoration: const InputDecoration(labelText: 'Portas'),
                    isExpanded: true,
                    items: [1, 2, 3]
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text('$e')))
                        .toList(),
                    onChanged: (v) => setState(() => qtdPortas = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: espessuraMDF,
                    decoration: const InputDecoration(labelText: 'MDF'),
                    isExpanded: true,
                    items: [15, 18]
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text('$e mm')))
                        .toList(),
                    onChanged: (v) => setState(() => espessuraMDF = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tampa'),
              value: temTampa,
              onChanged: (v) => setState(() => temTampa = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Prateleira'),
              value: temPrateleira,
              onChanged: (v) => setState(() => temPrateleira = v),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Portinha menor (248 mm)'),
              value: portinhaMenor && qtdPortas == 3,
              onChanged: qtdPortas == 3
                  ? (v) => setState(() => portinhaMenor = v!)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoMedida(String label, double valor, double minimo,
      ValueChanged<double> atualizar) {
    return TextFormField(
      key: ValueKey(label),
      initialValue: _medida(valor),
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (v) {
        final numero = _numero(v ?? '');
        if (numero == null || !numero.isFinite || numero < minimo) {
          return 'Mínimo: ${_medida(minimo)} mm';
        }
        return null;
      },
      onChanged: (v) {
        final numero = _numero(v);
        if (numero != null && numero.isFinite && numero >= minimo) {
          setState(() => atualizar(numero));
        }
      },
    );
  }

  Widget _buildPecas() {
    final lista = pecas;
    final quantidade = lista.fold<int>(0, (total, p) => total + p.qtd);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Peças do móvel',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('$quantidade peças • MDF branco'),
            const SizedBox(height: 12),
            for (final p in lista)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.nome,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                        '${_medida(p.comp)} × ${_medida(p.larg)} mm • ${p.qtd} un • '
                        '${p.tipo == TipoMDF.fundo3mm ? 3 : espessuraMDF} mm'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    final movel = movelAtual;
    double area = 0, fitaM = 0;
    int pTotal = 0;
    for (final p in movel.pecas) {
      pTotal += p.qtd;
      fitaM += p.metrosFita;
      if (p.tipo == TipoMDF.branco) area += p.areaM2;
    }
    final chapas = (area / 4.5).ceil();
    final rolos = (fitaM / 20).ceil();
    final cortes = (pTotal * fatorCorte).ceil();
    final ferragens =
        (movel.dobradicaReta + movel.dobradicaCurva) * precoDobComum +
            movel.dobradicaCantoCego * precoDobCantoCego;
    final custoAplicacao = fitaM * precoAplicacaoFita;
    final custoRolos = rolos * precoRoloFita;
    final total = chapas * precoChapaBranca +
        custoRolos +
        cortes * precoCorte +
        custoAplicacao +
        ferragens;

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Orçamento do móvel',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _resRow('TOTAL DO ORÇAMENTO', _moeda(total), destaque: true),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _exportarExcel,
              icon: const Icon(Icons.download),
              label: const Text('Baixar planilha Excel (.xlsx)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _copiarParaCortecloud,
              icon: const Icon(Icons.content_copy),
              label: const Text('Copiar para o Cortecloud'),
            ),
            const Divider(height: 32),
            const Text('AJUSTE DE PREÇOS',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _editRow('Chapa branca', precoChapaBranca,
                (v) => setState(() => precoChapaBranca = v)),
            _editRow('Rolo de fita (20 m)', precoRoloFita,
                (v) => setState(() => precoRoloFita = v)),
            _editRow('Aplicação de fita (m)', precoAplicacaoFita,
                (v) => setState(() => precoAplicacaoFita = v)),
            _editRow('Corte (un)', precoCorte,
                (v) => setState(() => precoCorte = v)),
            _editRow('Fator de corte', fatorCorte,
                (v) => setState(() => fatorCorte = v)),
            const Divider(height: 32),
            const Text('CÁLCULO DE MATERIAIS',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _resRow('Quantidade de peças', '$pTotal'),
            _resRow('Área de MDF branco', '${area.toStringAsFixed(2)} m²'),
            _resRow('Chapas brancas (4,5 m²)', '$chapas'),
            const Text(
                'Estimativa por área, sem plano de corte. Fundo de 3 mm não incluído no custo das chapas.',
                style: TextStyle(fontSize: 14)),
            const Divider(height: 24),
            _resRow('Metragem de fita', '${fitaM.toStringAsFixed(1)} m'),
            _resRow('Rolos necessários', '$rolos'),
            _resRow('Custo dos rolos', _moeda(custoRolos)),
            _resRow('Aplicação de fita', _moeda(custoAplicacao)),
            _resRow('Serviço de cortes ($cortes)', _moeda(cortes * precoCorte)),
            _resRow('Ferragens', _moeda(ferragens)),
          ],
        ),
      ),
    );
  }

  String _moeda(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  Widget _editRow(String label, double valor, ValueChanged<double> atualizar) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        key: ValueKey('preco-$label'),
        initialValue: valor.toString().replaceAll('.', ','),
        decoration: InputDecoration(labelText: label),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (v) {
          final numero = _numero(v ?? '');
          return numero == null || !numero.isFinite || numero < 0
              ? 'Informe um valor válido (zero ou maior).'
              : null;
        },
        onChanged: (v) {
          final numero = _numero(v);
          if (numero != null && numero.isFinite && numero >= 0)
            atualizar(numero);
        },
      ),
    );
  }

  Widget _resRow(String label, String valor, {bool destaque = false}) {
    final estilo = TextStyle(
      fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
      fontSize: destaque ? 18 : 16,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 4,
        children: [Text(label, style: estilo), Text(valor, style: estilo)],
      ),
    );
  }
}
