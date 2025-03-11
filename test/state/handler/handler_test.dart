import 'package:auto_stories/auto_stories.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('handler', (t) async {
    var counter = 0;
    await t.pumpWidget(Example(callback: (_) => counter++).ensureText());
    expect(counter, 0);
    expect(find.text('outer value: ${0}'), findsOneWidget);
    expect(find.text('value: ${0}'), findsOneWidget);

    // Update from outside.
    await t.tap(find.text(increase));
    await t.pump();
    expect(counter, 1);
    expect(find.text('outer value: ${1}'), findsOneWidget);
    expect(find.text('value: ${1}'), findsOneWidget);

    // Update from inside: outer value won't change.
    await t.tap(find.text(decrease));
    await t.pump();
    expect(counter, 2);
    expect(find.text('outer value: ${1}'), findsOneWidget);
    expect(find.text('value: ${0}'), findsOneWidget);
  });
}

const increase = 'increase';
const decrease = 'decrease';

/// Encapsulate the [int] value, because it's not allowed in [Handler],
/// as the [num] might cause program breakdown because of
/// potential type error.
class Counter {
  const Counter(this.value);

  final int value;
}

class Example extends StatefulWidget {
  const Example({super.key, this.callback});

  final void Function(int value)? callback;

  @override
  State<Example> createState() => _ExampleState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ObjectFlagProperty<void Function(int value)?>.has('callback', callback),
    );
  }
}

class _ExampleState extends State<Example> {
  var _value = 0;
  int get value => _value;
  set value(int value) {
    if (value != _value) setState(() => _value = value);
  }

  @override
  Widget build(BuildContext context) {
    final increaseButton = increase.text.gesture(onTap: () => value++);
    final outerProbe = 'outer value: $value'.text;
    final innerProbe = Builder(
      builder: (context) {
        final value = context.find<Counter>()!.value;
        final display = 'value: $value'.asText();
        final decreaseButton = decrease.text.gesture(
          onTap: () => context.update(Counter(value - 1)),
        );
        return [display, decreaseButton].columnCenter;
      },
    );

    return [outerProbe, innerProbe, increaseButton].columnCenter.handle(
      Counter(value),
      onChange: (counter) => widget.callback?.call(counter.value),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('value', value));
  }
}
