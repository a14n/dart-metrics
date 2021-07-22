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

library metrics.ewma_test;

import 'package:test/test.dart';
import 'package:metrics/metrics.dart';

const oneSecond = Duration(seconds: 1);

main() {
  test('a one minute EWMA with a value of three', () {
    final ewma = EWMA.oneMinuteEWMA();
    ewma.update(3);
    ewma.tick();

    expect(ewma.getRate(oneSecond), closeTo(0.6, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.22072766, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.08120117, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.02987224, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.01098938, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.00404277, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.00148725, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.00054713, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.00020128, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.00007405, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.00002724, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.00001002, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.00000369, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.00000136, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.00000050, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.00000018, 0.000001));
  });

  test('a five minute EWMA with a value of three', () {
    final ewma = EWMA.fiveMinuteEWMA();
    ewma.update(3);
    ewma.tick();

    expect(ewma.getRate(oneSecond), closeTo(0.6, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.49123845, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.40219203, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.32928698, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.26959738, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.22072766, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.18071653, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.14795818, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.12113791, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.09917933, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.08120117, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.06648190, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.05443077, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.04456415, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.03648604, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.02987224, 0.000001));
  });

  test('a fifteen minute EWMA with a value of three', () {
    final ewma = EWMA.fifteenMinuteEWMA();
    ewma.update(3);
    ewma.tick();

    expect(ewma.getRate(oneSecond), closeTo(0.6, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.56130419, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.52510399, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.49123845, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.45955700, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.42991879, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.40219203, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.37625345, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.35198773, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.32928698, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.30805027, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.28818318, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.26959738, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.25221023, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.23594443, 0.000001));
    elapseMinute(ewma);
    expect(ewma.getRate(oneSecond), closeTo(0.22072766, 0.000001));
  });
}

void elapseMinute(EWMA ewma) {
  for (int i = 1; i <= 12; i++) {
    ewma.tick();
  }
}
