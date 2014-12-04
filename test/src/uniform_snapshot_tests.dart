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

library metrics.uniform_snapshot_test;

import 'package:unittest/unittest.dart';
import 'package:metrics/metrics.dart';


main() {
  group('', () {
    Snapshot snapshot;

    setUp(() {
      snapshot = new WeightedSnapshot(
          [new WeightedSample(5, 1.0),
           new WeightedSample(1, 2.0),
           new WeightedSample(2, 3.0),
           new WeightedSample(3, 2.0),
           new WeightedSample(4, 2.0),]);
    });

    test('small quantiles are the first value', () {
      expect(snapshot.getValue(0.0), equals(1.0));
    });

    test('big quantiles are the last value', () {
      expect(snapshot.getValue(1.0), equals(5.0));
    });

    test('has a median', () {
      expect(snapshot.median, closeTo(3.0, 0.1));
    });

    test('has a p75', () {
      expect(snapshot.get75thPercentile(), closeTo(4.0, 0.1));
    });

    test('has a p95', () {
      expect(snapshot.get95thPercentile(), closeTo(5.0, 0.1));
    });

    test('has a p98', () {
      expect(snapshot.get98thPercentile(), closeTo(5.0, 0.1));
    });

    test('has a p99', () {
      expect(snapshot.get99thPercentile(), closeTo(5.0, 0.1));
    });

    test('has a p999', () {
      expect(snapshot.get999thPercentile(), closeTo(5.0, 0.1));
    });

    test('has values', () {
      expect(snapshot.values, hasLength(5));
      expect(snapshot.values, equals([1, 2, 3, 4, 5]));
    });

    test('has a size', () {
      expect(snapshot.size, equals(5));
    });

    test('dumps to a sink', () {
      final sb = new StringBuffer();

      snapshot.dump(sb);

      expect(sb.toString(), equals('1\n2\n3\n4\n5\n'));
    });

    test('calculates the minimum value', () {
      expect(snapshot.min, equals(1));
    });

    test('calculates the maximum value', () {
      expect(snapshot.max, equals(5));
    });

    test('calculates the mean value', () {
      expect(snapshot.mean, equals(2.7));
    });

    test('calculates the stdDev value', () {
      expect(snapshot.stdDev, closeTo(1.2688, 0.0001));
    });

    test('calculates a min of zero for an empty snapshot', () {
      final emptySnapshot = new WeightedSnapshot([]);
      expect(emptySnapshot.min, equals(0));
    });

    test('calculates a max of zero for an empty snapshot', () {
      final emptySnapshot = new WeightedSnapshot([]);
      expect(emptySnapshot.max, equals(0));
    });

    test('calculates a mean of zero for an empty snapshot', () {
      final emptySnapshot = new WeightedSnapshot([]);
      expect(emptySnapshot.mean, equals(0));
    });

    test('calculates a stdDev of zero for an empty snapshot', () {
      final emptySnapshot = new WeightedSnapshot([]);
      expect(emptySnapshot.stdDev, equals(0));
    });

    test('calculates a stdDev of zero for an singleton snapshot', () {
      final singleItemSnapshot = new WeightedSnapshot([new WeightedSample(1, 1.0)]);
      expect(singleItemSnapshot.stdDev, equals(0));
    });

    test('expect no overflow for low weights', () {
      final singleItemSnapshot = new WeightedSnapshot(
          [new WeightedSample(1, double.MIN_POSITIVE),
           new WeightedSample(2, double.MIN_POSITIVE),
           new WeightedSample(3, double.MIN_POSITIVE),]);
      expect(singleItemSnapshot.mean, equals(2));
    });

  });

}
