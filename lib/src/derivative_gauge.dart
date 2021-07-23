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

/// A gauge whose value is derived from the value of another gauge.
class DerivativeGauge<F, T> implements Gauge<T> {
  final Gauge<F> _base;
  final T Function(F value) _transform;

  DerivativeGauge(this._base, this._transform);

  @override
  T get value => _transform(_base.value);
}
