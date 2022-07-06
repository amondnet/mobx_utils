import 'package:mobx/mobx.dart';

abstract class LazyObservable<T> {
  T? get current;

  T? refresh();

  T? reset();

  bool get pending;
}

/// `lazyObservable` creates an observable around a `fetch` method that will not be invoked
/// until the observable is needed the first time.
/// The fetch method receives a `sink` callback which can be used to replace the
/// current value of the lazyObservable. It is allowed to call `sink` multiple times
/// to keep the lazyObservable up to date with some external resource.
///
/// Note that it is the `current()` call itself which is being tracked by MobX,
/// so make sure that you don't dereference to early.
LazyObservable<T> lazyObservable<T>(
  Function(Function(T newValue) sink) fetch,
  T? initialValue,
) {
  var started = false;
  final value = Observable(initialValue);
  final pending = Observable(false);

  T? currentFnc() {
    if (!started) {
      started = true;
      runInAction(() {
        pending.value = true;
      });
      fetch((T newValue) {
        runInAction(() {
          value.value = newValue;
          pending.value = false;
        });
      });
    }
    return value.value;
  }

  ;

  var resetFnc = Action(
    () {
      started = false;
      value.value = initialValue;
      return value.value;
    },
    name: 'lazyObservable-reset',
  );

  return _LazyObservable(
      currentFnc: currentFnc,
      refreshFnc: () {
        if (started) {
          started = false;
          return currentFnc();
        } else {
          return value.value;
        }
      },
      resetFnc: () {
        return resetFnc();
      },
      pendingFnc: () {
        return pending.value;
      });
}

class _LazyObservable<T> extends LazyObservable<T> {
  final T? Function() currentFnc;
  final T? Function() refreshFnc;
  final T? Function() resetFnc;

  final bool Function() pendingFnc;

  _LazyObservable(
      {required this.currentFnc,
      required this.refreshFnc,
      required this.resetFnc,
      required this.pendingFnc});

  @override
  T? get current => currentFnc();

  @override
  bool get pending => pendingFnc();

  @override
  T? refresh() => refreshFnc();

  @override
  T? reset() => resetFnc();
}
