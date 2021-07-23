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

/// A meter metric which measures mean throughput and one-, five-, and
/// fifteen-minute exponentially-weighted moving average throughputs.
///
///  See [EWMA]
class Meter implements Metered {
  static final _tickInterval = const Duration(seconds: 5);

  final _m1Rate = EWMA.oneMinuteEWMA();
  final _m5Rate = EWMA.fiveMinuteEWMA();
  final _m15Rate = EWMA.fifteenMinuteEWMA();

  int _count = 0;
  final DateTime _startTime;
  DateTime _lastTime;
  final Clock _clock;

  /// Creates a new [Meter].
  Meter([
    Clock clock = const Clock(),
  ])  : _clock = clock,
        _startTime = clock.now(),
        _lastTime = clock.now();

  /// Mark the occurrence of [n] number of events.
  void mark([int n = 1]) {
    _tickIfNecessary();
    _count += n;
    _m1Rate.update(n);
    _m5Rate.update(n);
    _m15Rate.update(n);
  }

  void _tickIfNecessary() {
    final now = _clock.now();
    final age = now.difference(_lastTime);
    if (age > _tickInterval) {
      final newIntervalStartTick = now.microsecondsSinceEpoch -
          age.inMicroseconds % _tickInterval.inMicroseconds;
      _lastTime = DateTime.fromMicrosecondsSinceEpoch(newIntervalStartTick);
      final requiredTicks = age.inMicroseconds ~/ _tickInterval.inMicroseconds;
      for (var i = 0; i < requiredTicks; i++) {
        _m1Rate.tick();
        _m5Rate.tick();
        _m15Rate.tick();
      }
    }
  }

  @override
  int get count => _count;

  @override
  double get fifteenMinuteRate {
    _tickIfNecessary();
    return _m15Rate.getRate(const Duration(seconds: 1));
  }

  @override
  double get fiveMinuteRate {
    _tickIfNecessary();
    return _m5Rate.getRate(const Duration(seconds: 1));
  }

  @override
  double get meanRate {
    if (count == 0) {
      return 0.0;
    } else {
      final elapsed = _clock.now().difference(_startTime);
      return count / elapsed.inSeconds;
    }
  }

  @override
  double get oneMinuteRate {
    _tickIfNecessary();
    return _m1Rate.getRate(const Duration(seconds: 1));
  }
}
