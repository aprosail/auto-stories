import 'package:auto_stories/generator.dart';

Future<void> main(List<String> arguments) async {
  final package = DartPackage.resolve('.');
  if (arguments.contains('test')) await package.test();
}
