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

///
/// An exponentially-weighted moving average.
///
/// See :
/// - [UNIX Load Average Part 1: How It Works](http://www.teamquest.com/pdfs/whitepaper/ldavg1.pdf)
/// - [UNIX Load Average Part 2: Not Your Average Average](http://www.teamquest.com/pdfs/whitepaper/ldavg2.pdf)
/// - [EMA](http://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average)
class EWMA {
  /// Create a new EWMA with a specific smoothing constant [_alpha] and the
  /// expected tick interval [_expectedTickInterval].
  EWMA(this._alpha, this._expectedTickInterval);

  final double _alpha;
  final Duration _expectedTickInterval;

  bool _initialized = false;
  double _rate = 0.0;

  int _uncounted = 0;

  /// Creates a new EWMA which is equivalent to the UNIX one minute load average
  /// and which expects to be ticked every 5 seconds.
  EWMA.oneMinuteEWMA()
      : this.likeUnixLoadAverage(
          const Duration(minutes: 1),
          const Duration(seconds: 5),
        );

  /// Creates a new EWMA which is equivalent to the UNIX five minute load
  /// average and which expects to be ticked every 5 seconds.
  EWMA.fiveMinuteEWMA()
      : this.likeUnixLoadAverage(
          const Duration(minutes: 5),
          const Duration(seconds: 5),
        );

  /// Creates a new EWMA which is equivalent to the UNIX fifteen minute load
  /// average and which expects to be ticked every 5 seconds.
  EWMA.fifteenMinuteEWMA()
      : this.likeUnixLoadAverage(
          const Duration(minutes: 15),
          const Duration(seconds: 5),
        );

  EWMA.likeUnixLoadAverage(
    Duration unixLoadAverageDuration,
    Duration expectedTickInterval,
  ) : this(
          1 -
              exp(-expectedTickInterval.inMicroseconds /
                  unixLoadAverageDuration.inMicroseconds),
          expectedTickInterval,
        );

  /// Update the moving average with a new value [n].
  void update(int n) {
    _uncounted += n;
  }

  /// Mark the passage of time (every microseconds) and decay the current rate accordingly.
  void tick() {
    final instantRate =
        _uncounted / _expectedTickInterval.inMicroseconds.toDouble();
    _uncounted = 0;
    if (_initialized) {
      _rate += _alpha * (instantRate - _rate);
    } else {
      _rate = instantRate;
      _initialized = true;
    }
  }

  /// Returns the rate in the given [duration].
  double getRate(Duration duration) => _rate * duration.inMicroseconds;
}
