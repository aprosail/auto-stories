import 'package:auto_stories/auto_stories.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ensure text', (t) async {
    const message = 'message';
    await t.pumpWidget(const EnsureText(child: Center(child: Text(message))));
    expect(find.text(message), findsOneWidget);
  });
}
