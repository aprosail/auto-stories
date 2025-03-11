# !/bin/bash

# Check root directory.
dart format --set-exit-if-changed --output none .
dart analyze --fatal-infos --fatal-warnings
dart run bin/build.dart test

# Check vscode extension.
cd editors/vscode
npm run check
cd ../..
