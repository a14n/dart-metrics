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

typedef T _Supplier<T>();

/**
 * A gauge metric is an instantaneous reading of a particular value. To instrument a queue's depth,
 * for example:
 *
 *     List l = [];
 *     final gauge = new Gauge<int>(() => l.length);
 */
class Gauge<T> extends Metric {
  final _Supplier<T> _getValue;

  Gauge(this._getValue) {
    assert(_getValue != null);
  }

  /// Returns the metric's current value.
  T get value => _getValue();
}