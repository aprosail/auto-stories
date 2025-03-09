/// @docImport 'package:flutter/cupertino.dart';
/// @docImport 'package:flutter/material.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Wraps about environments in the widget tree context.
extension WrapEnvironments on Widget {
  /// Wrap current widget with a [MediaQuery] widget with specified [data].
  MediaQuery media(MediaQueryData data, {Key? key}) =>
      MediaQuery(key: key, data: data, child: this);

  /// Wrap current widget with a [Directionality] widget
  /// with specified [direction].
  Directionality textDirection(TextDirection direction, {Key? key}) =>
      Directionality(key: key, textDirection: direction, child: this);

  /// Ensure the text in such widget can display normally.
  /// See [EnsureText] for more details.
  EnsureText ensureText({
    Key? key,
    MediaQueryData? media,
    TextDirection? direction,
    TextDirection defaultDirection = TextDirection.ltr,
  }) => EnsureText(
    key: key,
    media: media,
    direction: direction,
    defaultDirection: defaultDirection,
    child: this,
  );
}

/// A widget to ensure the [Text] widget can display in its descendants.
///
/// The [Text] widget requires a [MediaQuery] and [Directionality]
/// as ancestors in the widget tree context,
/// or the assertions cannot pass,
/// and the text cannot display normally.
///
/// [WidgetsApp] implementations including [MaterialApp] and [CupertinoApp]
/// had already wrap `home` with those widgets,
/// but this widget is designed for the condition without imports from
/// `package:flutter/material.dart` or `package:flutter/cupertino.dart`.
/// And by the way, when testing, wrapping this widget
/// is much more efficient that wrapping those two [WidgetsApp]s.
class EnsureText extends StatelessWidget {
  /// Ensure the [Text] widget can display in its descendants.
  ///
  /// The [Text] widget requires a [MediaQuery] and [Directionality]
  /// as ancestors in the widget tree context,
  /// or the assertions cannot pass,
  /// and the text cannot display normally.
  ///
  /// You may specify the [media] and [direction] to apply on its descendants.
  /// But this widget is designed for testing propose,
  /// that it's strongly not recommended to use it in production code,
  /// because it's not as efficient and might waste the performance.
  const EnsureText({
    required this.child,
    super.key,
    this.media,
    this.direction,
    this.defaultDirection = TextDirection.ltr,
  });

  /// Specify a media to wrap on its descendants.
  ///
  /// When specified, this [media] will be wrapped,
  /// and when `null`, it will apply the media parsed from [View]
  /// if there's no [MediaQuery] ancestor in the widget tree context.
  final MediaQueryData? media;

  /// Specify a text direction to wrap on its descendants.
  ///
  /// When specified, this [direction] will be wrapped,
  /// and when `null`, it will apply the text direction parsed from [View]
  /// if there's no [Directionality] ancestor in the widget tree context.
  /// And in that case, the default value will be [defaultDirection].
  final TextDirection? direction;

  /// Specify a default text direction which will be applied
  /// when [direction] is `null` and there's no [Directionality] ancestor
  /// in the widget tree context. The default value is [TextDirection.ltr].
  final TextDirection defaultDirection;

  /// Child to apply this encapsulation of ensuring environment for [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var handler = child;

    // Ensure directionality environment.
    if (direction != null || Directionality.maybeOf(context) == null) {
      handler = handler.textDirection(direction ?? defaultDirection);
    }

    // Ensure media query environment.
    if (media != null || MediaQuery.maybeOf(context) == null) {
      handler = handler.media(
        media ?? MediaQueryData.fromView(View.of(context)),
      );
    }

    return handler;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<MediaQueryData?>('media', media))
      ..add(EnumProperty<TextDirection>('direction', direction))
      ..add(EnumProperty<TextDirection>('defaultDirection', defaultDirection));
  }
}
