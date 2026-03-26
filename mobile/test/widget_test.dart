import 'package:fitstrike_mobile/shared/widgets/app_viewport.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppViewport renders child content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppViewport(
          child: Text('FitStrike'),
        ),
      ),
    );

    expect(find.text('FitStrike'), findsOneWidget);
  });
}
