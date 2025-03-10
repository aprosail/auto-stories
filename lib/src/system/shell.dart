import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Encapsulation of running command in the shell,
/// and redirect the output of such command into [stdout] and [stderr].
extension RunInShell on Process {
  /// Encapsulation of running command in the shell.
  ///
  /// 1. It will redirect the output of such command into [stdout] and [stderr].
  /// 2. All parameters but [transformer] are just the same as [Process.run].
  /// 3. The default [transformer] is [Utf8Codec.decoder],
  /// which will transform the output stream into utf8 strings,
  /// and you can also specify other decoders,
  /// according to the exact environment of current platform and terminal.
  Future<void> shell(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = true,
    ProcessStartMode mode = ProcessStartMode.normal,
    StreamTransformer<List<int>, String>? transformer,
  }) async {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      mode: mode,
    );
    process.stdout.transform(transformer ?? utf8.decoder).listen(stdout.write);
    process.stderr.transform(transformer ?? utf8.decoder).listen(stderr.write);
  }
}
