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

import 'dart:async';

import 'package:test/test.dart';
import 'package:metrics/metrics.dart';

main() {
  test('caches the value for the given period', () {
    int i = 1;
    final gauge = CachedGauge(() => i++, const Duration(milliseconds: 100));

    expect(gauge.value, equals(1));
    expect(gauge.value, equals(1));
  });

  test('reloads the cached value after the given period', () {
    int i = 1;
    final gauge = CachedGauge(() => i++, const Duration(milliseconds: 100));

    expect(gauge.value, equals(1));
    Future.delayed(const Duration(milliseconds: 150), expectAsync0(() {
      expect(gauge.value, equals(2));
      expect(gauge.value, equals(2));
    }));
  });
}
