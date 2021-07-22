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

/// An incrementing and decrementing counter metric.
class Counter implements Metric, Counting {
  int _count = 0;

  /// Increment the counter by [n] or `1` if ommitted.
  void inc([int n = 1]) {
    _count += n;
  }

  /// Decrement the counter by [n] or `1` if ommitted.
  void dec([int n = 1]) {
    _count -= n;
  }

  /// Returns the counter's current value.
  @override
  int get count => _count;
}
