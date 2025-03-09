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

/// Encapsulate a [String] as [Text].
extension WrapText on String {
  /// Wrap a [String] with a [Text] widget.
  ///
  /// This getter is designed as a shortcut, especially for testing propose.
  /// and if there's necessary to specify more parameters of the [Text] widget,
  /// you may consider the [asText] extension method, which is similar.
  Text get text => Text(this);

  /// Wrap a [String] with a [Text] widget.
  ///
  /// This method provides all non-deprecated parameters of the [Text] widget.
  /// And if there's no necessary to specify those parameters,
  /// you may consider the [text] getter, which might simplify your code,
  /// especially for testing propose.
  Text asText({
    Key? key,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    TextScaler? textScaler,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
    Color? selectionColor,
  }) => Text(
    this,
    key: key,
    style: style,
    strutStyle: strutStyle,
    textAlign: textAlign,
    textDirection: textDirection,
    locale: locale,
    softWrap: softWrap,
    overflow: overflow,
    textScaler: textScaler,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel,
    textWidthBasis: textWidthBasis,
    textHeightBehavior: textHeightBehavior,
    selectionColor: selectionColor,
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

/// Encapsulations about [Align] and its subclasses.
extension WrapAlignment on Widget {
  /// Wrap current widget with [Center].
  ///
  /// This getter is designed as a shortcut, especially for testing propose.
  /// and if there's necessary to apply some parameters to the [Center] widget,
  /// please use the [wrapCenter] or [align] extension method instead.
  Center get center => Center(child: this);

  /// Wrap current widget with [Align].
  Align align({
    Key? key,
    AlignmentGeometry alignment = Alignment.center,
    double? widthFactor,
    double? heightFactor,
  }) => Align(
    key: key,
    alignment: alignment,
    widthFactor: widthFactor,
    heightFactor: heightFactor,
    child: this,
  );

  /// Wrap current widget with [Center].
  ///
  /// This method provides all non-deprecated parameters of the [Center] widget.
  /// But it's strongly recommended to use [align] instead,
  /// because [Center] is exactly a subclass of [Align].
  /// It's only recommend to use this method if it's really necessary
  /// to make the return value match the [Center] type.
  /// And you may also consider the [center] getter,
  /// which might be more convenient for general situations.
  Center wrapCenter({Key? key, double? widthFactor, double? heightFactor}) =>
      Center(
        key: key,
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: this,
      );
}
