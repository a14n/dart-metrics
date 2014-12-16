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

import 'package:unittest/unittest.dart';
import 'package:metrics/metrics.dart';
import 'package:mock/mock.dart';

import '../lib/mocks.dart';

main() {
  group('', () {

    StringBuffer output;
    ConsoleReporter reporter;

    setUp(() {
      final registry = new MockMetricRegistry();
      final clock = new MockClock();
      clock.when(callsTo('get time')).thenReturn(1363568676000);

      output = new StringBuffer();
      reporter = new ConsoleReporter(registry, output: output, clock: clock);

    });

    test('reports gauge values', () {
      final gauge = new MockGauge();
      gauge.when(callsTo('get value')).thenReturn(1);

      reporter.reportMetrics(gauges: {'gauge': gauge});

      expect(output.toString(), equals('''
2013-03-18T02:04:36.000 ========================================================

-- Gauges ----------------------------------------------------------------------
gauge
             value = 1


'''));
    });

    test('reports counter values', () {
      final counter = new MockCounter();
      counter.when(callsTo('get count')).thenReturn(100);

      reporter.reportMetrics(counters: {'test.counter': counter});

      expect(output.toString(), equals('''
2013-03-18T02:04:36.000 ========================================================

-- Counters --------------------------------------------------------------------
test.counter
             count = 100


'''));
    });

    test('reports histogram values', () {
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

      reporter.reportMetrics(histograms: {'test.histogram': histogram});

      expect(output.toString(), equals('''
2013-03-18T02:04:36.000 ========================================================

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
      final meter = new MockMeter();
      meter.when(callsTo('get count')).thenReturn(1);
      meter.when(callsTo('get meanRate')).thenReturn(2.0);
      meter.when(callsTo('get oneMinuteRate')).thenReturn(3.0);
      meter.when(callsTo('get fiveMinuteRate')).thenReturn(4.0);
      meter.when(callsTo('get fifteenMinuteRate')).thenReturn(5.0);

      reporter.reportMetrics(meters: {'test.meter': meter});

      expect(output.toString(), equals('''
2013-03-18T02:04:36.000 ========================================================

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

      reporter.reportMetrics(timers: {'test.another.timer': timer});

      expect(output.toString(), equals('''
2013-03-18T02:04:36.000 ========================================================

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
