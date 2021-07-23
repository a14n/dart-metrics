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
  final T Function() _getValue;
  final Clock _clock;
  DateTime _reloadAt;
  final Duration timeout;

  late T _value;

  /// Creates a new cached gauge with the given [clock] and [timeout] period.
  CachedGauge(
    this._getValue,
    this.timeout, [
    this._clock = const Clock(),
  ]) : _reloadAt = _clock.now();

  @override
  T get value {
    if (_shouldLoad()) _value = _getValue();
    return _value;
  }

  bool _shouldLoad() {
    final now = _clock.now();
    if (now.isBefore(_reloadAt)) return false;
    _reloadAt = now.add(timeout);
    return true;
  }
}
