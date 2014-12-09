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

library metrics.lib.mocks;

import 'package:metrics/metrics.dart';
import 'package:mock/mock.dart';

class MockMetric extends Mock implements Metric {
}

class MockMetricRegistry extends Mock implements MetricRegistry {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockClock extends Mock implements Clock {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockGauge extends MockMetric implements Gauge {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockCounter extends MockMetric implements Counter {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHistogram extends MockMetric implements Histogram {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSnapshot extends Mock implements Snapshot {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockMeter extends MockMetric implements Meter {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTimer extends MockMetric implements Timer {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockReservoir extends Mock implements Reservoir {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockMetricRegistryListener extends Mock implements MetricRegistryListener {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
