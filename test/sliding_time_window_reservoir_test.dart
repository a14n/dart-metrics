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

import 'package:metrics/metrics.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks.dart';

main() {
  group('', () {
    late MockClock clock;
    late SlidingTimeWindowReservoir reservoir;

    setUp(() {
      clock = MockClock();
      reservoir = SlidingTimeWindowReservoir(
        const Duration(microseconds: 10),
        clock,
      );
    });

    test('stores measurements with duplicate ticks', () {
      when(() => clock.now())
          .thenReturn(DateTime.fromMicrosecondsSinceEpoch(20));

      reservoir.update(1);
      reservoir.update(2);

      expect(reservoir.size, equals(2));
      expect(reservoir.snapshot.values, unorderedEquals([1, 2]));
    });

    test('bounds measurements to a time window', () {
      when(() => clock.now())
          .thenReturn(DateTime.fromMicrosecondsSinceEpoch(0));
      reservoir.update(1);
      expect(
        reservoir.measurements,
        equals({
          DateTime.fromMicrosecondsSinceEpoch(0): [1],
        }),
      );
      expect(reservoir.size, equals(1));

      when(() => clock.now())
          .thenReturn(DateTime.fromMicrosecondsSinceEpoch(5));
      reservoir.update(2);
      expect(
        reservoir.measurements,
        equals({
          DateTime.fromMicrosecondsSinceEpoch(0): [1],
          DateTime.fromMicrosecondsSinceEpoch(5): [2],
        }),
      );
      expect(reservoir.size, equals(2));

      when(() => clock.now())
          .thenReturn(DateTime.fromMicrosecondsSinceEpoch(10));
      reservoir.update(3);
      expect(
        reservoir.measurements,
        equals({
          DateTime.fromMicrosecondsSinceEpoch(0): [1],
          DateTime.fromMicrosecondsSinceEpoch(5): [2],
          DateTime.fromMicrosecondsSinceEpoch(10): [3],
        }),
      );
      expect(reservoir.size, equals(3));

      when(() => clock.now())
          .thenReturn(DateTime.fromMicrosecondsSinceEpoch(15));
      reservoir.update(4);
      expect(
        reservoir.measurements,
        equals({
          DateTime.fromMicrosecondsSinceEpoch(0): [1],
          DateTime.fromMicrosecondsSinceEpoch(5): [2],
          DateTime.fromMicrosecondsSinceEpoch(10): [3],
          DateTime.fromMicrosecondsSinceEpoch(15): [4],
        }),
      );
      expect(reservoir.size, equals(3));
      expect(
        reservoir.measurements,
        equals({
          DateTime.fromMicrosecondsSinceEpoch(5): [2],
          DateTime.fromMicrosecondsSinceEpoch(10): [3],
          DateTime.fromMicrosecondsSinceEpoch(15): [4],
        }),
      );

      when(() => clock.now())
          .thenReturn(DateTime.fromMicrosecondsSinceEpoch(20));
      reservoir.update(5);
      expect(
        reservoir.measurements,
        equals({
          DateTime.fromMicrosecondsSinceEpoch(5): [2],
          DateTime.fromMicrosecondsSinceEpoch(10): [3],
          DateTime.fromMicrosecondsSinceEpoch(15): [4],
          DateTime.fromMicrosecondsSinceEpoch(20): [5],
        }),
      );
      expect(reservoir.size, equals(3));
      expect(
        reservoir.measurements,
        equals({
          DateTime.fromMicrosecondsSinceEpoch(10): [3],
          DateTime.fromMicrosecondsSinceEpoch(15): [4],
          DateTime.fromMicrosecondsSinceEpoch(20): [5],
        }),
      );

      expect(reservoir.snapshot.values, equals([3, 4, 5]));
    });
  });
}
