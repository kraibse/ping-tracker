// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ping_tracker/main.dart';
import 'package:ping_tracker/controllers/settings_controller.dart';
import 'package:ping_tracker/controllers/entry_controller.dart';
import 'package:ping_tracker/controllers/log_controller.dart';

void main() {
  testWidgets('App builds and shows title', (WidgetTester tester) async {
    final settings = SettingsController();
    final logs = LogController();
    final entry = EntryController(settings: settings, logs: logs);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: settings),
          ChangeNotifierProvider.value(value: logs),
          ChangeNotifierProvider.value(value: entry),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ping Tracker'), findsOneWidget);
    expect(find.byTooltip('Add entry'), findsOneWidget);
  });
}
