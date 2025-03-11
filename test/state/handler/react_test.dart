import 'package:auto_stories/auto_stories.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('react', (t) async {
    final handler = React(phase1);
    var counter = 0;
    await t.pumpWidget(Example(handler: handler).ensureText());
    expect(find.text(phase1), findsOneWidget);

    // Registered state updated, unregistered counter unchanged.
    handler.value = phase2;
    await t.pump();
    expect(find.text(phase2), findsOneWidget);
    expect(counter, 0);

    // Register the counter and it will also be updated.
    void increase() => counter++;
    handler.callbacks.add(increase);
    handler.value = phase3;
    await t.pump();
    expect(find.text(phase3), findsOneWidget);
    expect(counter, 1);

    // Removed callback won't be called anymore.
    handler.callbacks.remove(increase);
    handler.value = phase4;
    await t.pump();
    expect(find.text(phase4), findsOneWidget);
    expect(counter, 1);
  });
}

const phase1 = 'phase1';
const phase2 = 'phase2';
const phase3 = 'phase3';
const phase4 = 'phase4';

class Example extends StatefulWidget {
  const Example({super.key, required this.handler});

  final React<String> handler;

  @override
  State<Example> createState() => _ExampleState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<React<String>>('handler', handler));
  }
}

class _ExampleState extends State<Example> {
  @override
  void initState() {
    super.initState();
    widget.handler.states.add(this);
  }

  @override
  void dispose() {
    widget.handler.states.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.handler.value.asText().center;
}
