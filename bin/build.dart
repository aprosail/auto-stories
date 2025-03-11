import 'package:auto_stories/generator.dart';

Future<void> main(List<String> arguments) async {
  final package = DartPackage.resolve('.');
  package.generatePubignore(
    basedOn: [package.rootGitignore],
    additionalIgnores: [
      'bin/build.dart', // Build script of the package.
      'editors', // Code editor extensions, not a part of the dart package.
      'CONTRIBUTING.md', // Unnecessary for pub.dev, read it on GitHub.
      '*.sh', // Shell scripts for CI/CD.
    ],
  );

  if (arguments.contains('test')) await package.test();
}
