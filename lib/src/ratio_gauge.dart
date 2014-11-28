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

/// A [Gauge] which measures the ratio of one value to another.
class RatioGauge implements Gauge<double> {
  final _Supplier<Ratio> _getRatio;

  RatioGauge(this._getRatio) {
    assert(_getRatio != null);
  }

  /// Returns the metric's current value.
  @override
  double get value => _getRatio().value;
}

class Ratio {
  final num numerator, denominator;

  Ratio(this.numerator, this.denominator);

  double get value => denominator.isNaN || denominator.isInfinite || denominator == 0 ? double.NAN : (numerator / denominator);

  @override
  String toString() => '$numerator:$denominator';
}