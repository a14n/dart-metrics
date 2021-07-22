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

import 'package:test/test.dart';
import 'package:metrics/metrics.dart';

main() {
  group('', () {
    late SlidingWindowReservoir reservoir;

    setUp(() {
      reservoir = SlidingWindowReservoir(3);
    });

    test('handles small data streams', () {
      reservoir.update(1);
      reservoir.update(2);

      expect(reservoir.snapshot.values, unorderedEquals([1, 2]));
    });

    test('big quantiles are the last value', () {
      reservoir.update(1);
      reservoir.update(2);
      reservoir.update(3);
      reservoir.update(4);

      expect(reservoir.snapshot.values, unorderedEquals([2, 3, 4]));
    });
  });
}
