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
/// An exponentially-decaying random reservoir of [int]s. Uses Cormode et al's
/// forward-decaying priority reservoir sampling method to produce a statistically representative
/// sampling reservoir, exponentially biased towards newer entries.
///
/// See [Cormode et al. Forward Decay: A Practical Time Decay Model for Streaming Systems. ICDE '09: Proceedings of the 2009 IEEE International Conference on Data Engineering (2009)](http://dimacs.rutgers.edu/~graham/pubs/papers/fwddecay.pdf)
class ExponentiallyDecayingReservoir implements Reservoir {
  static const _defaultSize = 1028;
  static const _defaultAlpha = 0.015;
  static const _rescaleThreshold = Duration(hours: 1);

  static final _random = Random();

  final _values = <double, WeightedSample>{};
  final double _alpha;
  final int _size;
  int _count = 0;
  DateTime _startTime;
  DateTime _nextScaleTime;
  final Clock _clock;

  /// Creates a new [ExponentiallyDecayingReservoir].
  ///
  /// By default a new [ExponentiallyDecayingReservoir] of 1028 elements, which offers a 99.9%
  /// confidence level with a 5% margin of error assuming a normal distribution, and an alpha
  /// factor of 0.015, which heavily biases the reservoir to the past 5 minutes of measurements.
  ///
  /// [_size] is the number of samples to keep in the sampling reservoir
  /// [_alpha] is the exponential decay factor; the higher this is, the more biased the reservoir will be towards newer values
  /// [clock] is the clock used to timestamp samples and track rescaling
  ExponentiallyDecayingReservoir([
    this._size = _defaultSize,
    this._alpha = _defaultAlpha,
    this._clock = const Clock(),
  ])  : _startTime = _clock.now(),
        _nextScaleTime = _clock.now().add(_rescaleThreshold);

  @override
  int get size => min(_size, _count);

  @override
  void update(int value) {
    _rescaleIfNeeded();
    final itemWeight = _weight(_clock.now().difference(_startTime).inSeconds);
    final sample = WeightedSample(value, itemWeight);
    final priority = itemWeight / _random.nextDouble();

    final newCount = ++_count;
    if (newCount <= _size) {
      _values[priority] = sample;
    } else {
      var first = _values.keys.first;
      final oldValue = _values[priority];
      if (first < priority && oldValue == null) {
        _values[priority] = sample;

        // ensure we always remove an item
        while (_values.remove(first) == null) {
          first = _values.keys.first;
        }
      }
    }
  }

  @override
  Snapshot get snapshot => WeightedSnapshot(_values.values);

  double _weight(int t) => exp(_alpha * t);

  /* "A common feature of the above techniques—indeed, the key technique that
   * allows us to track the decayed weights efficiently—is that they maintain
   * counts and other quantities based on g(ti − L), and only scale by g(t − L)
   * at query time. But while g(ti −L)/g(t−L) is guaranteed to lie between zero
   * and one, the intermediate values of g(ti − L) could become very large. For
   * polynomial functions, these values should not grow too large, and should be
   * effectively represented in practice by floating point values without loss of
   * precision. For exponential functions, these values could grow quite large as
   * new values of (ti − L) become large, and potentially exceed the capacity of
   * common floating point types. However, since the values stored by the
   * algorithms are linear combinations of g values (scaled sums), they can be
   * rescaled relative to a new landmark. That is, by the analysis of exponential
   * decay in Section III-A, the choice of L does not affect the final result. We
   * can therefore multiply each value based on L by a factor of exp(−α(L′ − L)),
   * and obtain the correct value as if we had instead computed relative to a new
   * landmark L′ (and then use this new L′ at query time). This can be done with
   * a linear pass over whatever data structure is being used."
   */
  void _rescaleIfNeeded() {
    final now = _clock.now();
    if (now.isAfter(_nextScaleTime)) {
      _nextScaleTime = now.add(_rescaleThreshold);
      final oldStartTime = _startTime;
      _startTime = now;
      final scalingFactor =
          exp(-_alpha * (_startTime.difference(oldStartTime).inSeconds));

      final keys = List<double>.from(_values.keys);
      for (final key in keys) {
        final sample = _values.remove(key)!;
        final newSample =
            WeightedSample(sample.value, sample.weight * scalingFactor);
        _values[key * scalingFactor] = newSample;
      }

      // make sure the counter is in sync with the number of stored samples.
      _count = _values.length;
    }
  }
}
