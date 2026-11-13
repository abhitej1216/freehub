import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freehub/app.dart';
import 'package:freehub/presentation/providers/database_providers.dart';

void main() {
  testWidgets('FreeHubApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const FreeHubApp(),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify FreeHub app builds properly
    expect(find.byType(FreeHubApp), findsOneWidget);
  });
}
