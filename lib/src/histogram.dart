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

/// A metric which calculates the distribution of a value.
///
/// See [Accurately computing running variance](http://www.johndcook.com/standard_deviation.html)
class Histogram implements Metric, Sampling, Counting {
  final Reservoir _reservoir;
  int _count = 0;

  /// Creates a new [Histogram] with the given [_reservoir].
  Histogram(this._reservoir);

  /// Adds a recorded value.
  void update(int value) {
    _count++;
    _reservoir.update(value);
  }

  /// The number of values recorded.
  @override
  int get count => _count;

  @override
  Snapshot get snapshot => _reservoir.snapshot;
}
