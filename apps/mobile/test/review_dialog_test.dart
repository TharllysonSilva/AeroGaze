import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aerogaze_mobile/features/operations/review_dialog.dart';

void main() {
  testWidgets(
    'Revisão valida descrição e conserva controller durante fechamento',
    (tester) async {
      String? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showDialog<String>(
                    context: context,
                    builder: (_) => const ReviewDialog(),
                  );
                },
                child: const Text('Nova revisão'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Nova revisão'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Registrar'))
            .onPressed,
        isNull,
      );
      await tester.enterText(
        find.byKey(const ValueKey('new-review-notes')),
        '  Revisar irrigação  ',
      );
      await tester.pump();
      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();
      expect(result, 'Revisar irrigação');
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Nova revisão'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('new-review-notes')))
            .controller!
            .text,
        isEmpty,
      );
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
