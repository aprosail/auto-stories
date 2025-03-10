dart format --set-exit-if-changed --output none .
dart analyze --fatal-infos --fatal-warnings
dart run bin/build.dart test
