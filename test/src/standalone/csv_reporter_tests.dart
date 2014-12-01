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

import 'package:metrics/metrics.dart';
import 'package:metrics/metrics_standalone.dart';
import 'package:mock/mock.dart';
import 'package:path/path.dart' as p;
import 'package:unittest/unittest.dart';

@proxy
class MockMetricRegistry extends Mock implements MetricRegistry {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@proxy
class MockClock extends Mock implements Clock {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@proxy
class MockGauge extends Mock implements Gauge {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@proxy
class MockCounter extends Mock implements Counter {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@proxy
class MockHistogram extends Mock implements Histogram {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@proxy
class MockSnapshot extends Mock implements Snapshot {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@proxy
class MockMeter extends Mock implements Meter {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@proxy
class MockTimer extends Mock implements Timer {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

main() {
  group('', () {

    Directory dataDir;
    CsvReporter reporter;

    getFileContents(String name) => new File(p.join(dataDir.path, name)).readAsStringSync();

    setUp(() {
      final registry = new MockMetricRegistry();
      final clock = new MockClock();
      clock.when(callsTo('get time')).thenReturn(19910191000);

      dataDir = new Directory('tmp-${new DateTime.now().millisecondsSinceEpoch}')..createSync();
      reporter = new CsvReporter(registry, dataDir, clock: clock);

    });

    tearDown(() {
      dataDir.deleteSync(recursive: true);
    });

    test('reports gauge values', () {
      final gauge = new MockGauge();
      gauge.when(callsTo('get value')).thenReturn(1);

      reporter.report({'gauge': gauge}, {}, {}, {}, {});

      expect(getFileContents('gauge.csv'), equals('''
t,value
19910191,1
'''));
    });

    test('reports counter values', () {
      final counter = new MockCounter();
      counter.when(callsTo('get count')).thenReturn(100);

      reporter.report({}, {'test.counter': counter}, {}, {}, {});

      expect(getFileContents('test.counter.csv'), equals('''
t,count
19910191,100
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

      reporter.report({}, {}, {'test.histogram': histogram}, {}, {});

      expect(getFileContents('test.histogram.csv'), equals('''
t,count,max,mean,min,stddev,p50,p75,p95,p98,p99,p999
19910191,1,2,3.0,4,5.0,6.0,7.0,8.0,9.0,10.0,11.0
'''));
    });

    test('reports meter values', () {
      final meter = new MockMeter();
      meter.when(callsTo('get count')).thenReturn(1);
      meter.when(callsTo('get meanRate')).thenReturn(2.0);
      meter.when(callsTo('get oneMinuteRate')).thenReturn(3.0);
      meter.when(callsTo('get fiveMinuteRate')).thenReturn(4.0);
      meter.when(callsTo('get fifteenMinuteRate')).thenReturn(5.0);

      reporter.report({}, {}, {}, {'test.meter': meter}, {});

      expect(getFileContents('test.meter.csv'), equals('''
t,count,mean_rate,m1_rate,m5_rate,m15_rate,rate_unit
19910191,1,2.0,3.0,4.0,5.0,events/second
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

      reporter.report({}, {}, {}, {}, {'test.another.timer': timer});

      expect(getFileContents('test.another.timer.csv'), equals('''
t,count,max,mean,min,stddev,p50,p75,p95,p98,p99,p999,mean_rate,m1_rate,m5_rate,m15_rate,rate_unit,duration_unit
19910191,1,100.0,200.0,300.0,400.0,500.0,600.0,700.0,800.0,900.0,1000.0,2.0,3.0,4.0,5.0,calls/second,milliseconds
'''));
    });

  });
}
