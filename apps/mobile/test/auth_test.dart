import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aerogaze_mobile/app/aerogaze_app.dart';
import 'package:aerogaze_mobile/features/auth/login_page.dart';
import 'package:aerogaze_mobile/features/auth/recovery_page.dart';
import 'package:aerogaze_mobile/features/auth/sms_recovery_page.dart';
import 'package:aerogaze_mobile/features/auth/support_page.dart';

Future<void> tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> enter(WidgetTester tester, String key, String value) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.enterText(finder, value);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('real login awaits API and preserves visible credential error', (
    tester,
  ) async {
    var calls = 0, demoCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          onSignIn: (_) => demoCalls++,
          authenticate: (email, password) async {
            calls++;
            throw Exception('Credenciais recusadas pela API');
          },
        ),
      ),
    );
    await enter(tester, 'login-operator', 'integration@example.invalid');
    await enter(tester, 'login-password', 'incorrect-test-password');
    await tapKey(tester, 'login-submit');
    expect(calls, 1);
    expect(demoCalls, 0);
    expect(
      find.textContaining('Credenciais recusadas pela API'),
      findsOneWidget,
    );
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('demo accepts arbitrary credentials and logout clears the form', (
    tester,
  ) async {
    await tester.pumpWidget(
      const AeroGazeApp(showSplash: false, demoLogin: true),
    );
    await tester.pumpAndSettle();
    await tapKey(tester, 'login-submit');
    expect(find.byType(FieldShell), findsNothing);
    await enter(tester, 'login-operator', 'qualquer pessoa');
    await enter(tester, 'login-password', 'senha livre');
    await tapKey(tester, 'login-submit');
    expect(find.byType(FieldShell), findsOneWidget);
    await tapKey(tester, 'logout');
    expect(find.byType(LoginPage), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('login-password')))
          .controller!
          .text,
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('recovery validates email and navigates to alternative methods', (
    tester,
  ) async {
    await tester.pumpWidget(
      const AeroGazeApp(showSplash: false, demoLogin: true),
    );
    await tester.pumpAndSettle();
    await tapKey(tester, 'login-recover');
    expect(find.byType(RecoveryPage), findsOneWidget);
    await tapKey(tester, 'recovery-submit');
    expect(find.textContaining('Informe um e-mail válido'), findsOneWidget);
    await enter(tester, 'recovery-email', 'teste@exemplo.com');
    await tapKey(tester, 'recovery-submit');
    expect(
      find.textContaining('Nenhum e-mail foi enviado e nenhuma senha'),
      findsOneWidget,
    );
    await tapKey(tester, 'recovery-sms');
    expect(find.byType(SmsRecoveryPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'OTP requires sending, rejects wrong code and accepts a pasted demo code',
    (tester) async {
      var signedIn = false;
      await tester.pumpWidget(
        MaterialApp(home: SmsRecoveryPage(onSignIn: (_) => signedIn = true)),
      );
      await tester.pumpAndSettle();
      await tapKey(tester, 'sms-validate');
      expect(signedIn, isFalse);
      await enter(tester, 'sms-operator', 'livre');
      await enter(tester, 'sms-phone', '46999991088');
      await tapKey(tester, 'sms-send');
      await enter(tester, 'otp-0', '654321');
      await tapKey(tester, 'sms-validate');
      expect(signedIn, isFalse);
      expect(find.textContaining('Código incorreto.'), findsOneWidget);
      await enter(tester, 'otp-0', '123456');
      await tapKey(tester, 'sms-validate');
      expect(signedIn, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'changing the recovery channel clears the code and requires terminal',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: SmsRecoveryPage(onSignIn: (_) {})),
      );
      await tester.pumpAndSettle();
      await enter(tester, 'sms-operator', 'demo');
      await enter(tester, 'sms-phone', '46999991088');
      await tapKey(tester, 'sms-send');
      await enter(tester, 'otp-0', '123456');
      await tapKey(tester, 'channel-satellite');
      expect(
        tester.widget<TextField>(find.byKey(const ValueKey('otp-0'))).enabled,
        isFalse,
      );
      await tapKey(tester, 'sms-send');
      expect(find.byKey(const ValueKey('sms-terminal')), findsOneWidget);
      expect(find.textContaining('Código de demonstração:'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('support reports the selected urgency and simulated channel', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SupportPage(onSignIn: (_) {}, operatorName: 'Demo'),
      ),
    );
    await tester.pumpAndSettle();
    await tapKey(tester, 'urgency-critical');
    await tapKey(tester, 'support-channel-radio');
    await enter(tester, 'support-description', 'Preciso de apoio');
    await tapKey(tester, 'support-submit');
    expect(
      find.textContaining('Chamado simulado: urgência crítica'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Nenhum chamado foi enviado ou salvo.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  for (final width in [320.0, 600.0]) {
    testWidgets('auth screens fit width $width with enlarged text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final page in <Widget>[
        LoginPage(onSignIn: (_) {}),
        RecoveryPage(onSignIn: (_) {}),
        SmsRecoveryPage(onSignIn: (_) {}),
        SupportPage(onSignIn: (_) {}),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.5)),
              child: child!,
            ),
            home: page,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
