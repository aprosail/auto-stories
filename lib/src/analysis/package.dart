import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';

/// Utilities about a Dart package.
class DartPackage {
  /// Construct an instance with the specified [root] directory object.
  ///
  /// It's strongly recommended to use an [absolute]d and [normalize]d path.
  /// Once there's no existing [Directory] instance,
  /// the [DartPackage.resolve] constructor might be a more convenient choice,
  /// as it will resolve the given path, [absolute] and [normalize]
  /// the raw parameter in type [String]
  const DartPackage(this.root);

  /// Construct an instance with the specified [path].
  ///
  /// The given [path] will be [absolute]d and [normalize]d,
  /// that you can specify even a relative path to current working directory.
  /// But when there's already an instance of [Directory] or its absolute path,
  /// the unnamed constructor might be a more efficient way.
  DartPackage.resolve(String path)
    : root = Directory(normalize(absolute(path)));

  /// Root directory of the Dart package.
  final Directory root;

  /// Get a directory according to the relative path to package [root].
  Directory directory(List<String> paths) =>
      Directory(joinAll([root.path, ...paths]));

  /// Get a file according to the relative path to package [root].
  File file(List<String> paths) => File(joinAll([root.path, ...paths]));

  /// Lib directory of the Dart package, the entry of all libraries.
  Directory get libDirectory => directory(['lib']);

  /// Test directory of the Dart package, the entry of all tests.
  Directory get testDirectory => directory(['test']);

  /// The `.pubignore` file of the package.
  File get pubignore => file(['.pubignore']);

  /// The `.gitignore` file at [root], but possibly not exist.
  File get rootGitignore => file(['.gitignore']);

  /// All `.gitignore` files inside the package.
  Iterable<File> get gitignores => root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => basename(file.path) == '.gitignore');

  /// Run a command in the [root] directory.
  ///
  /// 1. This method is almost an encapsulation on [Process.start].
  /// 2. It will run with the [root] as current working directory.
  /// 3. It will inherit the stdio by default,
  /// but when it's unnecessary to output,
  /// you can specify the [mode] parameter to [ProcessStartMode.detached].
  Future<int> run(
    String executable,
    List<String> arguments, {
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = true,
    ProcessStartMode mode = ProcessStartMode.inheritStdio,
  }) async {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: root.path,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      mode: mode,
    );
    return process.exitCode;
  }

  /// Test all files inside this Dart package.
  ///
  /// It will detect whether a Dart test file in the [testDirectory]
  /// is a Dart or Flutter test by detecting its imports with [containsImport].
  /// When such file uses `package:test/test.dart`, it will use
  /// the `dart test` command, and when such file
  /// uses `package:flutter_test/flutter_test.dart`, it will use
  /// the `flutter test` command.
  ///
  /// 1. There's parameters like [Process.run] to specify environment.
  /// 2. It will output by default,
  /// as the [mode] is default to [ProcessStartMode.inheritStdio].
  /// When it's unnecessary to output,
  /// you can set the [mode] parameter to [ProcessStartMode.detached].
  Future<void> test({
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = true,
    ProcessStartMode mode = ProcessStartMode.inheritStdio,
  }) async {
    final allTestFiles = testDirectory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('_test.dart'));

    // Classify all test files into Dart and Flutter test files.
    final dartTestFiles = <File>[];
    final flutterTestFiles = <File>[];
    for (final file in allTestFiles) {
      final code = file.readAsStringSync();
      final dartTest = containsImport(code, _dartTestImport);
      final flutterTest = containsImport(code, _flutterTestImport);
      if (dartTest) dartTestFiles.add(file);
      if (flutterTest) flutterTestFiles.add(file);
    }

    // Run dart and flutter tests separately.
    final dartPaths = dartTestFiles.map((file) => file.path).toList();
    final flutterPaths = flutterTestFiles.map((file) => file.path).toList();
    Future<int> run(String executable, List<String> arguments) => this.run(
      executable,
      arguments,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      mode: mode,
    );
    if (dartTestFiles.isNotEmpty) await run('dart', ['test', ...dartPaths]);
    if (flutterTestFiles.isNotEmpty) {
      await run('flutter', ['test', ...flutterPaths]);
    }
  }

  /// Generate a `.pubignore` file at the package [root].
  ///
  /// 1. The `.pubignore` file might be generated from other ignore files,
  /// such as `.gitignore` files, located inside the package [root] directory.
  /// 2. When generating from a `.gitignore` file inside a child package,
  /// all items inside will be added with the relative path from [root]
  /// to the parent directory where the specified [basedOn] file locates.
  /// 3. The specified [additionalIgnores] will be added to the prefix.
  /// 4. It's strongly recommended to use [absolute]d and [normalize]d path.
  void generatePubignore({
    Iterable<File> basedOn = const [],
    List<String> additionalIgnores = const [],
  }) {
    final buffer = StringBuffer(additionalIgnores.join('\n'));
    if (additionalIgnores.isNotEmpty) buffer.writeln();

    for (final file in basedOn) {
      final basePath = normalize(relative(file.parent.path, from: root.path));
      final resolvedBase = basePath == '.' ? '' : '$basePath/';
      buffer.writeln('\n# Synced from $basePath');
      file
          .readAsStringSync()
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && !line.startsWith('#'))
          .map((line) => '$resolvedBase$line')
          .forEach(buffer.writeln);
    }
    pubignore.writeAsStringSync('$buffer\n');
  }
}

const _dartTestImport = 'package:test/';
const _flutterTestImport = 'package:flutter_test/';

/// Whether a Dart [code] contains specified import.
bool containsImport(String code, String importIdentifier) {
  final lines = code.split('\n').map((line) => line.trim());
  for (final line in lines) {
    // Not import statement, pass.
    if (!line.startsWith('import')) continue;

    // Test the import identifier, consider both single and double quotes.
    final content = line.substring('import'.length).trimLeft();
    if (content.startsWith("'$importIdentifier") ||
        content.startsWith('"$importIdentifier')) {
      return true;
    }
  }
  return false;
}

/// Copy a file and create corresponding folders if necessary.
extension CopyEnsureFile on File {
  /// Copy the file and create corresponding folders if necessary,
  /// to ensure that all folders in the [newPath] exists,
  /// that the file can be copied safely.
  void copyEnsureSync(String newPath) {
    File(newPath).parent.createSync(recursive: true);
    copySync(newPath);
  }
}

/// Utilities about copy a directory.
extension CopyDirectory on Directory {
  /// Copy all files in the directory to the [newPath].
  void copyAllFilesSync(String newPath) {
    final e = listSync(recursive: true);
    for (final dir in e.whereType<Directory>()) dir.createSync(recursive: true);
    for (final file in e.whereType<File>()) {
      file.copySync(join(newPath, relative(file.path, from: path)));
    }
  }
}
