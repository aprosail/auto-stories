/// Generator APIs that generate data and stories preview.
///
/// ## Incompatibilities with `package:flutter`
///
/// This library contains imports of `package:analyzer`,
/// which is incompatible with `package:flutter`,
/// so don't import such library into your `package:flutter` related code,
/// or it will cause compile errors.
/// And when testing with this library,
/// `package:flutter_test` and `flutter test` is also not compatible,
/// that you can only test corresponding code with `package:test`
/// and the `dart test` command.
///
/// @docImport "package:path/path.dart";
library;

import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/file_system/file_system.dart' show ResourceProvider;

export 'src/generate.dart';

/// A general proposed abstract class for code generating on files.
abstract class Generator {
  /// This constructor is designed for code reuse by subclasses.
  Generator({
    required this.entries,
    this.sdkPath,
    ResourceProvider? resourceProvider,
  }) : _contextCollection = AnalysisContextCollection(
         includedPaths: entries.map((entry) => entry.path).toList(),
         resourceProvider: resourceProvider,
         sdkPath: sdkPath,
       );

  /// All files and folders to be included inside the analysis.
  ///
  /// It means: all those files and the ones inside those folders
  /// can be an entry point for analysis. (At least they are dart files).
  /// Files not inside the [entries] might also be included in the analysis
  /// if they are imported by one of the [entries], directly or indirectly.
  ///
  /// It's strongly recommended to use [absolute] and [normalize]d paths.
  final Iterable<FileSystemEntity> entries;

  /// Specify a SDK to use, or `null` for current default SDK.
  final String? sdkPath;

  /// An encapsulated context collection.
  ///
  /// This instance is here to handle analysis cache
  /// to avoid repeated analysis and improve performance.
  /// Analysis of a dart file with import of big packages,
  /// for example, `package:flutter`, will take a few seconds,
  /// which is inconvenient for the user.
  /// But with such cache, the second analysis after indexing
  /// will only take a few milliseconds.
  final AnalysisContextCollection _contextCollection;

  /// Analysis a [file] and return the result.
  ///
  /// The analysis may fail,
  /// and the returned value may not be a prepared abstract syntax tree,
  /// so there might be more encapsulations on this method.
  Future<SomeResolvedUnitResult> resolve(File file) => _contextCollection
      .contextFor(file.path)
      .currentSession
      .getResolvedUnit(file.path);

  /// Update a [file] and [generate] if the analysis succeeds.
  ///
  /// You may override the [generate] method to specify
  /// how to generate according to the source code file.
  /// If the analysis failed, it will do nothing.
  Future<void> update(File file) async {
    switch (await resolve(file)) {
      case final ResolvedUnitResult result:
        generate(file, result.unit);
      default:
    }
  }

  /// Override this method to specify how to generate according to
  /// the source [file] and the parsed [unit] of the abstract syntax tree.
  void generate(File file, CompilationUnit unit);
}
