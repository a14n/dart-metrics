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

part of metrics;

/// An abstraction for how time passes. It is passed to [Timer] to track timing.
abstract class Clock {
  /// Returns the current time tick in microseconds.
  int get tick;

  /// Returns the current time in milliseconds.
  int get time => new DateTime.now().millisecondsSinceEpoch;

  static final Clock _DEFAULT = new StopwatchClock();

  /**
   * The default clock to use.
   *
   * @return the default {@link Clock} instance
   *
   * @see Clock.UserTimeClock
   */
  static Clock get defaultClock => _DEFAULT;
}

/// A clock implementation which returns the current time in epoch microseconds.
class FakeTickClock extends Clock {
  @override
  int get tick => time * Duration.microsecondsPerMillisecond;
}

/// A clock implementation which returns the current time in epoch microseconds.
class StopwatchClock extends Clock {
  final _sw = new Stopwatch()..start();
  final _microsecondsSinceEpoch = new DateTime.now().millisecondsSinceEpoch *
      Duration.microsecondsPerMillisecond;

  @override
  int get tick => _microsecondsSinceEpoch + _sw.elapsedMicroseconds;
}