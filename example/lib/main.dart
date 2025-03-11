import 'package:auto_stories/auto_stories.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const App());
}

/// Demonstrate how to use `package:auto_stories`.
class App extends StatelessWidget {
  /// Entry point of the whole application.
  const App({super.key});

  @override
  Widget build(BuildContext context) => 'entry point'.text.center.ensureText();
}
