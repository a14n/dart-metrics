// Copyright (c) 2014, Alexandre Ardhuin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:clock/clock.dart';
import 'package:metrics/metrics.dart';
import 'package:test/test.dart';

main() {
  test('a reservoir of 100 out of 1000 elements', () {
    final reservoir = ExponentiallyDecayingReservoir(100, 0.99);
    for (var i = 0; i < 1000; i++) {
      reservoir.update(i);
    }
    expect(reservoir.size, equals(100));
    expect(reservoir.snapshot.size, equals(100));
    _assertAllValuesBetween(reservoir, 0, 1000);
  });

  test('a reservoir of 100 out of 10 elements', () {
    final reservoir = ExponentiallyDecayingReservoir(100, 0.99);
    for (var i = 0; i < 10; i++) {
      reservoir.update(i);
    }
    expect(reservoir.size, equals(10));
    expect(reservoir.snapshot.size, equals(10));
    _assertAllValuesBetween(reservoir, 0, 10);
  });

  test('a heavily biased reservoir of 100 out of 1000 elements', () {
    final reservoir = ExponentiallyDecayingReservoir(1000, 0.01);
    for (var i = 0; i < 100; i++) {
      reservoir.update(i);
    }
    expect(reservoir.size, equals(100));
    expect(reservoir.snapshot.size, equals(100));
    _assertAllValuesBetween(reservoir, 0, 100);
  });

  test('long periods of inactivity should not corrupt sampling state', () {
    var millisecondsSinceEpoch = 0;
    final clock = Clock(
      () => DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
    );
    final reservoir = ExponentiallyDecayingReservoir(10, 0.015, clock);

    // add 1000 values at a rate of 10 values/second
    for (var i = 0; i < 1000; i++) {
      reservoir.update(1000 + i);
      millisecondsSinceEpoch += 100;
    }
    expect(reservoir.snapshot.size, equals(10));
    _assertAllValuesBetween(reservoir, 1000, 2000);

    // wait for 15 hours and add another value.
    // this should trigger a rescale. Note that the number of samples will be reduced to 2
    // because of the very small scaling factor that will make all existing priorities equal to
    // zero after rescale.
    millisecondsSinceEpoch += Duration(hours: 15).inMilliseconds;
    reservoir.update(2000);
    expect(reservoir.snapshot.size, equals(2));
    _assertAllValuesBetween(reservoir, 1000, 3000);

    // add 1000 values at a rate of 10 values/second
    for (var i = 0; i < 1000; i++) {
      reservoir.update(3000 + i);
      millisecondsSinceEpoch += 100;
    }
    expect(reservoir.snapshot.size, equals(10));
    _assertAllValuesBetween(reservoir, 3000, 4000);
  });

  test('spot lift', () {
    var millisecondsSinceEpoch = 0;
    final clock = Clock(
      () => DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
    );
    final reservoir = ExponentiallyDecayingReservoir(1000, 0.015, clock);

    final valuesRatePerMinute = 10;
    final valuesIntervalMillis =
        Duration.millisecondsPerMinute ~/ valuesRatePerMinute;
    // mode 1: steady regime for 120 minutes
    for (var i = 0; i < 120 * valuesRatePerMinute; i++) {
      reservoir.update(177);
      millisecondsSinceEpoch += valuesIntervalMillis;
    }

    // switching to mode 2: 10 minutes more with the same rate, but larger value
    for (var i = 0; i < 10 * valuesRatePerMinute; i++) {
      reservoir.update(9999);
      millisecondsSinceEpoch += valuesIntervalMillis;
    }

    // expect that quantiles should be more about mode 2 after 10 minutes
    expect(reservoir.snapshot.median, equals(9999));
  });

  test('spot fall', () {
    var millisecondsSinceEpoch = 0;
    final clock = Clock(
      () => DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
    );
    final reservoir = ExponentiallyDecayingReservoir(1000, 0.015, clock);

    final valuesRatePerMinute = 10;
    final valuesIntervalMillis =
        Duration.millisecondsPerMinute ~/ valuesRatePerMinute;
    // mode 1: steady regime for 120 minutes
    for (var i = 0; i < 120 * valuesRatePerMinute; i++) {
      reservoir.update(9998);
      millisecondsSinceEpoch += valuesIntervalMillis;
    }

    // switching to mode 2: 10 minutes more with the same rate, but smaller value
    for (var i = 0; i < 10 * valuesRatePerMinute; i++) {
      reservoir.update(178);
      millisecondsSinceEpoch += valuesIntervalMillis;
    }

    // expect that quantiles should be more about mode 2 after 10 minutes
    expect(reservoir.snapshot.get95thPercentile(), equals(178));
  });

  test('quantilies should be based on weights', () {
    var millisecondsSinceEpoch = 0;
    final clock = Clock(
      () => DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
    );
    final reservoir = ExponentiallyDecayingReservoir(1000, 0.015, clock);

    for (var i = 0; i < 40; i++) {
      reservoir.update(177);
    }

    millisecondsSinceEpoch += Duration(seconds: 120).inMilliseconds;

    for (var i = 0; i < 10; i++) {
      reservoir.update(9999);
    }

    expect(reservoir.snapshot.size, equals(50));

    // the first added 40 items (177) have weights 1
    // the next added 10 items (9999) have weights ~6
    // so, it's 40 vs 60 distribution, not 40 vs 10
    expect(reservoir.snapshot.median, equals(9999));
    expect(reservoir.snapshot.get75thPercentile(), equals(9999));
  });
}

void _assertAllValuesBetween(
    ExponentiallyDecayingReservoir reservoir, num min, num max) {
  for (num i in reservoir.snapshot.values) {
    expect(i, greaterThanOrEqualTo(min));
    expect(i, lessThan(max));
  }
}
