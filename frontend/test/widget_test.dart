import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('TrustLayer app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const TrustLayerApp());
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(TrustLayerApp), findsOneWidget);
  });
}
