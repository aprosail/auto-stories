import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

Future<void> main(List<String> arguments) async {
  final root = Directory.current;
  generatePubignore(root, [
    'bin/build.dart', // Build script.
  ]);

  // Run redirected commands.
  Future<int> run(String cmd) => execute(cmd, workingDirectory: root.path);
  await run('dart format --set-exit-if-changed --output none .');
  await run('dart analyze --fatal-infos --fatal-warnings');
  await run('flutter test');
}

/// Generate a `.pubignore` file directly under the [root] folder.
/// If there's a `.gitignore` file at root,
/// it will sync all its contents with comments removed.
/// You can also specify some [additionalIgnores]
/// to be ignored by `pub publish` but not ignored by Git.
void generatePubignore(Directory root, List<String> additionalIgnores) {
  final gitignoreFile = File(join(root.path, '.gitignore'));
  final handler = <String>[];
  if (gitignoreFile.existsSync()) {
    handler.addAll(
      gitignoreFile
          .readAsStringSync()
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && !line.startsWith('#')),
    );
  }
  final content = [
    ...additionalIgnores,
    '',
    if (handler.isNotEmpty) '# Followings are synced from Git ignores.',
    ...handler,
    '',
  ].join('\n');
  File(join(root.path, '.pubignore')).writeAsStringSync(content);
}

/// Encapsulation of execution of a command.
///
/// It will first transform the [command] string to a list,
/// and then call [Process.start] to execute and redirect the outputs.
/// All other parameters are just the same as [Process.start].
Future<int> execute(
  String command, {
  String? workingDirectory,
  Map<String, String>? environment,
  bool includeParentEnvironment = true,
  bool runInShell = false,
  ProcessStartMode mode = ProcessStartMode.normal,
}) async {
  // Transform command string to list.
  final commands =
      command.trim().split(' ').map((item) => item.trim()).toList()
        ..removeWhere((item) => item.isEmpty);
  assert(commands.isNotEmpty, 'commands cannot be empty ($command)');

  // Run the command and redirect output to stdout and stderr.
  final process = await Process.start(
    commands.first,
    commands.sublist(1),
    workingDirectory: workingDirectory,
    environment: environment,
    includeParentEnvironment: includeParentEnvironment,
    runInShell: runInShell,
    mode: mode,
  );
  process.stderr.transform(utf8.decoder).listen(stderr.write);
  process.stdout.transform(utf8.decoder).listen(stdout.write);
  return process.exitCode;
}
