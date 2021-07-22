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

import 'package:test/test.dart';
import 'package:metrics/metrics.dart';
import 'package:metrics/test/manual_clock.dart';

main() {
  for (var ratePerMinute in [15, 60, 600, 6000]) {
    group('at rate of $ratePerMinute', () {
      test('control meter 1 minute mean approximation', () {
        final Meter meter = _simulateMetronome(
            const Duration(milliseconds: 62934),
            const Duration(minutes: 3),
            ratePerMinute);

        expect(meter.oneMinuteRate * 60,
            closeTo(ratePerMinute, 0.1 * ratePerMinute));
      });

      test('control meter 5 minute mean approximation', () {
        final Meter meter = _simulateMetronome(
            const Duration(milliseconds: 62934),
            const Duration(minutes: 13),
            ratePerMinute);

        expect(meter.fiveMinuteRate * 60,
            closeTo(ratePerMinute, 0.1 * ratePerMinute));
      });

      test('control meter 15 minute mean approximation', () {
        final Meter meter = _simulateMetronome(
            const Duration(milliseconds: 62934),
            const Duration(minutes: 38),
            ratePerMinute);

        expect(meter.fifteenMinuteRate * 60,
            closeTo(ratePerMinute, 0.1 * ratePerMinute));
      });
    });
  }
}

Meter _simulateMetronome(
    Duration introDelay, Duration duration, int ratePerMinute) {
  final clock = ManualClock();
  final meter = Meter(clock);

  clock.addMicros(introDelay.inMicroseconds);

  final endTick = clock.tick + duration.inMicroseconds;
  final marksIntervalInMicros = Duration.microsecondsPerMinute ~/ ratePerMinute;

  while (clock.tick <= endTick) {
    clock.addMicros(marksIntervalInMicros);
    meter.mark();
  }

  return meter;
}
