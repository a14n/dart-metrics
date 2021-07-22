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

import 'dart:async' as a show Timer;

import 'package:test/test.dart';
import 'package:metrics/metrics.dart';

import '../lib/mocks.dart';

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
    registeringAMetricTriggersANotification(gauge);
  });

  test('removing a gauge triggers a notification', () {
    removingAMetricTriggersANotification(gauge);
  });

  test('registering a counter triggers a notification', () {
    registeringAMetricTriggersANotification(counter);
  });

  test('accessing a counter registers and reuses the counter', () {
    accessingAMetricRegistersAndReusesTheMetric((r) => r.counter);
  });

  test('removing a counter triggers a notification', () {
    removingAMetricTriggersANotification(counter);
  });

  test('registering a histogram triggers a notification', () {
    registeringAMetricTriggersANotification(histogram);
  });

  test('accessing a histogram registers and reuses the histogram', () {
    accessingAMetricRegistersAndReusesTheMetric((r) => r.histogram);
  });

  test('removing a histogram triggers a notification', () {
    removingAMetricTriggersANotification(histogram);
  });

  test('registering a meter triggers a notification', () {
    registeringAMetricTriggersANotification(meter);
  });

  test('accessing a meter registers and reuses the meter', () {
    accessingAMetricRegistersAndReusesTheMetric((r) => r.meter);
  });

  test('removing a meter triggers a notification', () {
    removingAMetricTriggersANotification(meter);
  });

  test('registering a timer triggers a notification', () {
    registeringAMetricTriggersANotification(timer);
  });

  test('accessing a timer registers and reuses the timer', () {
    accessingAMetricRegistersAndReusesTheMetric((r) => r.timer);
  });

  test('removing a timer triggers a notification', () {
    removingAMetricTriggersANotification(timer);
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
    final registry = new MetricRegistry();

    final metricsRemoved = <NamedMetric>[];
    registry.onMetricRemoved.listen(metricsRemoved.add);

    registry.timer('timer-1');
    registry.timer('timer-2');
    registry.histogram('histogram-1');

    expect(registry.names, unorderedEquals(['timer-1', 'timer-2', 'histogram-1']));

    registry.removeMatching((name, _) => name.endsWith("1"));

    expect(registry.names, isNot(contains(['timer-1', 'histogram-1'])));
    expect(registry.names, unorderedEquals(['timer-2']));

    a.Timer.run(expectAsync0((){
      expect(metricsRemoved, hasLength(2));
      expect(metricsRemoved.where((nm) => nm.name == 'timer-1' && nm.metric is Timer).length, equals(1));
      expect(metricsRemoved.where((nm) => nm.name == 'histogram-1' && nm.metric is Histogram).length, equals(1));
    }));
  });

}

void registeringAMetricTriggersANotification(MockMetric m) {
  final registry = new MetricRegistry();

  final metricsAdded = <NamedMetric>[];
  registry.onMetricAdded.listen(metricsAdded.add);

  expect(registry.register('thing', m), equals(m));

  a.Timer.run(expectAsync0((){
    expect(metricsAdded, hasLength(1));
    expect(metricsAdded.where((nm) => nm.name == 'thing' && nm.metric == m).length, equals(1));
  }));
}

void accessingAMetricRegistersAndReusesTheMetric(getFunction(MetricRegistry mr)) {
  final registry = new MetricRegistry();

  final metricsAdded = <NamedMetric>[];
  registry.onMetricAdded.listen(metricsAdded.add);

  final createMetric = getFunction(registry);
  final m1 = createMetric('thing');
  final m2 = createMetric('thing');

  expect(m1, same(m2));

  a.Timer.run(expectAsync0((){
    expect(metricsAdded, hasLength(1));
    expect(metricsAdded.where((nm) => nm.name == 'thing' && nm.metric == m1).length, equals(1));
  }));
}

void removingAMetricTriggersANotification(MockMetric m) {
  final registry = new MetricRegistry();

  final metricsRemoved = <NamedMetric>[];
  registry.onMetricRemoved.listen(metricsRemoved.add);

  registry.register('thing', m);

  expect(registry.remove('thing'), equals(true));

  a.Timer.run(expectAsync0((){
    expect(metricsRemoved, hasLength(1));
    expect(metricsRemoved.where((nm) => nm.name == 'thing' && nm.metric == m).length, equals(1));
  }));
}
