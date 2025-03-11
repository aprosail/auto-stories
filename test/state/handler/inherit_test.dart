import 'package:auto_stories/auto_stories.dart';
import 'package:flutter/foundation.dart';
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

  testWidgets('update', (t) async {
    const message = 'message';
    const updatedMessage = 'updated message';
    const updateButtonLabel = 'update';

    await t.pumpWidget(
      const _Example(
        message: message,
        updatedMessage: updatedMessage,
        buttonLabel: updateButtonLabel,
      ).ensureText(),
    );
    expect(find.text(updateButtonLabel), findsOneWidget);
    expect(find.text(message), findsOneWidget);

    await t.tap(find.text(updateButtonLabel));
    await t.pump();
    expect(find.text(updatedMessage), findsOneWidget);
  });
}

class _Example extends StatefulWidget {
  const _Example({
    required this.buttonLabel,
    required this.message,
    required this.updatedMessage,
  });

  final String buttonLabel;
  final String message;
  final String updatedMessage;

  @override
  State<_Example> createState() => _ExampleState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('buttonLabel', buttonLabel))
      ..add(StringProperty('message', message))
      ..add(StringProperty('updatedMessage', updatedMessage));
  }
}

class _ExampleState extends State<_Example> {
  late String message = widget.message;

  @override
  Widget build(BuildContext context) {
    final detector = Builder(builder: (c) => c.find<String>()!.asText());
    final button = widget
        .buttonLabel //
        .asText()
        .gesture(onTap: () => setState(() => message = widget.updatedMessage));

    return [detector, button].columnCenter.inherit(message);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('message', message));
  }
}
