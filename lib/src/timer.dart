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

/// A timer metric which aggregates timing durations and provides duration statistics, plus
/// throughput statistics via [Meter].
class Timer implements Metered, Sampling {
  late Meter _meter;
  late Histogram _histogram;
  late Clock _clock;

  /// Creates a new [Timer] that uses the given [reservoir] and [clock].
  Timer([Reservoir? reservoir, Clock? clock]) {
    _clock = clock ?? Clock.defaultClock;
    _meter = Meter(_clock);
    _histogram = Histogram(reservoir ?? ExponentiallyDecayingReservoir());
  }

  /// Adds a recorded [duration].
  void update(Duration duration) => _update(duration.inMicroseconds);

  /// Times and records the duration of event.
  /*<T> T*/ timed(event()) {
    final startTime = _clock.tick;
    try {
      return event.call();
    } finally {
      _update(_clock.tick - startTime);
    }
  }

  /// Returns a new [TimerContext].
  TimerContext get time => TimerContext(this, _clock);

  @override
  int get count => _histogram.count;

  @override
  double get fifteenMinuteRate => _meter.fifteenMinuteRate;

  @override
  double get fiveMinuteRate => _meter.fiveMinuteRate;

  @override
  double get meanRate => _meter.meanRate;

  @override
  double get oneMinuteRate => _meter.oneMinuteRate;

  @override
  Snapshot get snapshot => _histogram.snapshot;

  void _update(int duration) {
    if (duration >= 0) {
      _histogram.update(duration);
      _meter.mark();
    }
  }
}

/// A timing context.
///
/// See [Timer.time]
class TimerContext {
  final Timer _timer;
  final Clock _clock;
  final int _startTime;

  TimerContext(this._timer, Clock clock)
      : _clock = clock,
        _startTime = clock.tick;

  /// Updates the timer with the difference between current and start time.
  ///
  /// Call to this method will not reset the start time. Multiple calls result in multiple updates.
  /// Returns the elapsed time in microseconds.
  int stop() {
    final elapsed = _clock.tick - _startTime;
    _timer.update(Duration(microseconds: elapsed));
    return elapsed;
  }
}
