import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:find_my_job/app.dart';

void main() {
  testWidgets('App smoke test — renders without crashing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FindMyJobApp()),
    );
    expect(find.byType(FindMyJobApp), findsOneWidget);
  });
}
