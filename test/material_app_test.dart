import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

void main() {
  test('center callbacks remain mutually exclusive', () {
    expect(
      () => SimpleCircularProgressBar(
        onGetText: (value, maxValue) => Text('$value'),
        centerChild: (value, maxValue) => const Icon(Icons.timer),
      ),
      throwsAssertionError,
    );
  });

  testWidgets(
    'custom center receives notifier values and preserves ownership',
    (tester) async {
      final notifier = ValueNotifier(5.0);
      addTearDown(notifier.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SimpleCircularProgressBar(
                maxValue: 10,
                valueNotifier: notifier,
                animationDuration: Duration.zero,
                centerChild: (value, maxValue) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer),
                    Text('${value.toInt()}/${maxValue.toInt()}'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('5/10'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
      notifier.value = 8;
      await tester.pumpAndSettle();
      expect(find.text('8/10'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      notifier.value = 9;
      expect(notifier.value, 9);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('text callback tracks animation and decreasing values wrap', (
    tester,
  ) async {
    final notifier = ValueNotifier(50.0);
    addTearDown(notifier.dispose);
    var current = -1.0;
    var maximum = -1.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SimpleCircularProgressBar(
            maxValue: 200,
            valueNotifier: notifier,
            animationDuration: const Duration(seconds: 2),
            onGetText: (value, maxValue) {
              current = value;
              maximum = maxValue;
              return Text('${value.toInt()}/${maxValue.toInt()}');
            },
          ),
        ),
      ),
    );

    expect(current, 0);
    await tester.pump(const Duration(milliseconds: 250));
    expect(current, closeTo(25, 0.001));
    expect(maximum, 200);
    await tester.pumpAndSettle();
    expect(find.text('50/200'), findsOneWidget);

    notifier.value = 25;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(current, closeTo(100, 0.001));
    await tester.pumpAndSettle();
    expect(find.text('25/200'), findsOneWidget);

    notifier.value = 250;
    await tester.pumpAndSettle();
    expect(find.text('200/200'), findsOneWidget);
    notifier.value = -5;
    await tester.pumpAndSettle();
    expect(find.text('0/200'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('inactivity ring paints decreasing values without animation', (
    tester,
  ) async {
    final notifier = ValueNotifier(10.0);
    addTearDown(notifier.dispose);
    final backColor = Colors.grey.withValues(alpha: 0.4);

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SimpleCircularProgressBar(
            maxValue: 10,
            size: 10,
            backStrokeWidth: 6,
            progressStrokeWidth: 6,
            progressColors: const [Colors.red],
            mergeMode: true,
            animationDuration: Duration.zero,
            fullProgressColor: Colors.red,
            backColor: backColor,
            valueNotifier: notifier,
          ),
        ),
      ),
    );
    final paint = find.descendant(
      of: find.byType(SimpleCircularProgressBar),
      matching: find.byType(CustomPaint),
    );
    expect(paint, paints..circle(radius: 5, color: Colors.red, strokeWidth: 6));

    for (final value in [9.0, 5.0]) {
      notifier.value = value;
      await tester.pumpAndSettle();
      expect(
        paint,
        paints
          ..circle(radius: 5, color: backColor, strokeWidth: 6)
          ..arc(strokeWidth: 6, strokeCap: StrokeCap.round),
      );
    }
    for (final value in [0.0, -1.0]) {
      notifier.value = value;
      await tester.pumpAndSettle();
      expect(paint, paints..circle(color: backColor));
      expect(paint, isNot(paints..arc()));
    }

    notifier.value = 11;
    await tester.pumpAndSettle();
    expect(paint, paints..circle(color: Colors.red));
    expect(tester.takeException(), isNull);
  });
}
