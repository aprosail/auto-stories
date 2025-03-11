/// Syntax sugar and utilities to support chain-style programming in Flutter.
///
/// Widget nesting might make the code hard to read and inconvenient to modify.
/// The chain-style programming can make the codebase
/// more readable and maintainable.
/// For example:
///
/// Before:
///
/// ```dart
/// import 'package:flutter/widgets.dart';
/// ...
/// class Example extends StatelessWidget {
///   const Example({super.key});
/// ...
///   @override
///   Widget build(BuildContext context) => MediaQuery(
///     data: MediaQueryData.fromView(View.of(context)),
///     child: const Directionality(
///       textDirection: TextDirection.ltr,
///       child: Center(
///         child: Text('message')
///       ),
///     ),
///   );
/// }
/// ```
///
/// After:
///
/// ```dart
/// import 'package:auto_stories/auto_stories.dart';
/// import 'package:flutter/widgets.dart';
/// ...
/// class Example extends StatelessWidget {
///   const Example({super.key});
/// ...
///   @override
///   Widget build(BuildContext context) => 'message'.text.center
///       .textDirection(TextDirection.ltr)
///       .media(MediaQueryData.fromView(View.of(context)));
/// }
/// ```
///
/// But attention that those method and getter encapsulations will
/// prevent the builders from using `const` modifier.
/// Please consider it in performance sensitive scenarios.
///
/// @docImport 'package:flutter/cupertino.dart';
/// @docImport 'package:flutter/material.dart';
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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

