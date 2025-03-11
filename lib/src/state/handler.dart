/// Utilities about handling data in widget tree.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Extensions that helps to find inherited data in context.
extension FindContext on BuildContext {
  /// A shortcut to find inherited data in the context.
  T? find<T>() => dependOnInheritedWidgetOfExactType<Inherit<T>>()?.data;
}

/// Chain-style encapsulation for this library.
extension WrapHandlers on Widget {
  /// Inherit the data into widget tree.
  ///
  /// 1. This is an encapsulation of [Inherit] and [InheritedWidget].
  /// 2. You can find the handled [data] in the widget tree by context
  /// with the [FindContext.find] extension method like this:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   final data = context.find<T>()!;
  ///   ...
  /// }
  /// ```
  Inherit<T> inherit<T>(T data, {Key? key}) =>
      Inherit(key: key, data: data, child: this);
}

/// An encapsulation of [InheritedWidget] for code reuse.
///
/// This inherited class widget can simplify the code.
/// But the only identification for finding such handled [data]
/// is the type of [T], that it might be inconvenient in some cases.
class Inherit<T> extends InheritedWidget {
  /// Handle the [data] into the widget tree to inherit it.
  ///
  /// Then, you can find the handled [data] in the widget tree by the context
  /// with the [FindContext.find] extension method like this:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   final data = context.find<T>()!;
  ///   ...
  /// }
  /// ```
  const Inherit({required this.data, required super.child, super.key});

  /// The handle [data], which also specify the type of [T] in constructor.
  final T data;

  @override
  bool updateShouldNotify(covariant Inherit<T> oldWidget) =>
      data != oldWidget.data;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>('data', data));
  }
}
