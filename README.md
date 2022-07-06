# MobX-utils

Utility functions and common patterns for MobX

This package provides utility functions and common MobX patterns build on top of MobX. It is encouraged to take a peek under the hood and read the sources of these utilities. Feel free to open a PR with your own utilities. For large new features, please open an issue first.

# API

## lazyObservable

`lazyObservable` creates an observable around a `fetch` method that will not be invoked until the observable is needed the first time. The fetch method receives a `sink` callback which can be used to replace the current value of the lazyObservable. It is allowed to call `sink` multiple times to keep the lazyObservable up to date with some external resource.

Note that it is the `current` call itself which is being tracked by MobX, so make sure that you don't dereference to early.

### Examples
```dart
final userProfile = lazyObservable(
    (sink) => fetch("/myprofile").then((profile) => sink(profile))
);

// use the userProfile in a Flutter widget:
const profile = Observer(builder: (_) =>
  userProfile.current == null
  ? Text('Loading user profile')
  : Text(userProfile.current.displayName)
);

// triggers refresh the userProfile
userProfile.refresh();
```

## queueProcessor

`queueProcessor` takes an `ObservableList`, observes it and calls `processor` once for each item added to the observable array, optionally debouncing the action

### Examples

```dart
final pendingNotifications = ObservableList.of([]);
final stop = queueProcessor(pendingNotifications, (msg) {
  // show Desktop notification
  return Notification(msg);
});

// usage:
pendingNotifications.add("test!");
```

Returns ReactionDisposer stops the processor



