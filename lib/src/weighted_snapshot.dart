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
  List<int> _values;
  List<double> _normWeights;
  List<double> _quantiles;

  /// Create a new [Snapshot] with the given [values].
  WeightedSnapshot(Iterable<WeightedSample> values) {
    final List<WeightedSample> copy = new List<WeightedSample>.from(values)
        ..sort((o1, o2) {
          if (o1.value > o2.value) return 1;
          if (o1.value < o2.value) return -1;
          return 0;
        });

    this._values = new List<int>.filled(copy.length, 0);
    this._normWeights = new List<double>.filled(copy.length, 0.0);
    this._quantiles = new List<double>.filled(copy.length, 0.0);

    double sumWeight = copy.fold(0, (sum, sample) => sum + sample.weight);

    for (int i = 0; i < copy.length; i++) {
      _values[i] = copy[i].value;
      _normWeights[i] = copy[i].weight / sumWeight;
    }

    for (int i = 1; i < copy.length; i++) {
      _quantiles[i] = _quantiles[i - 1] + _normWeights[i - 1];
    }
  }

  /// Returns the value at the given [quantile] (between 0 and 1).
  @override
  double getValue(double quantile) {
    if (quantile < 0.0 || quantile > 1.0) {
      throw new ArgumentError("$quantile is not in [0..1]");
    }

    if (_values.isEmpty) {
      return 0.0;
    }

    int posx = _quantiles.indexOf(quantile);
    if (posx < 0) {
      posx = 0;
      for (int i = 0; i < _quantiles.length; i++) {
        if (_quantiles[i] > quantile) break;
        posx = i;
      }
    }

    return _values[posx].toDouble();
  }

  /// The number of values in the snapshot.
  @override
  int get size => _values.length;

  /// The entire set of values in the snapshot.
  @override
  List<int> get values => new List<int>.from(_values);

  /// The highest value in the snapshot.
  @override
  int get max => _values.isEmpty ? 0 : _values.last;

  /// The lowest value in the snapshot.
  @override
  int get min => _values.isEmpty ? 0 : _values.first;

  /// The weighted arithmetic mean of the values in the snapshot.
  @override
  double get mean {
    if (_values.isEmpty) return 0.0;

    double sum = 0.0;
    for (int i = 0; i < _values.length; i++) {
      sum += _values[i] * _normWeights[i];
    }
    return sum;
  }

  /// The weighted standard deviation of the values in the snapshot.
  @override
  double get stdDev {
    // two-pass algorithm for variance, avoids numeric overflow

    if (_values.length <= 1) {
      return 0.0;
    }

    final double mean = this.mean;
    double variance = 0.0;

    for (int i = 0; i < _values.length; i++) {
      final double diff = _values[i] - mean;
      variance += _normWeights[i] * diff * diff;
    }

    return sqrt(variance);
  }

  /// Writes the values of the snapshot to the given [sink].
  @override
  void dump(Sink<String> sink) {
    for (int value in _values) {
      sink.add('$value\n');
    }
    sink.close();
  }
}
