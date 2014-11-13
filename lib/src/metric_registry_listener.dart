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

// TODO(aa) make streams
/// Listeners for events from the registry.
class MetricRegistryListener {

  /// Called when a [Gauge] is added to the registry.
  void onGaugeAdded(String name, Gauge gauge) {}

  /// Called when a [Gauge] is removed to the registry.
  void onGaugeRemoved(String name) {}

  /// Called when a [Counter] is added to the registry.
  void onCounterAdded(String name, Counter counter) {}

  /// Called when a [Counter] is removed to the registry.
  void onCounterRemoved(String name) {}

  /// Called when a [Histogram] is added to the registry.
  void onHistogramAdded(String name, Histogram histogram) {}

  /// Called when a [Histogram] is removed to the registry.
  void onHistogramRemoved(String name) {}

  /// Called when a [Meter] is added to the registry.
  void onMeterAdded(String name, Meter meter) {}

  /// Called when a [Meter] is removed to the registry.
  void onMeterRemoved(String name) {}

  /// Called when a [Timer] is added to the registry.
  void onTimerAdded(String name, Timer timer) {}

  /// Called when a [Timer] is removed to the registry.
  void onTimerRemoved(String name) {}
}
