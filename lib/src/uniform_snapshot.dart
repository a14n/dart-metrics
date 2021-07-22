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

/// A statistical snapshot of a [UniformSnapshot].
class UniformSnapshot extends Snapshot {
  final List<int> _values;

  /// Create a new [Snapshot] with the given values.
  UniformSnapshot(List<int> values) : _values = values.toList(growable: false);

  @override
  double getValue(num quantile) {
    if (quantile < 0.0 || quantile > 1.0) {
      throw ArgumentError("$quantile is not in [0..1]");
    }

    if (_values.isEmpty) return 0.0;

    final pos = quantile * (_values.length + 1);

    if (pos < 1) return _values[0].toDouble();
    if (pos >= _values.length) return _values[_values.length - 1].toDouble();

    final lower = _values[pos.toInt() - 1];
    final upper = _values[pos.toInt()];
    return (lower + (pos - pos.floor()) * (upper - lower)).toDouble();
  }

  @override
  int get size => _values.length;

  @override
  List<int> get values => _values.toList(growable: false);

  @override
  int get max => _values.isEmpty ? 0 : _values.last;

  @override
  int get min => _values.isEmpty ? 0 : _values.first;

  @override
  double get mean => _values.isEmpty
      ? 0.0
      : (_values.reduce((a, b) => a + b) / _values.length);

  @override
  double get stdDev {
    if (_values.isEmpty) return 0.0;

    final mean = this.mean;
    final sum =
        _values.map((e) => e - mean).map((e) => e * e).reduce((a, b) => a + b);

    final variance = sum / (_values.length - 1);
    return sqrt(variance);
  }

  @override
  void dump(StringSink sink) => _values.forEach(sink.writeln);
}
