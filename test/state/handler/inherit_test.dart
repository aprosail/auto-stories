import 'package:auto_stories/auto_stories.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('inherit data', (t) async {
    const message = 'message';
    await t.pumpWidget(
      Builder(builder: (context) => context.find<String>()!.text)
          .center //
          .inherit(message)
          .ensureText(),
    );
    expect(find.text(message), findsOneWidget);
  });
}
