import 'package:mobx/mobx.dart';

/// `queueProcessor` takes an observable array, observes it and calls `processor`
///  once for each item added to the observable array, optionally debouncing the action
///
/// final pendingNotifications = ObservableList.of([]);
/// final stop = queueProcessor(pendingNotifications, (msg) {
///  // show Desktop notification
///  return Notification(msg);
/// });
///
/// usage:
/// pendingNotifications.add("test!");
///
/// [observableList] - [ObservableList] instance to track
/// [processor] - action to call per item
/// [debounce] optional debounce time in ms. With debounce 0 the processor will run synchronously
ReactionDisposer queueProcessor<T>(
  ObservableList<T> observableList,
  Function(T item) processor, {
  int debounce = 0,
}) {
  final _processor = Action(processor, name: 'queueProcessor');

  void _runner (_) {
    final items = List.of(observableList);
    // clear the queue for next iteration
    runInAction(() => observableList.clear());
    // fire processor
    for (var item in items) {
      _processor.call([item]);
    }
  }
  if (debounce > 0) {
    return autorun(_runner, delay: debounce);
  } else {
    return autorun(_runner);
  }
}
