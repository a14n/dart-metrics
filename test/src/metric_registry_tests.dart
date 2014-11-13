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

library metrics.metric_registry_test;

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

class SimpleMetricSet extends MetricSet {
  final Map<String, Metric> metrics;
  SimpleMetricSet(this.metrics);
}

main() {

  test('registering a gauge triggers a notification', () {
    registeringAMetricTriggersANotification(gauge, 'onGaugeAdded');
  });

  test('removing a gauge triggers a notification', () {
    removingAMetricTriggersANotification(gauge, 'onGaugeRemoved');
  });

  test('registering a counter triggers a notification', () {
    registeringAMetricTriggersANotification(counter, 'onCounterAdded');
  });

  test('accessing a counter registers and reuses the counter', () {
    accessingAMetricRegistersAndReusesTheMetric((r) => r.counter, 'onCounterAdded');
  });

  test('removing a counter triggers a notification', () {
    removingAMetricTriggersANotification(counter, 'onCounterRemoved');
  });

  test('registering a histogram triggers a notification', () {
    registeringAMetricTriggersANotification(histogram, 'onHistogramAdded');
  });

  test('accessing a histogram registers and reuses the histogram', () {
    accessingAMetricRegistersAndReusesTheMetric((r) => r.histogram, 'onHistogramAdded');
  });

  test('removing a histogram triggers a notification', () {
    removingAMetricTriggersANotification(histogram, 'onHistogramRemoved');
  });

  test('registering a meter triggers a notification', () {
    registeringAMetricTriggersANotification(meter, 'onMeterAdded');
  });

  test('accessing a meter registers and reuses the meter', () {
    accessingAMetricRegistersAndReusesTheMetric((r) => r.meter, 'onMeterAdded');
  });

  test('removing a meter triggers a notification', () {
    removingAMetricTriggersANotification(meter, 'onMeterRemoved');
  });

  test('registering a timer triggers a notification', () {
    registeringAMetricTriggersANotification(timer, 'onTimerAdded');
  });

  test('accessing a timer registers and reuses the timer', () {
    accessingAMetricRegistersAndReusesTheMetric((r) => r.timer, 'onTimerAdded');
  });

  test('removing a timer triggers a notification', () {
    removingAMetricTriggersANotification(timer, 'onTimerRemoved');
  });

  test('adding a listener with existing metrics catches it up', () {
    final listener1 =  new MockMetricRegistryListener();
    final registry = new MetricRegistry()..addListener(listener1);

    registry.register('gauge', gauge);
    registry.register('counter', counter);
    registry.register('histogram', histogram);
    registry.register('meter', meter);
    registry.register('timer', timer);

    final listener2 =  new MockMetricRegistryListener();
    registry.addListener(listener2);

    listener2.getLogs(callsTo('onGaugeAdded', 'gauge', gauge)).verify(happenedExactly(1));
    listener2.getLogs(callsTo('onCounterAdded', 'counter', counter)).verify(happenedExactly(1));
    listener2.getLogs(callsTo('onHistogramAdded', 'histogram', histogram)).verify(happenedExactly(1));
    listener2.getLogs(callsTo('onMeterAdded', 'meter', meter)).verify(happenedExactly(1));
    listener2.getLogs(callsTo('onTimerAdded', 'timer', timer)).verify(happenedExactly(1));
  });

  test('a removed listener does not receive updates', () {
    final listener =  new MockMetricRegistryListener();
    final registry = new MetricRegistry()..addListener(listener);

    registry.register('gauge', gauge);
    registry.removeListener(listener);
    registry.register('gauge2', gauge);

    listener.getLogs(callsTo('onGaugeAdded', 'gauge2', gauge)).verify(neverHappened);
  });

  test('has a map of registered gauges', () {
    final registry = new MetricRegistry();

    registry.register('gauge', gauge);

    expect(registry.getGauges(), containsPair('gauge', gauge));
  });

  test('has a map of registered counters', () {
    final registry = new MetricRegistry();

    registry.register('counter', counter);

    expect(registry.getCounters(), containsPair('counter', counter));
  });

  test('has a map of registered histograms', () {
    final registry = new MetricRegistry();

    registry.register('histogram', histogram);

    expect(registry.getHistograms(), containsPair('histogram', histogram));
  });

  test('has a map of registered meters', () {
    final registry = new MetricRegistry();

    registry.register('meter', meter);

    expect(registry.getMeters(), containsPair('meter', meter));
  });

  test('has a map of registered timers', () {
    final registry = new MetricRegistry();

    registry.register('timer', timer);

    expect(registry.getTimers(), containsPair('timer', timer));
  });

  test('has a set of registered metric names', () {
    final registry = new MetricRegistry();

    registry.register('gauge', gauge);
    registry.register('counter', counter);
    registry.register('histogram', histogram);
    registry.register('meter', meter);
    registry.register('timer', timer);

    expect(registry.names, unorderedEquals(['gauge', 'counter', 'histogram', 'meter', 'timer']));
  });

  test('registers multiple metrics', () {
    final registry = new MetricRegistry();

    final metrics = new SimpleMetricSet({
      'gauge': gauge,
      'counter': counter
    });

    registry.registerAll(metrics);

    expect(registry.names, unorderedEquals(['gauge', 'counter']));
  });

  test('registers multiple metrics with a prefix', () {
    final registry = new MetricRegistry();

    final metrics = new SimpleMetricSet({
      'gauge': gauge,
      'counter': counter
    });

    registry.register('my', metrics);

    expect(registry.names, unorderedEquals(['my.gauge', 'my.counter']));
  });

  test('registers recursive metric sets', () {
    final registry = new MetricRegistry();

    final metrics = new SimpleMetricSet({
      'inner': new SimpleMetricSet({
        'gauge': gauge
      }),
      'counter': counter
    });

    registry.register('my', metrics);

    expect(registry.names, unorderedEquals(['my.inner.gauge', 'my.counter']));
  });

  test('registers metrics from another registry', () {
    final registry1 = new MetricRegistry();
    final registry2 = new MetricRegistry();

    registry2.register('gauge', gauge);
    registry1.register('nested', registry2);

    expect(registry1.names, unorderedEquals(['nested.gauge']));
  });

  test('concatenates strings to form a dotted name', () {
    expect(MetricRegistry.name(['one', 'two', 'three']), equals('one.two.three'));
  });

  test('elides null values from names when only one null passed in', () {
    expect(MetricRegistry.name(['one', null]), equals('one'));
  });

  test('elides null values from names when many nulls passed in', () {
    expect(MetricRegistry.name(['one', null, null]), equals('one'));
  });

  test('elides null values from names when null and not null passed in', () {
    expect(MetricRegistry.name(['one', null, 'three']), equals('one.three'));
  });

  test('elides empty strings from names', () {
    expect(MetricRegistry.name(['one', '', 'three']), equals('one.three'));
  });

  test('concatenates class names with strings to form a dotted name', () {
    expect(MetricRegistry.nameWithType(String, ['one', 'two']), equals('String.one.two'));
  });

  test('removes metrics matching a filter', () {
    final listener =  new MockMetricRegistryListener();
    final registry = new MetricRegistry()..addListener(listener);

    registry.timer('timer-1');
    registry.timer('timer-2');
    registry.histogram('histogram-1');

    expect(registry.names, unorderedEquals(['timer-1', 'timer-2', 'histogram-1']));

    registry.removeMatching((name, _) => name.endsWith("1"));

    expect(registry.names, isNot(contains(['timer-1', 'histogram-1'])));
    expect(registry.names, unorderedEquals(['timer-2']));

    listener.getLogs(callsTo('onTimerRemoved', 'timer-1')).verify(happenedExactly(1));
    listener.getLogs(callsTo('onHistogramRemoved', 'histogram-1')).verify(happenedExactly(1));
  });

}

void registeringAMetricTriggersANotification(MockMetric m, String methodName) {
  final listener =  new MockMetricRegistryListener();
  final registry = new MetricRegistry()..addListener(listener);

  expect(registry.register('thing', m), equals(m));

  listener.getLogs(callsTo(methodName, 'thing', m)).verify(happenedExactly(1));
}

void accessingAMetricRegistersAndReusesTheMetric(getFunction(MetricRegistry mr), String methodName) {
  final listener =  new MockMetricRegistryListener();
  final registry = new MetricRegistry()..addListener(listener);

  final createMetric = getFunction(registry);
  final m1 = createMetric('thing');
  final m2 = createMetric('thing');

  expect(m1, same(m2));

  listener.getLogs(callsTo(methodName, 'thing', m1)).verify(happenedExactly(1));
}

void removingAMetricTriggersANotification(MockMetric m, String methodName) {
  final listener =  new MockMetricRegistryListener();
  final registry = new MetricRegistry()..addListener(listener);

  registry.register('thing', m);

  expect(registry.remove('thing'), equals(true));

  listener.getLogs(callsTo(methodName, 'thing')).verify(happenedExactly(1));
}