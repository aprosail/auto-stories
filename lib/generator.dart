/// Command line generator approach of code generating.
/// see: https://pub.dev/packages/analyzer
library;

import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/file_system/file_system.dart' show ResourceProvider;

abstract class Generator {
  Generator({required this.entries, ResourceProvider? resourceProvider})
    : contextCollection = AnalysisContextCollection(
        includedPaths: entries.map((item) => item.path).toList(),
        resourceProvider: resourceProvider,
      );

  /// All files and folders to be included inside the analysis.
  final Iterable<FileSystemEntity> entries;
  late final AnalysisContextCollection contextCollection;

  /// Update a [file], generate it if available and necessary.
  /// It will return a [bool] value to represent
  /// whether the file had been modified.
  Future<void> update(File file) async {
    switch (await resolve(file)) {
      case final ResolvedUnitResult result:
        generate(file, result.unit);
      default:
    }
  }

  /// Resolve a [file] and return the resolved unit.
  /// It will trace all imports and analyze when possible,
  /// and it will cache the analyzed AST result for further use,
  /// in order to improve performance.
  Future<SomeResolvedUnitResult> resolve(File file) => contextCollection
      .contextFor(file.path)
      .currentSession
      .getResolvedUnit(file.path);

  /// Define how to generate on a single file.
  /// Override such abstract method to customize the generator.
  void generate(File file, CompilationUnit unit);
}

class AutoStoriesGenerator extends Generator {
  AutoStoriesGenerator({required super.entries, super.resourceProvider});

  @override
  void generate(File file, CompilationUnit unit) {}
}
