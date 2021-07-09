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

/// A [Reservoir] implementation backed by a sliding window that stores the last
/// _N_  measurements.
class SlidingWindowReservoir implements Reservoir {
  final List<int> _measurements;
  int _count = 0;

  /// Creates a new [SlidingWindowReservoir] which stores the last [size]
  /// measurements.
  SlidingWindowReservoir(int size)
      : _measurements = List.filled(size, 0);

  @override
  int get size => min(_count, _measurements.length);

  @override
  void update(int value) {
    _measurements[_count++ % _measurements.length] = value;
  }

  @override
  Snapshot get snapshot {
    final values = _measurements.sublist(0, size).toList(growable: false);
    return new UniformSnapshot(values);
  }
}
