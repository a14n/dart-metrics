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

library metrics.test.manual_clock;

import 'package:metrics/metrics.dart';

class ManualClock extends Clock {
  int ticksInMicros = 0;

  void addSeconds(int seconds) {
    ticksInMicros += seconds * Duration.microsecondsPerSecond;
  }

  void addMillis(int millis) {
    ticksInMicros += millis * Duration.microsecondsPerMillisecond;
  }

  void addMicros(int micros) {
    ticksInMicros += micros;
  }

  void addHours(int hours) {
    ticksInMicros += hours * Duration.microsecondsPerHour;
  }

  @override
  int get tick => ticksInMicros;

  @override
  int get time => ticksInMicros ~/ Duration.microsecondsPerMillisecond;
}