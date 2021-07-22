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

library metrics.histogram_test;

import 'package:metrics/metrics.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'mocks.dart';

main() {
  test('updates the count on updates', () {
    final reservoir = MockReservoir();
    final histogram = Histogram(reservoir);

    expect(histogram.count, equals(0));
    histogram.update(1);
    expect(histogram.count, equals(1));
  });

  test('returns the snapshot from the reservoir', () {
    final reservoir = MockReservoir();
    final snapshot = MockSnapshot();
    final histogram = Histogram(reservoir);

    when(() => reservoir.snapshot).thenReturn(snapshot);

    expect(histogram.snapshot, equals(snapshot));
  });

  test('updates the reservoir', () {
    final reservoir = MockReservoir();
    final histogram = Histogram(reservoir);

    histogram.update(1);

    verify(() => reservoir.update(1)).called(1);
  });
}
