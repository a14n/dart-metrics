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

/// A [Reservoir] implementation backed by a sliding window that stores only the
/// measurements made in the last _N_ seconds (or other time unit).
class SlidingTimeWindowReservoir implements Reservoir {
  // only trim on updating once every N
  static const trimThreshold = 256;

  final Duration window;
  final Clock clock;
  @visibleForTesting
  final measurements = <DateTime, List<int>>{};
  int _trimCountDown = trimThreshold;

  /// Creates a new [SlidingTimeWindowReservoir] with the given [clock] and
  /// [duration].
  SlidingTimeWindowReservoir(
    this.window, [
    this.clock = const Clock(),
  ]);

  @override
  int get size {
    _trim();
    return measurements.values.fold(0, (t, e) => t + e.length);
  }

  @override
  Snapshot get snapshot {
    _trim();
    return UniformSnapshot(measurements.values.expand((e) => e).toList());
  }

  @override
  void update(int value) {
    if (_trimCountDown-- <= 0) {
      _trimCountDown = trimThreshold;
      _trim();
    }
    measurements.putIfAbsent(clock.now(), () => <int>[]).add(value);
  }

  void _trim() {
    final time = clock.now();
    measurements.keys
        .takeWhile((t) => t.isBefore(time.subtract(window)))
        .toList()
        .forEach(measurements.remove);
  }
}
