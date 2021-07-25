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

import 'package:logging/logging.dart';
import 'package:metrics/metrics.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart' hide expect;

import 'mocks.dart';

class MockLogger extends Mock implements Logger {}

main() {
  testLevel(Level.SEVERE);
  testLevel(Level.INFO);
  testLevel(Level.FINER);
}

void testLevel(Level level) {
  group('', () {
    late MockLogger logger;
    late LogReporter reporter;

    setUp(() {
      final registry = MockMetricRegistry();
      logger = MockLogger();

      reporter = LogReporter(registry, logger: logger, level: level);
    });

    test('reports gauge values at $level', () {
      reporter.reportMetrics(gauges: {'gauge': Gauge(() => 'value')});

      verify(() => logger.log(level, 'type=GAUGE, name=gauge, value=value'))
          .called(1);
    });

    test('reports counter values at $level', () {
      final counter = MockCounter();
      when(() => counter.count).thenReturn(100);

      reporter.reportMetrics(counters: {'test.counter': counter});

      verify(() =>
              logger.log(level, 'type=COUNTER, name=test.counter, count=100'))
          .called(1);
    });

    test('reports histogram values at $level', () {
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

      verify(() => logger.log(level,
              'type=HISTROGRAM, name=test.histogram, count=1, max=2, mean=3.0, min=4, stddev=5.0, p50=6.0, p75=7.0, p95=8.0, p98=9.0, p99=10.0, p999=11.0'))
          .called(1);
    });

    test('reports meter values at $level', () {
      final meter = MockMeter();
      when(() => meter.count).thenReturn(1);
      when(() => meter.meanRate).thenReturn(2.0);
      when(() => meter.oneMinuteRate).thenReturn(3.0);
      when(() => meter.fiveMinuteRate).thenReturn(4.0);
      when(() => meter.fifteenMinuteRate).thenReturn(5.0);

      reporter.reportMetrics(meters: {'test.meter': meter});

      verify(() => logger.log(level,
              'type=METER, name=test.meter, count=1, mean_rate=2.0, m1_rate=3.0, m5_rate=4.0, m15_rate=5.0, rate_unit=events/second'))
          .called(1);
    });

    test('reports timer values at $level', () {
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

      verify(() => logger.log(level,
              'type=TIMER, name=test.another.timer, count=1, max=100.0, mean=200.0, min=300.0, stddev=400.0, p50=500.0, p75=600.0, p95=700.0, p98=800.0, p99=900.0, p999=1000.0, mean_rate=2.0, m1_rate=3.0, m5_rate=4.0, m15_rate=5.0, rate_unit=calls/second, duration_unit=milliseconds'))
          .called(1);
    });
  });
}
