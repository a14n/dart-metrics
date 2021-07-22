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

library metrics.ratio_gauge_test;

import 'package:test/test.dart';
import 'package:metrics/metrics.dart';

main() {

  test('ratios are human readable', () {
    final ratio = new Ratio(100, 200);

    expect(ratio.toString(), equals('100:200'));
  });

  test('calculates the ratio of the numerator to the denominator', () {
    final regular = new RatioGauge(() => new Ratio(2, 4));

    expect(regular.value, equals(0.5));
  });

  test('handles divide by zero issues', () {
    final regular = new RatioGauge(() => new Ratio(100, 0));

    expect(regular.value, isNaN);
  });

  test('handles infinite denominators', () {
    final regular = new RatioGauge(() => new Ratio(10, double.infinity));

    expect(regular.value, isNaN);
  });

  test('handles NaN denominators', () {
    final regular = new RatioGauge(() => new Ratio(10, double.nan));

    expect(regular.value, isNaN);
  });
}
