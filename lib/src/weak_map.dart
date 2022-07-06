class WeakMap<K, V> {
  final Map<K, V> _map;
  Expando _expando;

  WeakMap()
      : _map = {},
        _expando = Expando();

  static bool _allowedInExpando(Object? value) =>
      value is! String && value is! num && value is! bool && value != null;

  void operator []=(K key, V value) => add(key: key, value: value);

  /// Returns the value associated with this key, or null if the key doesn't exist in the map.
  /// Note this can't differentiate between the key not existing and the value being null.
  ///
  /// This is the same as using the [get] method.
  ///
  V? operator [](K key) => get(key);

  void add({required K key, required V value}) {
    if (_allowedInExpando(key)) {
      _expando[key!] = value;
    } else {
      _map[key] = value;
    }
  }

  bool contains(K key) => get(key) != null;

  /// Returns the value associated with this key, or null if the key doesn't exist in the map.
  /// Note this can't differentiate between the key not existing and the value being null.
  ///
  /// This is the same as using the [] operator.
  ///
  V? get(K key) => _map.containsKey(key)
      ? //
      _map[key]
      : (_allowedInExpando(key) ? _expando[key!] as V : null);

  /// Returns the value associated with this key.
  /// It will throw if the key doesn't exist in the map.
  /// Note this may only return null if V is nullable.
  ///
  /// This is the same as using the [] operator.
  ///
  V getOrThrow(K key) {
    if (_map.containsKey(key)) {
      return _map[key] as V;
    } else {
      if (_allowedInExpando(key)) {
        return _expando[key!] as V;
      } else {
        throw StateError("No value for key.");
      }
    }
  }

  void remove(K key) {
    _map.remove(key);

    if (_allowedInExpando(key)) {
      _expando[key!] = null;
    }
  }

  void clear() {
    _map.clear();
    _expando = Expando();
  }
}
