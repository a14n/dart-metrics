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

library metrics.standalone.csv_reporter_test;

import 'dart:io';

import 'package:metrics/metrics_standalone.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../mocks.dart';

main() {
  group('', () {
    late Directory dataDir;
    late CsvReporter reporter;

    getFileContents(String name) =>
        File(p.join(dataDir.path, name)).readAsStringSync();

    setUp(() {
      final registry = MockMetricRegistry();
      final clock = MockClock();
      when(() => clock.time).thenReturn(19910191000);

      dataDir = Directory('tmp-${DateTime.now().millisecondsSinceEpoch}')
        ..createSync();
      reporter = CsvReporter(registry, dataDir, clock: clock);
    });

    tearDown(() {
      dataDir.deleteSync(recursive: true);
    });

    test('reports gauge values', () {
      final gauge = MockGauge();
      when(() => gauge.value).thenReturn(1);

      reporter.reportMetrics(gauges: {'gauge': gauge});

      expect(getFileContents('gauge.csv'), equals('''
t,value
19910191,1
'''));
    });

    test('reports counter values', () {
      final counter = MockCounter();
      when(() => counter.count).thenReturn(100);

      reporter.reportMetrics(counters: {'test.counter': counter});

      expect(getFileContents('test.counter.csv'), equals('''
t,count
19910191,100
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

      expect(getFileContents('test.histogram.csv'), equals('''
t,count,max,mean,min,stddev,p50,p75,p95,p98,p99,p999
19910191,1,2,3.0,4,5.0,6.0,7.0,8.0,9.0,10.0,11.0
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

      expect(getFileContents('test.meter.csv'), equals('''
t,count,mean_rate,m1_rate,m5_rate,m15_rate,rate_unit
19910191,1,2.0,3.0,4.0,5.0,events/second
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

      expect(getFileContents('test.another.timer.csv'), equals('''
t,count,max,mean,min,stddev,p50,p75,p95,p98,p99,p999,mean_rate,m1_rate,m5_rate,m15_rate,rate_unit,duration_unit
19910191,1,100.0,200.0,300.0,400.0,500.0,600.0,700.0,800.0,900.0,1000.0,2.0,3.0,4.0,5.0,calls/second,milliseconds
'''));
    });
  });
}
