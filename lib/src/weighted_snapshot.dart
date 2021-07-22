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

/// A statistical snapshot of a [WeightedSnapshot].
class WeightedSnapshot extends Snapshot {
  late List<int> _values;
  late List<double> _normWeights;
  late List<double> _quantiles;

  /// Create a new [Snapshot] with the given [values].
  WeightedSnapshot(Iterable<WeightedSample> values) {
    final List<WeightedSample> copy = List<WeightedSample>.from(values)
      ..sort((o1, o2) {
        if (o1.value > o2.value) return 1;
        if (o1.value < o2.value) return -1;
        return 0;
      });

    _values = List<int>.filled(copy.length, 0);
    _normWeights = List<double>.filled(copy.length, 0.0);
    _quantiles = List<double>.filled(copy.length, 0.0);

    final sumWeight = copy.fold(
        0.0, (double sum, WeightedSample sample) => sum + sample.weight);

    for (int i = 0; i < copy.length; i++) {
      _values[i] = copy[i].value;
      _normWeights[i] = copy[i].weight / sumWeight;
    }

    for (int i = 1; i < copy.length; i++) {
      _quantiles[i] = _quantiles[i - 1] + _normWeights[i - 1];
    }
  }

  @override
  double getValue(num quantile) {
    if (quantile < 0.0 || quantile > 1.0) {
      throw ArgumentError("$quantile is not in [0..1]");
    }

    if (_values.isEmpty) return 0.0;

    int posx = quantile is double ? _quantiles.indexOf(quantile) : -1;
    if (posx < 0) {
      posx = 0;
      for (int i = 0; i < _quantiles.length; i++) {
        if (_quantiles[i] > quantile) break;
        posx = i;
      }
    }

    return _values[posx].toDouble();
  }

  @override
  int get size => _values.length;

  @override
  List<int> get values => List<int>.from(_values);

  @override
  int get max => _values.isEmpty ? 0 : _values.last;

  @override
  int get min => _values.isEmpty ? 0 : _values.first;

  @override
  double get mean {
    if (_values.isEmpty) return 0.0;

    double sum = 0.0;
    for (int i = 0; i < _values.length; i++) {
      sum += _values[i] * _normWeights[i];
    }
    return sum;
  }

  @override
  double get stdDev {
    if (_values.isEmpty) return 0.0;

    final mean = this.mean;
    num variance = 0.0;

    for (int i = 0; i < _values.length; i++) {
      final diff = _values[i] - mean;
      variance += _normWeights[i] * diff * diff;
    }

    return sqrt(variance);
  }

  @override
  void dump(StringSink sink) => _values.forEach(sink.writeln);
}
