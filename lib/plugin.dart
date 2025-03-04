/// Analyzer plugin approach of code generating,
/// see: https://pub.dev/packages/analyzer_plugin
library;

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer_plugin/plugin/assist_mixin.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:analyzer_plugin/utilities/assist/assist.dart';

class AutoStoriesPlugin extends ServerPlugin with AssistsMixin {
  AutoStoriesPlugin({
    required super.resourceProvider,
    this.name = 'Auto Stories Plugin',
    this.version = '0.0.0',
    this.fileGlobsToAnalyze = const ['**/*.dart'],
  });

  @override
  final String name;

  @override
  final String version;

  @override
  final List<String> fileGlobsToAnalyze;

  @override
  Future<void> analyzeFile({
    required AnalysisContext analysisContext,
    required String path,
  }) async {}

  @override
  List<AssistContributor> getAssistContributors(String path) {
    return [];
  }

  @override
  Future<AssistRequest> getAssistRequest(
    EditGetAssistsParams parameters,
  ) async => DartAssistRequestImpl(
    resourceProvider: resourceProvider,
    offset: parameters.offset,
    length: parameters.length,
    result: await getResolvedUnitResult(parameters.file),
  );
}

class DartAssistRequestImpl implements DartAssistRequest {
  DartAssistRequestImpl({
    required this.resourceProvider,
    required this.offset,
    required this.length,
    required this.result,
  });

  @override
  final int offset;

  @override
  final int length;

  @override
  final ResolvedUnitResult result;

  @override
  final ResourceProvider resourceProvider;
}
