import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:auto_stories/plugin.dart';

void main(List<String> arguments, SendPort sendPort) {
  final resources = PhysicalResourceProvider.INSTANCE;
  final plugin = AutoStoriesPlugin(resourceProvider: resources);
  ServerPluginStarter(plugin).start(sendPort);
}
