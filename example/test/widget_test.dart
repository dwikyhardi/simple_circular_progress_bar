import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:simple_circular_progress_bar_example/main.dart';

void main() {
  testWidgets('open the progress bar examples', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('PROGRESS BAR EXAMPLE'));
    await tester.pumpAndSettle();

    expect(find.byType(SimpleCircularProgressBar), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('submit a new notifier value', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('VALUE NOTIFIER EXAMPLE'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '42');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('42'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
