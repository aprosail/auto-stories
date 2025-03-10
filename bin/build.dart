import 'package:auto_stories/generator.dart';

Future<void> main() async {
  final package = DartPackage.resolve('.');
  await package.test();
}
