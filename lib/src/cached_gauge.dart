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

/// A [Gauge] implementation which caches its value for a period of time.
class CachedGauge<T> implements Gauge<T> {
  final _Supplier<T> _getValue;
  final Clock _clock;
  int _reloadAt = 0;
  final int _timeoutInMicroseconds;

  T? _value;

  /// Creates a new cached gauge with the given [clock] and [timeout] period.
  CachedGauge(this._getValue, Duration timeout, [Clock? clock])
      : _clock = clock ?? Clock.defaultClock,
        _timeoutInMicroseconds = timeout.inMilliseconds * 1000;

  @override
  T get value {
    if (_shouldLoad()) _value = _getValue();
    return _value!;
  }

  bool _shouldLoad() {
    final time = _clock.tick;
    if (time <= _reloadAt) return false;
    _reloadAt = time + _timeoutInMicroseconds;
    return true;
  }
}
