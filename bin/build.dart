import 'package:auto_stories/generator.dart';

const additionalPubIgnores = [
  'bin/build.dart', // Build script of the package.
  'editors', // Code editor extensions, not a part of the dart package.
  'CONTRIBUTING.md', // Unnecessary for pub.dev, read it on GitHub.
  '*.sh', // Shell scripts for CI/CD.
  // Unnecessary platform code in the example package.
  'example/android',
  'example/ios',
  'example/linux',
  'example/macos',
  'example/test',
  'example/web',
  'example/windows',
];

Future<void> main(List<String> arguments) async {
  final package =
      DartPackage.resolve('.')
        ..generateChangelog()
        ..generatePubignore(additionalIgnores: additionalPubIgnores);

  // Copy VSCode settings to the example folder.
  package
      .directory(['.vscode'])
      .copyAllFilesSync(package.directory(['example', '.vscode']).path);

  // Test when necessary (arguments specified).
  if (arguments.contains('test')) await package.test();
}
