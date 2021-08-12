import 'package:flutter/material.dart';
import 'package:goribernetflix/deferred.dart';

typedef ResponseWidgetBuilder<T> = Widget Function(
    BuildContext context, Deferred<T> response);

class FutureBuilder2<T> extends StatefulWidget {
  /// Creates a widget that builds itself based on the latest snapshot of
  /// interaction with a [Future].
  ///
  /// The [builder] must not be null.
  const FutureBuilder2({
    Key? key,
    this.future,
    this.initialData,
    required this.builder,
  }) : super(key: key);

  /// The asynchronous computation to which this builder is currently connected,
  /// possibly null.
  ///
  /// If no future has yet completed, including in the case where [future] is
  /// null, the data provided to the [builder] will be set to [initialData].
  final Future<T>? future;

  /// The build strategy currently used by this builder.
  ///
  /// The builder is provided with an [AsyncSnapshot] object whose
  /// [AsyncSnapshot.connectionState] property will be one of the following
  /// values:
  ///
  ///  * [ConnectionState.none]: [future] is null. The [AsyncSnapshot.data] will
  ///    be set to [initialData], unless a future has previously completed, in
  ///    which case the previous result persists.
  ///
  ///  * [ConnectionState.waiting]: [future] is not null, but has not yet
  ///    completed. The [AsyncSnapshot.data] will be set to [initialData],
  ///    unless a future has previously completed, in which case the previous
  ///    result persists.
  ///
  ///  * [ConnectionState.done]: [future] is not null, and has completed. If the
  ///    future completed successfully, the [AsyncSnapshot.data] will be set to
  ///    the value to which the future completed. If it completed with an error,
  ///    [AsyncSnapshot.hasError] will be true and [AsyncSnapshot.error] will be
  ///    set to the error object.
  ///
  /// This builder must only return a widget and should not have any side
  /// effects as it may be called multiple times.
  final ResponseWidgetBuilder<T> builder;

  /// The data that will be used to create the snapshots provided until a
  /// non-null [future] has completed.
  ///
  /// If the future completes with an error, the data in the [AsyncSnapshot]
  /// provided to the [builder] will become null, regardless of [initialData].
  /// (The error itself will be available in [AsyncSnapshot.error], and
  /// [AsyncSnapshot.hasError] will be true.)
  final T? initialData;

  @override
  State<FutureBuilder2<T>> createState() => _FutureBuilder2State<T>();
}

/// State for [FutureBuilder2].
class _FutureBuilder2State<T> extends State<FutureBuilder2<T>> {
  /// An object that identifies the currently active callbacks. Used to avoid
  /// calling setState from stale callbacks, e.g. after disposal of this state,
  /// or after widget reconfiguration to a new Future.
  Object? _activeCallbackIdentity;
  late Deferred<T> _result;

  @override
  void initState() {
    super.initState();
    _result = widget.initialData == null
        ? Deferred<T>.idle() // might be changed
        : Deferred<T>.success(widget.initialData as T);
    _subscribe();
  }

  @override
  void didUpdateWidget(FutureBuilder2<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.future != widget.future) {
      if (_activeCallbackIdentity != null) {
        _unsubscribe();
        _result = Deferred<T>.idle();
      }
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _result);

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (widget.future != null) {
      final Object callbackIdentity = Object();
      _activeCallbackIdentity = callbackIdentity;
      widget.future!.then<void>((T data) {
        if (_activeCallbackIdentity == callbackIdentity) {
          setState(() {
            _result = Deferred<T>.success(data);
          });
        }
      }, onError: (Object error, StackTrace stackTrace) {
        if (_activeCallbackIdentity == callbackIdentity) {
          setState(() {
            _result = Deferred<T>.error(error, stackTrace);
          });
        }
      });
      _result = Deferred<T>.inProgress();
    }
  }

  void _unsubscribe() {
    _activeCallbackIdentity = null;
  }
}
