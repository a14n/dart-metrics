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

/**
 * An exponentially-weighted moving average.
 *
 * See :
 * - [UNIX Load Average Part 1: How It Works](http://www.teamquest.com/pdfs/whitepaper/ldavg1.pdf)
 * - [UNIX Load Average Part 2: Not Your Average Average](http://www.teamquest.com/pdfs/whitepaper/ldavg2.pdf)
 * - [EMA](http://en.wikipedia.org/wiki/Moving_average#Exponential_moving_average)
 */
class EWMA {
  static const _INTERVAL_IN_SECONDS = 5;
  static final _INTERVAL_IN_MINUTES = _INTERVAL_IN_SECONDS / 60.0;

  static final _M1_ALPHA = 1 - exp(-_INTERVAL_IN_MINUTES / 1.0);
  static final _M5_ALPHA = 1 - exp(-_INTERVAL_IN_MINUTES / 5.0);
  static final _M15_ALPHA = 1 - exp(-_INTERVAL_IN_MINUTES / 15.0);

  bool _initialized = false;
  double _rate = 0.0;

  int _uncounted = 0;
  double _alpha, _interval;

  /// Creates a new EWMA which is equivalent to the UNIX one minute load average
  /// and which expects to be ticked every 5 seconds.
  EWMA.oneMinuteEWMA()
      : this(_M1_ALPHA, const Duration(seconds: _INTERVAL_IN_SECONDS));

  /// Creates a new EWMA which is equivalent to the UNIX five minute load
  /// average and which expects to be ticked every 5 seconds.
  EWMA.fiveMinuteEWMA()
      : this(_M5_ALPHA, const Duration(seconds: _INTERVAL_IN_SECONDS));

  /// Creates a new EWMA which is equivalent to the UNIX fifteen minute load
  /// average and which expects to be ticked every 5 seconds.
  EWMA.fifteenMinuteEWMA()
      : this(_M15_ALPHA, const Duration(seconds: _INTERVAL_IN_SECONDS));

  /// Create a new EWMA with a specific smoothing constant [_alpha] and the
  /// expected tick interval [expectedTickInterval].
  EWMA(this._alpha, Duration expectedTickInterval) : _interval =
      expectedTickInterval.inMicroseconds.toDouble();

  /// Update the moving average with a new value [n].
  void update(int n) {
    _uncounted += n;
  }

  /// Mark the passage of time and decay the current rate accordingly.
  void tick() {
    final instantRate = _uncounted / _interval;
    _uncounted = 0;
    if (_initialized) {
      _rate += (_alpha * (instantRate - _rate));
    } else {
      _rate = instantRate;
      _initialized = true;
    }
  }

  /// Returns the rate in the given [duration].
  double getRate(Duration duration) => _rate * duration.inMicroseconds;
}
