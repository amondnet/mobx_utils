import 'package:fake_async/fake_async.dart';
import 'package:mobx/mobx.dart';
import 'package:mobx_utils/src/queue_processor.dart';
import 'package:test/test.dart';

void main() {
  test('sync processor should work', () {
    final q = ObservableList.of([1, 2]);
    final res = [];

    final stop = queueProcessor<int>(q, (v) => res.add(v * 2));

    expect(res, [2, 4]);
    expect(q, isEmpty);

    runInAction(() => q.add(3));
    expect(res, [2, 4, 6]);

    runInAction(() => q.addAll([4, 5]));
    expect(q, isEmpty);
    expect(res, [2, 4, 6, 8, 10]);

    runInAction(() {
      q.insertAll(0, [6, 7]);
      expect(q.length, 2);
      expect(res, [2, 4, 6, 8, 10]);
    });

    expect(q, isEmpty);
    expect(res, [2, 4, 6, 8, 10, 12, 14]);

    stop();
    runInAction(() => q.add(42));
    expect(q.length, 1);
    expect(res, [2, 4, 6, 8, 10, 12, 14]);
  });

  test('async processor should work', () {
    fakeAsync((async) {
      final q = ObservableList.of([1, 2]);
      final res = [];

      final stop = queueProcessor<int>(q, (v) => res.add(v * 2), debounce: 10);

      expect(res, isEmpty);
      expect(q.length, 2);

      async.elapse(Duration(milliseconds: 50));
      expect(res, [2, 4]);
      expect(q, isEmpty);

      runInAction(() => q.add(3));
      expect(q.length, 1);
      expect(res, [2, 4]);

      async.elapse(Duration(milliseconds: 50));
      expect(q, isEmpty);
      expect(res, [2, 4, 6]);

      stop();
    });
  });
}
