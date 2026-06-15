import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:agenda_escolar/providers/auth_provider.dart';
import 'package:agenda_escolar/screens/login_screen.dart';
import 'package:agenda_escolar/utils/senha_util.dart';

void main() {
  // Teste de unidade: o hash é determinístico e a conferência funciona.
  group('SenhaUtil', () {
    test('mesma senha gera o mesmo hash', () {
      expect(SenhaUtil.gerarHash('123456'), SenhaUtil.gerarHash('123456'));
    });

    test('confere senha correta e rejeita errada', () {
      final hash = SenhaUtil.gerarHash('minhaSenha');
      expect(SenhaUtil.conferir('minhaSenha', hash), isTrue);
      expect(SenhaUtil.conferir('outra', hash), isFalse);
    });
  });

  // Teste de widget: a tela de login mostra o título e o botão Entrar.
  testWidgets('LoginScreen exibe título e botão', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Agenda Escolar'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
