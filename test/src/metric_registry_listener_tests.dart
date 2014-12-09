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

library metrics.metric_registry_listener_test;

import 'package:unittest/unittest.dart';
import 'package:metrics/metrics.dart';
import 'package:mock/mock.dart';

class MockMetric extends Mock implements Metric {
}

@proxy
class MockMetricRegistryListener extends Mock implements MetricRegistryListener {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@proxy
class MockGauge extends MockMetric implements Gauge {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@proxy
class MockCounter extends MockMetric implements Counter {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@proxy
class MockHistogram extends MockMetric implements Histogram {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@proxy
class MockMeter extends MockMetric implements Meter {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

@proxy
class MockTimer extends MockMetric implements Timer {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final gauge = new MockGauge();
final counter = new MockCounter();
final histogram = new MockHistogram();
final meter = new MockMeter();
final timer = new MockTimer();

main() {
  final listener = new MetricRegistryListener();

  test('no ops on gauge added', () {
    listener.onGaugeAdded("blah", gauge);
    expect(gauge.log.logs, isEmpty);
  });

  test('no ops on counter added', () {
    listener.onCounterAdded("blah", counter);
    expect(counter.log.logs, isEmpty);
  });

  test('no ops on histogram added', () {
    listener.onHistogramAdded("blah", histogram);
    expect(histogram.log.logs, isEmpty);
  });

  test('no ops on meter added', () {
    listener.onMeterAdded("blah", meter);
    expect(meter.log.logs, isEmpty);
  });

  test('no ops on timer added', () {
    listener.onTimerAdded("blah", timer);
    expect(timer.log.logs, isEmpty);
  });

  test('does not explode when metrics are removed', () {
    expect((){
      listener.onGaugeRemoved("blah");
      listener.onCounterRemoved("blah");
      listener.onHistogramRemoved("blah");
      listener.onMeterRemoved("blah");
      listener.onTimerRemoved("blah");
    }, returnsNormally);
  });
}
