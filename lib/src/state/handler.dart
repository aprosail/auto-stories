import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Extensions that helps to find inherited data in context.
extension FindContext on BuildContext {
  /// A shortcut to find inherited data in the context.
  T? find<T>() => dependOnInheritedWidgetOfExactType<Inherit<T>>()?.data;
}

/// An encapsulation of [InheritedWidget] for code reuse.
class Inherit<T> extends InheritedWidget {
  /// Handle the [data] into the widget tree to inherit it.
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
