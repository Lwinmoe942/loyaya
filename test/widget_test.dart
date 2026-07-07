import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:loyaya/main.dart';

void main() {
  testWidgets('app root shows loading then auth', (WidgetTester tester) async {
    await tester.pumpWidget(const LotayaShweOhApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
