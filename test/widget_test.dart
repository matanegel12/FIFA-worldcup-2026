import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/app.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('World Cup 2026'), findsOneWidget);
  });
}
