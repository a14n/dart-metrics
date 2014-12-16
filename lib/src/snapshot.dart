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

/// A statistical snapshot of a [Snapshot].
abstract class Snapshot {

  /// Returns the value at the given [quantile] (between 0 and 1).
  num getValue(num quantile);

  /// The entire set of values in the snapshot.
  List<int> get values;

  /// The number of values in the snapshot.
  int get size;

  ///The median value in the distribution.
  num get median => getValue(0.5);

  /// Returns the value at the 75th percentile in the distribution.
  num get75thPercentile() => getValue(0.75);

  /// Returns the value at the 95th percentile in the distribution.
  num get95thPercentile() => getValue(0.95);

  /// Returns the value at the 98th percentile in the distribution.
  num get98thPercentile() => getValue(0.98);

  /// Returns the value at the 99th percentile in the distribution.
  num get99thPercentile() => getValue(0.99);

  /// Returns the value at the 99.9th percentile in the distribution.
  num get999thPercentile() => getValue(0.999);

  /// The highest value in the snapshot.
  int get max;

  /// The arithmetic mean of the values in the snapshot.
  num get mean;

  /// The lowest value in the snapshot.
  int get min;

  /// The standard deviation of the values in the snapshot.
  num get stdDev;

  /// Writes the values of the snapshot to the given [sink].
  void dump(StringSink sink);
}