/// Encapsulation for gestures and mouse interactions.
extension WrapInteract on Widget {
  /// Wrap current widget with a [GestureDetector].
  GestureDetector gesture({
    Key? key,

    // Tap.
    void Function(TapDownDetails details)? onTapDown,
    void Function(TapUpDetails details)? onTapUp,
    void Function()? onTap,
    void Function()? onTapCancel,

    // Secondary tap.
    void Function()? onSecondaryTap,
    void Function(TapDownDetails details)? onSecondaryTapDown,
    void Function(TapUpDetails details)? onSecondaryTapUp,
    void Function()? onSecondaryTapCancel,

    // Tertiary tap.
    void Function(TapDownDetails details)? onTertiaryTapDown,
    void Function(TapUpDetails details)? onTertiaryTapUp,
    void Function()? onTertiaryTapCancel,

    // Double tap.
    void Function(TapDownDetails details)? onDoubleTapDown,
    void Function()? onDoubleTap,
    void Function()? onDoubleTapCancel,

    // Long press.
    void Function(LongPressDownDetails details)? onLongPressDown,
    void Function()? onLongPressCancel,
    void Function()? onLongPress,
    void Function(LongPressStartDetails details)? onLongPressStart,
    void Function(LongPressMoveUpdateDetails details)? onLongPressMoveUpdate,
    void Function()? onLongPressUp,
    void Function(LongPressEndDetails details)? onLongPressEnd,

    // Secondary long press.
    void Function(LongPressDownDetails details)? onSecondaryLongPressDown,
    void Function()? onSecondaryLongPressCancel,
    void Function()? onSecondaryLongPress,
    void Function(LongPressStartDetails details)? onSecondaryLongPressStart,
    void Function(LongPressMoveUpdateDetails details)?
    onSecondaryLongPressMoveUpdate,
    void Function()? onSecondaryLongPressUp,
    void Function(LongPressEndDetails details)? onSecondaryLongPressEnd,

    // Tertiary long press.
    void Function(LongPressDownDetails details)? onTertiaryLongPressDown,
    void Function()? onTertiaryLongPressCancel,
    void Function()? onTertiaryLongPress,
    void Function(LongPressStartDetails details)? onTertiaryLongPressStart,
    void Function(LongPressMoveUpdateDetails details)?
    onTertiaryLongPressMoveUpdate,
    void Function()? onTertiaryLongPressUp,
    void Function(LongPressEndDetails details)? onTertiaryLongPressEnd,

    // Vertical drag.
    void Function(DragDownDetails details)? onVerticalDragDown,
    void Function(DragStartDetails details)? onVerticalDragStart,
    void Function(DragUpdateDetails details)? onVerticalDragUpdate,
    void Function(DragEndDetails details)? onVerticalDragEnd,
    void Function()? onVerticalDragCancel,

    // Horizontal drag.
    void Function(DragDownDetails details)? onHorizontalDragDown,
    void Function(DragStartDetails details)? onHorizontalDragStart,
    void Function(DragUpdateDetails details)? onHorizontalDragUpdate,
    void Function(DragEndDetails details)? onHorizontalDragEnd,
    void Function()? onHorizontalDragCancel,

    // Force press.
    void Function(ForcePressDetails details)? onForcePressStart,
    void Function(ForcePressDetails details)? onForcePressPeak,
    void Function(ForcePressDetails details)? onForcePressUpdate,
    void Function(ForcePressDetails details)? onForcePressEnd,

    // Pan.
    void Function(DragDownDetails details)? onPanDown,
    void Function(DragStartDetails details)? onPanStart,
    void Function(DragUpdateDetails details)? onPanUpdate,
    void Function(DragEndDetails details)? onPanEnd,
    void Function()? onPanCancel,

    // Scale.
    void Function(ScaleStartDetails details)? onScaleStart,
    void Function(ScaleUpdateDetails details)? onScaleUpdate,
    void Function(ScaleEndDetails details)? onScaleEnd,

    // Configurations.
    HitTestBehavior? behavior,
    bool excludeFromSemantics = false,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    bool trackpadScrollCausesScale = false,
    Offset trackpadScrollToScaleFactor = kDefaultTrackpadScrollToScaleFactor,
    Set<PointerDeviceKind>? supportedDevices,
  }) => GestureDetector(
    key: key,

    // Tap.
    onTapDown: onTapDown,
    onTapUp: onTapUp,
    onTap: onTap,
    onTapCancel: onTapCancel,

    // Secondary Tap.
    onSecondaryTap: onSecondaryTap,
    onSecondaryTapDown: onSecondaryTapDown,
    onSecondaryTapUp: onSecondaryTapUp,
    onSecondaryTapCancel: onSecondaryTapCancel,

    // Tertiary Tap.
    onTertiaryTapDown: onTertiaryTapDown,
    onTertiaryTapUp: onTertiaryTapUp,
    onTertiaryTapCancel: onTertiaryTapCancel,

    // Double Tap.
    onDoubleTapDown: onDoubleTapDown,
    onDoubleTap: onDoubleTap,
    onDoubleTapCancel: onDoubleTapCancel,

    // Long press.
    onLongPressDown: onLongPressDown,
    onLongPressCancel: onLongPressCancel,
    onLongPress: onLongPress,
    onLongPressStart: onLongPressStart,
    onLongPressMoveUpdate: onLongPressMoveUpdate,
    onLongPressUp: onLongPressUp,
    onLongPressEnd: onLongPressEnd,

    // Secondary long press.
    onSecondaryLongPressDown: onSecondaryLongPressDown,
    onSecondaryLongPressCancel: onSecondaryLongPressCancel,
    onSecondaryLongPress: onSecondaryLongPress,
    onSecondaryLongPressStart: onSecondaryLongPressStart,
    onSecondaryLongPressMoveUpdate: onSecondaryLongPressMoveUpdate,
    onSecondaryLongPressUp: onSecondaryLongPressUp,
    onSecondaryLongPressEnd: onSecondaryLongPressEnd,

    // Tertiary long press.
    onTertiaryLongPressDown: onTertiaryLongPressDown,
    onTertiaryLongPressCancel: onTertiaryLongPressCancel,
    onTertiaryLongPress: onTertiaryLongPress,
    onTertiaryLongPressStart: onTertiaryLongPressStart,
    onTertiaryLongPressMoveUpdate: onTertiaryLongPressMoveUpdate,
    onTertiaryLongPressUp: onTertiaryLongPressUp,
    onTertiaryLongPressEnd: onTertiaryLongPressEnd,

    // Vertical drag.
    onVerticalDragDown: onVerticalDragDown,
    onVerticalDragStart: onVerticalDragStart,
    onVerticalDragUpdate: onVerticalDragUpdate,
    onVerticalDragEnd: onVerticalDragEnd,
    onVerticalDragCancel: onVerticalDragCancel,

    // Horizontal drag.
    onHorizontalDragDown: onHorizontalDragDown,
    onHorizontalDragStart: onHorizontalDragStart,
    onHorizontalDragUpdate: onHorizontalDragUpdate,
    onHorizontalDragEnd: onHorizontalDragEnd,
    onHorizontalDragCancel: onHorizontalDragCancel,

    // Force press.
    onForcePressStart: onForcePressStart,
    onForcePressPeak: onForcePressPeak,
    onForcePressUpdate: onForcePressUpdate,
    onForcePressEnd: onForcePressEnd,

    // Pan.
    onPanDown: onPanDown,
    onPanStart: onPanStart,
    onPanUpdate: onPanUpdate,
    onPanEnd: onPanEnd,
    onPanCancel: onPanCancel,

    // Scale.
    onScaleStart: onScaleStart,
    onScaleUpdate: onScaleUpdate,
    onScaleEnd: onScaleEnd,

    // Configurations.
    behavior: behavior,
    excludeFromSemantics: excludeFromSemantics,
    dragStartBehavior: dragStartBehavior,
    trackpadScrollCausesScale: trackpadScrollCausesScale,
    trackpadScrollToScaleFactor: trackpadScrollToScaleFactor,
    supportedDevices: supportedDevices,

    child: this,
  );
}
