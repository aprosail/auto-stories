/// Utilities about handling data in widget tree.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Extensions that helps to find inherited data in context.
extension FindContext on BuildContext {
  /// A shortcut to find inherited data in the context.
  T? find<T>() => dependOnInheritedWidgetOfExactType<Inherit<T>>()?.data;

  /// Find the nearest [InheritUpdater] with specified type [T] in the context.
  /// You may consider [update], [trigger], [maybeUpdate] or [maybeTrigger],
  /// which is more direct and convenient than this method.
  InheritUpdater<T>? findUpdater<T>() =>
      dependOnInheritedWidgetOfExactType<InheritUpdater<T>>();

  /// Update the handled [data] in context if possible,
  /// and if such [Handler] doesn't exist, it will do nothing.
  void maybeUpdate<T>(T data) => findUpdater<T>()?.update(data);

  /// Trigger the handled callback of [data] in context if possible,
  /// even if the value of [data] won't change.
  /// If such [Handler] doesn't exist, it will do nothing.
  void maybeTrigger<T>(T data) => findUpdater<T>()?.trigger(data);

  /// Update the handled [data] in context.
  /// And if there's not such inherit, the type assertion will fail.
  void update<T>(T data) => findUpdater<T>()!.update(data);

  /// Trigger the handled callback of [data] in context,
  /// even if the value of [data] won't change.
  /// And if there's not such inherit, the type assertion will fail.
  void trigger<T>(T data) => findUpdater<T>()!.trigger(data);
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

  /// Handle a data in the widget tree.
  ///
  /// Once the data updated, no matter from its ancestor or descendant,
  /// all corresponding widgets inherited from the [data] will be updated,
  /// and if the [onChange] action is specified, it will be triggered.
  ///
  /// 1. The [data] had already been inherited, which you can get from context
  /// like this:
  ///
  /// ```dart
  /// final XXX data = context.find<XXX>()!;
  /// ```
  ///
  /// 2. You can update the handled [data] like this:
  ///
  /// ```dart
  /// context.maybeUpdate(data); // Not sure whether handled.
  /// context.update(data); // Sure handled.
  /// ```
  ///
  /// 3. If the handled [data] is not sure to change,
  /// but you want to ensure the callback must be triggered,
  /// you can code like this:
  ///
  /// ```dart
  /// context.maybeTrigger(data); // Not sure whether handled.
  /// context.trigger(data); // Sure handled.
  /// ```
  ///
  /// ## Attention
  ///
  /// It's not allowed to use [num] ([int] and [double]) here
  /// because it might cause unsafe variance, which might break the program.
  /// If you do need to use such types, please encapsulate them with a class.
  Handler<T> handle<T>(T data, {Key? key, void Function(T data)? onChange}) =>
      Handler(key: key, onChange: onChange, data: data, child: this);
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

  /// The handled [data], which also specify the type of [T] in constructor.
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

/// Handler of a data in the widget tree.
///
/// You can either update the data from its ancestor and descendant.
class Handler<T> extends StatefulWidget {
  /// Handle a data in the widget tree.
  ///
  /// Once the data updated, no matter from its ancestor or descendant,
  /// all corresponding widgets inherited from the [data] will be updated,
  /// and if the [onChange] action is specified, it will be triggered.
  ///
  /// 1. The [data] had already been inherited, which you can get from context
  /// like this:
  ///
  /// ```dart
  /// final XXX data = context.find<XXX>()!;
  /// ```
  ///
  /// 2. You can update the handled [data] like this:
  ///
  /// ```dart
  /// context.maybeUpdate(data); // Not sure whether handled.
  /// context.update(data); // Sure handled.
  /// ```
  ///
  /// 3. If the handled [data] is not sure to change,
  /// but you want to ensure the callback must be triggered,
  /// you can code like this:
  ///
  /// ```dart
  /// context.maybeTrigger(data); // Not sure whether handled.
  /// context.trigger(data); // Sure handled.
  /// ```
  ///
  /// ## Attention
  ///
  /// It's not allowed to use [num] ([int] and [double]) here
  /// because it might cause unsafe variance, which might break the program.
  /// If you do need to use such types, please encapsulate them with a class.
  const Handler({
    required this.data,
    required this.child,
    super.key,
    this.onChange,
  }) : assert(T is! num);

  /// The callback to be triggered once the handled [data] changed.
  // ignore: unsafe_variance assert and doc not to use num.
  final void Function(T data)? onChange;

  /// The handled [data], which also specify the type of [T] in constructor.
  final T data;

  /// The child that inherit such [data], and can update such [data].
  final Widget child;

  @override
  State<Handler<T>> createState() => _HandlerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<T>('data', data))
      ..add(
        ObjectFlagProperty<void Function(T data)?>.has('onChange', onChange),
      );
  }
}

class _HandlerState<T> extends State<Handler<T>> {
  late T _data = widget.data;

  /// Update the [_data] and [trigger] only if the data has changed.
  void update(T data) {
    if (_data != data) trigger(data);
  }

  /// Trigger corresponding actions and set states
  /// no matter whether the data has changed or not.
  void trigger(T data) {
    setState(() => _data = data);
    widget.onChange?.call(data);
  }

  @override
  void didUpdateWidget(covariant Handler<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    update(widget.data);
  }

  @override
  Widget build(BuildContext context) => Inherit(
    data: _data,
    child: InheritUpdater<T>(
      update: update,
      trigger: trigger,
      child: widget.child,
    ),
  );
}

/// An encapsulation of [InheritedWidget] for code reuse.
///
/// Like [Inherit], but this widget is designed specially for the [Handler].
/// It will inherit the update callback,
/// and as the callback will be a static method,
class InheritUpdater<T> extends InheritedWidget {
  /// An updater for updating the [Handler] in the widget tree.
  /// This class is designed for code reuse.
  /// It's usually only used with the [Handler].
  ///
  /// ## Attention
  ///
  /// It's not allowed to use [num] ([int] and [double]) here
  /// because it might cause unsafe variance, which might break the program.
  /// If you do need to use such types, please encapsulate them with a class.
  const InheritUpdater({
    required this.update,
    required this.trigger,
    required super.child,
    super.key,
  }) : assert(T is! num);

  /// Call this function parameter to update the handled data
  /// and [trigger] corresponding callbacks if data has changed.
  // ignore: unsafe_variance assert and doc not to use num.
  final void Function(T data) update;

  /// Trigger all corresponding callbacks and update the data
  /// no matter whether the data has changed or not.
  // ignore: unsafe_variance assert and doc not to use num.
  final void Function(T data) trigger;

  @override
  bool updateShouldNotify(covariant InheritUpdater<T> oldWidget) => false;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ObjectFlagProperty<void Function(T data)>.has('update', update))
      ..add(ObjectFlagProperty<void Function(T data)>.has('trigger', trigger));
  }
}
