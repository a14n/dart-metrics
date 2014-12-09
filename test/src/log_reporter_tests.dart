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

library metrics.log_reporter_test;

import 'package:logging/logging.dart';
import 'package:metrics/metrics.dart';
import 'package:mock/mock.dart';
import 'package:unittest/unittest.dart';

import '../lib/mocks.dart';

class MockLogger implements Logger {
  final _mock = new Mock();
  noSuchMethod(Invocation invocation) => _mock.noSuchMethod(invocation);
}

main() {
  testLevel(Level.SEVERE);
  testLevel(Level.INFO);
  testLevel(Level.FINER);
}

void testLevel(Level level) {
  group('', () {

    MockLogger logger;
    LogReporter infoReporter, reporter;

    setUp(() {
      final registry = new MockMetricRegistry();
      logger = new MockLogger();

      reporter = new LogReporter(registry, logger: logger, level: level);
    });

    test('reports gauge values at $level', () {
      reporter.report({'gauge': new Gauge(() => 'value')}, {}, {}, {}, {});

      logger._mock.getLogs(callsTo('log', level, 'type=GAUGE, name=gauge, value=value')).verify(happenedExactly(1));
    });

    test('reports counter values at $level', () {
      final counter = new MockCounter();
      counter.when(callsTo('get count')).thenReturn(100);

      reporter.report({}, {'test.counter': counter}, {}, {}, {});

      logger._mock.getLogs(callsTo('log', level, 'type=COUNTER, name=test.counter, count=100')).verify(happenedExactly(1));
    });

    test('reports histogram values at $level', () {
      final histogram = new MockHistogram();
      histogram.when(callsTo('get count')).thenReturn(1);

      final snapshot = new MockSnapshot();
      snapshot.when(callsTo('get max')).thenReturn(2);
      snapshot.when(callsTo('get mean')).thenReturn(3.0);
      snapshot.when(callsTo('get min')).thenReturn(4);
      snapshot.when(callsTo('get stdDev')).thenReturn(5.0);
      snapshot.when(callsTo('get median')).thenReturn(6.0);
      snapshot.when(callsTo('get75thPercentile')).thenReturn(7.0);
      snapshot.when(callsTo('get95thPercentile')).thenReturn(8.0);
      snapshot.when(callsTo('get98thPercentile')).thenReturn(9.0);
      snapshot.when(callsTo('get99thPercentile')).thenReturn(10.0);
      snapshot.when(callsTo('get999thPercentile')).thenReturn(11.0);

      histogram.when(callsTo('get snapshot')).thenReturn(snapshot);

      reporter.report({}, {}, {'test.histogram': histogram}, {}, {});

      logger._mock.getLogs(callsTo('log', level, 'type=HISTROGRAM, name=test.histogram, count=1, max=2, mean=3.0, min=4, stddev=5.0, p50=6.0, p75=7.0, p95=8.0, p98=9.0, p99=10.0, p999=11.0')).verify(happenedExactly(1));
    });

    test('reports meter values at $level', () {
      final meter = new MockMeter();
      meter.when(callsTo('get count')).thenReturn(1);
      meter.when(callsTo('get meanRate')).thenReturn(2.0);
      meter.when(callsTo('get oneMinuteRate')).thenReturn(3.0);
      meter.when(callsTo('get fiveMinuteRate')).thenReturn(4.0);
      meter.when(callsTo('get fifteenMinuteRate')).thenReturn(5.0);

      reporter.report({}, {}, {}, {'test.meter': meter}, {});

      logger._mock.getLogs(callsTo('log', level, 'type=METER, name=test.meter, count=1, mean_rate=2.0, m1_rate=3.0, m5_rate=4.0, m15_rate=5.0, rate_unit=events/second')).verify(happenedExactly(1));
    });

    test('reports timer values at $level', () {
      final timer = new MockTimer();
      timer.when(callsTo('get count')).thenReturn(1);
      timer.when(callsTo('get meanRate')).thenReturn(2.0);
      timer.when(callsTo('get oneMinuteRate')).thenReturn(3.0);
      timer.when(callsTo('get fiveMinuteRate')).thenReturn(4.0);
      timer.when(callsTo('get fifteenMinuteRate')).thenReturn(5.0);

      final snapshot = new MockSnapshot();
      snapshot.when(callsTo('get max')).thenReturn(const Duration(milliseconds: 100).inMicroseconds);
      snapshot.when(callsTo('get mean')).thenReturn(const Duration(milliseconds: 200).inMicroseconds.toDouble());
      snapshot.when(callsTo('get min')).thenReturn(const Duration(milliseconds: 300).inMicroseconds);
      snapshot.when(callsTo('get stdDev')).thenReturn(const Duration(milliseconds: 400).inMicroseconds.toDouble());
      snapshot.when(callsTo('get median')).thenReturn(const Duration(milliseconds: 500).inMicroseconds.toDouble());
      snapshot.when(callsTo('get75thPercentile')).thenReturn(const Duration(milliseconds: 600).inMicroseconds.toDouble());
      snapshot.when(callsTo('get95thPercentile')).thenReturn(const Duration(milliseconds: 700).inMicroseconds.toDouble());
      snapshot.when(callsTo('get98thPercentile')).thenReturn(const Duration(milliseconds: 800).inMicroseconds.toDouble());
      snapshot.when(callsTo('get99thPercentile')).thenReturn(const Duration(milliseconds: 900).inMicroseconds.toDouble());
      snapshot.when(callsTo('get999thPercentile')).thenReturn(const Duration(milliseconds: 1000).inMicroseconds.toDouble());

      timer.when(callsTo('get snapshot')).thenReturn(snapshot);

      reporter.report({}, {}, {}, {}, {'test.another.timer': timer});

      logger._mock.getLogs(callsTo('log', level, 'type=TIMER, name=test.another.timer, count=1, max=100.0, mean=200.0, min=300.0, stddev=400.0, p50=500.0, p75=600.0, p95=700.0, p98=800.0, p99=900.0, p999=1000.0, mean_rate=2.0, m1_rate=3.0, m5_rate=4.0, m15_rate=5.0, rate_unit=calls/second, duration_unit=milliseconds')).verify(happenedExactly(1));
    });

  });
}
