import 'package:aerogaze_mobile/app/startup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> loadArtwork(WidgetTester tester) async {
  await tester.runAsync(
    () => precacheImage(
      const AssetImage('assets/branding/aerogaze-splash.png'),
      tester.element(find.byType(StartupScreen)),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  test(
    'each radar contact activates on crossing, fades, then reactivates next lap',
    () {
      for (final contact in radarContacts) {
        expect(contact.activityAt(0), 0);
        expect(contact.activityAt(contact.phase), 1);
        expect(
          contact.activityAt(contact.phase + .15),
          allOf(greaterThan(0), lessThan(1)),
        );
        expect(contact.activityAt(contact.phase + .35), 0);
        expect(contact.activityAt(contact.phase + 1), closeTo(1, .001));
      }
    },
  );

  testWidgets(
    'home is mounted early and revealed immediately when the bar fills',
    (tester) async {
      var mounts = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StartupScreen(
            displayDuration: const Duration(seconds: 1),
            child: _MountProbe(onMount: () => mounts++),
          ),
        ),
      );
      await loadArtwork(tester);
      expect(mounts, 1);
      expect(
        tester
            .widget<IgnorePointer>(
              find.byKey(const ValueKey('startup-home-input')),
            )
            .ignoring,
        isTrue,
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        tester
            .widget<AeroGazeSplashArt>(find.byType(AeroGazeSplashArt))
            .progress
            .value,
        closeTo(.5, .001),
      );
      expect(
        tester
            .widget<FadeTransition>(
              find.byKey(const ValueKey('startup-overlay')),
            )
            .opacity
            .value,
        1,
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        tester
            .widget<AeroGazeSplashArt>(find.byType(AeroGazeSplashArt))
            .progress
            .value,
        1,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(
        tester
            .widget<FadeTransition>(
              find.byKey(const ValueKey('startup-overlay')),
            )
            .opacity
            .value,
        lessThan(1),
      );
      expect(mounts, 1);
      await tester.pumpAndSettle();
      expect(find.byType(AeroGazeSplashArt), findsNothing);
      expect(
        tester
            .widget<IgnorePointer>(
              find.byKey(const ValueKey('startup-home-input')),
            )
            .ignoring,
        isFalse,
      );
      expect(mounts, 1);
    },
  );

  testWidgets('closing startup disposes both animation controllers', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StartupScreen(
          displayDuration: Duration(milliseconds: 100),
          child: Text('APP PRONTO'),
        ),
      ),
    );
    await loadArtwork(tester);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 6));
    expect(tester.takeException(), isNull);
  });
}

class _MountProbe extends StatefulWidget {
  const _MountProbe({required this.onMount});
  final VoidCallback onMount;
  @override
  State<_MountProbe> createState() => _MountProbeState();
}

class _MountProbeState extends State<_MountProbe> {
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  Widget build(BuildContext context) => const Text('APP PRONTO');
}
