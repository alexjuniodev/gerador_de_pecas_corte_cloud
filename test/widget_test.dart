import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerador_de_pecas_corte_cloud/main.dart';

void main() {
  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(844, 390),
    const Size(768, 1024),
    const Size(1024, 768),
    const Size(1440, 900),
  ]) {
    testWidgets('configuração e orçamento acessíveis em $size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const AppAquario());
      expect(tester.takeException(), isNull);
      expect(
          find.byKey(
              ValueKey(size.width < 1000 ? 'layout-mobile' : 'layout-desktop')),
          findsOneWidget);
      expect(find.text('TOTAL DO ORÇAMENTO'), findsOneWidget);
      expect(find.textContaining('ADICIONAR MÓVEL'), findsNothing);
      expect(find.text('Chapa Color'), findsNothing);
      expect(find.byType(DropdownButtonFormField<int>), findsNWidgets(2));
      await tester.ensureVisible(find.text('Copiar para o Cortecloud'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester
          .ensureVisible(find.byKey(const ValueKey('preco-Fator de corte')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('altura e preços atualizam orçamento e exportação do único móvel',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? textoCopiado;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          textoCopiado = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(const AppAquario());
    String total() => tester
        .widgetList<Text>(find.byType(Text))
        .firstWhere((t) => t.data?.startsWith('R\$') ?? false)
        .data!;
    final totalInicial = total();
    await tester.enterText(find.byKey(const ValueKey('Altura (mm)')), '1000');
    await tester.pumpAndSettle();
    expect(find.text('845 × 402 mm • 3 un • 15 mm'), findsOneWidget);
    expect(find.text('1000 × 420 mm • 2 un • 15 mm'), findsOneWidget);
    expect(find.text('730 × 248 mm • 1 un • 15 mm'), findsOneWidget);
    expect(total(), isNot(totalInicial));
    await tester.tap(find.text('Copiar para o Cortecloud'));
    await tester.pumpAndSettle();
    final primeiraCopia = textoCopiado;
    final linhas =
        textoCopiado!.split('\r\n').map((l) => l.split('\t')).toList();
    expect(linhas.where((l) => l[3] == 'Coluna Interna').single[1], '845.0');
    expect(linhas.every((l) => l[8].endsWith('Branco')), isTrue);
    expect(linhas.every((l) => l[9] == 'Aquário 1000x400x1000 mm'), isTrue);
    await tester.enterText(find.byKey(const ValueKey('Altura (mm)')), '950,5');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copiar para o Cortecloud'));
    await tester.pumpAndSettle();
    expect(textoCopiado!.split('\r\n'), hasLength(linhas.length));
    expect(textoCopiado, contains('Aquário 1000x400x950.5 mm'));
    expect(textoCopiado, isNot(contains('Aquário 1000x400x1000 mm')));
    expect(textoCopiado, isNot(primeiraCopia));
    final totalAntesPreco = total();
    await tester.enterText(
        find.byKey(const ValueKey('preco-Chapa branca')), '700,50');
    await tester.pumpAndSettle();
    expect(total(), isNot(totalAntesPreco));
    final antesDoErro = textoCopiado;
    for (final invalido in ['', '270', '-1', 'NaN', 'Infinity']) {
      await tester.enterText(
          find.byKey(const ValueKey('Altura (mm)')), invalido);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copiar para o Cortecloud'));
      await tester.pumpAndSettle();
      expect(find.text('Mínimo: 271 mm'), findsOneWidget);
      expect(textoCopiado, antesDoErro);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('layout se adapta ao redimensionar com fonte ampliada e teclado',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data:
            MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.5)),
        child: child!,
      ),
      home: const CalculadoraMovel(),
    ));
    await tester.enterText(find.byKey(const ValueKey('Altura (mm)')), '1100');
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(320, 640);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('layout-mobile')), findsOneWidget);
    expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('Altura (mm)')))
            .initialValue,
        '1100');
    await tester.ensureVisible(find.text('Copiar para o Cortecloud'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
