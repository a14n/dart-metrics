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

library metrics.counter_test;

import 'package:test/test.dart';
import 'package:metrics/metrics.dart';

main() {
  group('counter', () {
    test('start at zero', () {
      final counter = new Counter();
      expect(counter.count, equals(0));
    });

    test('increments by one', () {
      final counter = new Counter();
      counter.inc();
      expect(counter.count, equals(1));
    });

    test('increments by an arbitrary delta', () {
      final counter = new Counter();
      counter.inc(12);
      expect(counter.count, equals(12));
    });

    test('decrements by one', () {
      final counter = new Counter();
      counter.dec();
      expect(counter.count, equals(-1));
    });

    test('decrements by an arbitrary delta', () {
      final counter = new Counter();
      counter.dec(12);
      expect(counter.count, equals(-12));
    });
  });
}
