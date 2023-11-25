import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:mobx/mobx.dart';
import 'package:mobx_utils/src/lazy_observables.dart';
import 'package:test/test.dart';

void main() {
  test('lazy observable should work', () {
    fakeAsync((async) {
      var started = false;
      final lo = lazyObservable<int>((sink) {
        started = true;
        Future.delayed(Duration(seconds: 5), () => sink(4));
        Future.delayed(Duration(seconds: 10), () => sink(5));
        Future.delayed(Duration(seconds: 15), () => sink(6));
      }, 3);

      final values = [];
      expect(started, isFalse);
      lo.refresh();
      expect(started, isFalse);

      autorun((_) => values.add(lo.current));

      expect(started, isTrue);
      expect(values, [3]);
      expect(lo.current, 3);

      async.elapse(Duration(seconds: 16));

      expect(lo.current, 6);
      expect(values, [3, 4, 5, 6]);
    });
  });

  test('lazy observable refresh', () {
    fakeAsync((async) {
      var started = 0;
      var i = 10;

      future() async {
        started = started + 1;
        return i++;
      }

      final lo = lazyObservable<int>((sink) async {
        future().then((value) => sink(value));
      }, 1);

      var values = [];
      autorun((_) => values.add(lo.current));

      expect(started, 1);
      expect(values, [1]);
      expect(lo.current, 1);

      Future.delayed(Duration(seconds: 50), lo.refresh);

      async.elapse(Duration(seconds: 51));

      expect(started, 2);
      expect(lo.current, 11);
      expect(values, [1, 10, 11]);
    });
  });

  test('lazy observable reset', () {
    fakeAsync((async) {
      final lo = lazyObservable<int>((sink) {
        Future.value(2).then((value) => sink(value));
      }, 1);

      lo.current;

      async.elapse(Duration(milliseconds: 50));

      expect(lo.current, 2);

      lo.reset();
      expect(lo.current, 1);

      async.elapse(Duration(milliseconds: 250));
      expect(lo.current, 2);
    });
  });

  test('lazy observable pending', () {
    fakeAsync((async) {
      final lo = lazyObservable<dynamic>((sink) {
        Future.delayed(Duration(seconds: 100), () {})
            .then((value) => sink(value));
      }, null);

      expect(lo.pending, false);

      lo.current;
      expect(lo.pending, true);

      async.elapse(Duration(seconds: 150));
      expect(lo.pending, false);
    });
  });

  test('lazy observable pending can be observed', () {
    sleep(ms) => Future.delayed(Duration(milliseconds: ms), () {});

    fakeAsync((async) {
      final lo = lazyObservable<dynamic>((sink) {
        sleep(100).then((value) => sink(value));
      }, null);

      final pendingValues = [];

      autorun((_) => pendingValues.add(lo.pending));

      lo.current;

      async.elapse(Duration(seconds: 150));

      expect(pendingValues, [false, true, false]);
    });
  });

  test('lazy observable pending can be observed', () {
    fakeAsync((async) {
      sleep(ms) => Future.delayed(Duration(milliseconds: ms), () {});

      final lo = lazyObservable<dynamic>((sink) {
        sleep(100).then((value) => sink(value));
      }, null);

      final pendingValues = [];

      autorun((_) => pendingValues.add(lo.pending));

      lo.current;
      async.elapse(Duration(milliseconds: 150));

      expect(pendingValues, [false, true, false]);
    });
  });
}
