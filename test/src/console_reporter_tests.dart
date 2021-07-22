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

library metrics.console_reporter_test;

import 'package:test/test.dart';
import 'package:metrics/metrics.dart';
import 'package:mocktail/mocktail.dart';

import '../lib/mocks.dart';

main() {
  group('', () {
    late StringBuffer output;
    late ConsoleReporter reporter;
    final DateTime datetime =
        DateTime.fromMillisecondsSinceEpoch(1363568676000);

    setUp(() {
      final registry = MockMetricRegistry();
      final clock = MockClock();
      when(() => clock.time).thenReturn(datetime.millisecondsSinceEpoch);

      output = StringBuffer();
      reporter = ConsoleReporter(registry, output: output, clock: clock);
    });

    test('reports gauge values', () {
      final gauge = MockGauge();
      when(() => gauge.value).thenReturn(1);

      reporter.reportMetrics(gauges: {'gauge': gauge});

      expect(output.toString(), equals('''
${datetime.toIso8601String()} ========================================================

-- Gauges ----------------------------------------------------------------------
gauge
             value = 1


'''));
    });

    test('reports counter values', () {
      final counter = MockCounter();
      when(() => counter.count).thenReturn(100);

      reporter.reportMetrics(counters: {'test.counter': counter});

      expect(output.toString(), equals('''
${datetime.toIso8601String()} ========================================================

-- Counters --------------------------------------------------------------------
test.counter
             count = 100


'''));
    });

    test('reports histogram values', () {
      final histogram = MockHistogram();
      when(() => histogram.count).thenReturn(1);

      final snapshot = MockSnapshot();
      when(() => snapshot.max).thenReturn(2);
      when(() => snapshot.mean).thenReturn(3.0);
      when(() => snapshot.min).thenReturn(4);
      when(() => snapshot.stdDev).thenReturn(5.0);
      when(() => snapshot.median).thenReturn(6.0);
      when(() => snapshot.get75thPercentile()).thenReturn(7.0);
      when(() => snapshot.get95thPercentile()).thenReturn(8.0);
      when(() => snapshot.get98thPercentile()).thenReturn(9.0);
      when(() => snapshot.get99thPercentile()).thenReturn(10.0);
      when(() => snapshot.get999thPercentile()).thenReturn(11.0);

      when(() => histogram.snapshot).thenReturn(snapshot);

      reporter.reportMetrics(histograms: {'test.histogram': histogram});

      expect(output.toString(), equals('''
${datetime.toIso8601String()} ========================================================

-- Histograms ------------------------------------------------------------------
test.histogram
             count = 1
               min = 4
               max = 2
              mean = 3.00
            stddev = 5.00
            median = 6.00
              75% <= 7.00
              95% <= 8.00
              98% <= 9.00
              99% <= 10.00
            99.9% <= 11.00


'''));
    });

    test('reports meter values', () {
      final meter = MockMeter();
      when(() => meter.count).thenReturn(1);
      when(() => meter.meanRate).thenReturn(2.0);
      when(() => meter.oneMinuteRate).thenReturn(3.0);
      when(() => meter.fiveMinuteRate).thenReturn(4.0);
      when(() => meter.fifteenMinuteRate).thenReturn(5.0);

      reporter.reportMetrics(meters: {'test.meter': meter});

      expect(output.toString(), equals('''
${datetime.toIso8601String()} ========================================================

-- Meters ----------------------------------------------------------------------
test.meter
             count = 1
         mean rate = 2.00 events/second
     1-minute rate = 3.00 events/second
     5-minute rate = 4.00 events/second
    15-minute rate = 5.00 events/second


'''));
    });

    test('reports timer values', () {
      final timer = MockTimer();
      when(() => timer.count).thenReturn(1);
      when(() => timer.meanRate).thenReturn(2.0);
      when(() => timer.oneMinuteRate).thenReturn(3.0);
      when(() => timer.fiveMinuteRate).thenReturn(4.0);
      when(() => timer.fifteenMinuteRate).thenReturn(5.0);

      final snapshot = MockSnapshot();
      when(() => snapshot.max)
          .thenReturn(const Duration(milliseconds: 100).inMicroseconds);
      when(() => snapshot.mean).thenReturn(
          const Duration(milliseconds: 200).inMicroseconds.toDouble());
      when(() => snapshot.min)
          .thenReturn(const Duration(milliseconds: 300).inMicroseconds);
      when(() => snapshot.stdDev).thenReturn(
          const Duration(milliseconds: 400).inMicroseconds.toDouble());
      when(() => snapshot.median).thenReturn(
          const Duration(milliseconds: 500).inMicroseconds.toDouble());
      when(() => snapshot.get75thPercentile()).thenReturn(
          const Duration(milliseconds: 600).inMicroseconds.toDouble());
      when(() => snapshot.get95thPercentile()).thenReturn(
          const Duration(milliseconds: 700).inMicroseconds.toDouble());
      when(() => snapshot.get98thPercentile()).thenReturn(
          const Duration(milliseconds: 800).inMicroseconds.toDouble());
      when(() => snapshot.get99thPercentile()).thenReturn(
          const Duration(milliseconds: 900).inMicroseconds.toDouble());
      when(() => snapshot.get999thPercentile()).thenReturn(
          const Duration(milliseconds: 1000).inMicroseconds.toDouble());

      when(() => timer.snapshot).thenReturn(snapshot);

      reporter.reportMetrics(timers: {'test.another.timer': timer});

      expect(output.toString(), equals('''
${datetime.toIso8601String()} ========================================================

-- Timers ----------------------------------------------------------------------
test.another.timer
             count = 1
         mean rate = 2.00 calls/second
     1-minute rate = 3.00 calls/second
     5-minute rate = 4.00 calls/second
    15-minute rate = 5.00 calls/second
               min = 300.00 milliseconds
               max = 100.00 milliseconds
              mean = 200.00 milliseconds
            stddev = 400.00 milliseconds
            median = 500.00 milliseconds
              75% <= 600.00 milliseconds
              95% <= 700.00 milliseconds
              98% <= 800.00 milliseconds
              99% <= 900.00 milliseconds
            99.9% <= 1000.00 milliseconds


'''));
    });
  });
}
