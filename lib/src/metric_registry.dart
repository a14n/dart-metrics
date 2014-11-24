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

/// A registry of metric instances.
class MetricRegistry implements MetricSet {
  /// Concatenates elements to form a dotted name, eliding any null values or empty strings.
  static String name(List<String> names) => names.where((e) => e != null && e.isNotEmpty).join('.');

  /// Concatenates a class name and elements to form a dotted name, eliding any null values or empty strings.
  static String nameWithType(Type t, List<String> names) => name([t.toString()]..addAll(names));

  Map<String, Metric> _metrics;
  final List<MetricRegistryListener> _listeners = <MetricRegistryListener>[];

  /// Creates a new [MetricRegistry].
  MetricRegistry() {
    _metrics = buildMap();
  }

  /**
   * Creates a new [Map] implementation for use inside the registry. Override this
   * to create a [MetricRegistry] with space- or time-bounded metric lifecycles, for
   * example.
   */
  Map<String, Metric> buildMap() => <String, Metric>{};

  /**
   * Given a [Metric], registers it under the given [name].
   *
   * Throws [ArgumentError] if the [name] is already registered.
   */
  /*<T extends Metric> T*/Metric register(String name, /*T*/Metric metric) {
    if (metric is MetricSet) {
      _registerAll(name, metric);
    } else {
      if (!_metrics.containsKey(name)) {
        _metrics[name] = metric;
        _onMetricAdded(name, metric);
      } else {
        throw new ArgumentError("A metric named " + name + " already exists");
      }
    }
    return metric;
  }

  /**
   * Given a metric set, registers them.
   *
   * Throws [ArgumentError] if any of the names are already registered
   */
  void registerAll(MetricSet metrics) => _registerAll(null, metrics);

  /// Creates a new [Counter] and registers it under the given [name].
  Counter counter(String name) => _getOrAdd(name, _MetricBuilder.COUNTERS);

  /// Creates a new [Histogram] and registers it under the given [name].
  Histogram histogram(String name) => _getOrAdd(name, _MetricBuilder.HISTOGRAMS);

  /// Creates a new [Meter] and registers it under the given [name].
  Meter meter(String name) => _getOrAdd(name, _MetricBuilder.METERS);

  /// Creates a new [Timer] and registers it under the given name.
  Timer timer(String name) => _getOrAdd(name, _MetricBuilder.TIMERS);

  /// Removes the metric with the given [name].
  bool remove(String name) {
    final Metric metric = _metrics.remove(name);
    if (metric != null) {
      _onMetricRemoved(name, metric);
      return true;
    }
    return false;
  }

  /// Removes all metrics which match the given [test].
  void removeMatching(MetricFilter test) =>
      _metrics.keys.where((name) => test(name, _metrics[name])).toList().forEach(remove);

  /**
   * Adds a [MetricRegistryListener] to a collection of listeners that will be notified on
   * metric creation.  Listeners will be notified in the order in which they are added.
   * **N.B.:** The listener will be notified of all existing metrics when it first registers.
   */
  void addListener(MetricRegistryListener listener) {
    _listeners.add(listener);

    for (String name in _metrics.keys) {
      _notifyListenerOfAddedMetric(listener, _metrics[name], name);
    }
  }

  /// Removes a [MetricRegistryListener] from this registry's collection of listeners.
  void removeListener(MetricRegistryListener listener) {
    _listeners.remove(listener);
  }

  /// A set of the names of all the metrics in the registry.
  Set<String> get names => _metrics.keys.toSet();

  /// Returns a map of all the gauges in the registry and their names which match the given [where].
  Map<String, Gauge> getGauges({MetricFilter where}) =>
      _getMetrics((name, metric) => metric is Gauge && (where == null || where(name, metric)));

  /// Returns a map of all the counters in the registry and their names which match the given [where].
  Map<String, Counter> getCounters({MetricFilter where}) =>
      _getMetrics((name, metric) => metric is Counter && (where == null || where(name, metric)));

  /// Returns a map of all the histograms in the registry and their names which match the given [where].
  Map<String, Histogram> getHistograms({MetricFilter where}) =>
      _getMetrics((name, metric) => metric is Histogram && (where == null || where(name, metric)));

  /// Returns a map of all the meters in the registry and their names which match the given [where].
  Map<String, Meter> getMeters({MetricFilter where}) =>
      _getMetrics((name, metric) => metric is Meter && (where == null || where(name, metric)));

  /// Returns a map of all the timers in the registry and their names which match the given [where].
  Map<String, Timer> getTimers({MetricFilter where}) =>
      _getMetrics((name, metric) => metric is Timer && (where == null || where(name, metric)));

  /*<T extends Metric> T*/ Metric _getOrAdd(String name, _MetricBuilder/*<T>*/ builder) {
    final Metric metric = _metrics[name];
    if (builder.isInstance(metric)) {
      return metric;
    } else if (metric == null) {
      try {
        return register(name, builder.newMetric());
      } on ArgumentError {
        final Metric added = _metrics[name];
        if (builder.isInstance(added)) {
          return added;
        }
      }
    }
    throw new ArgumentError("$name is already used for a different type of metric");
  }

  /*<T extends Metric> Map<String, T>*/Map<String, dynamic> _getMetrics(MetricFilter test) {
    final timers = <String, dynamic>{};
    for (String name in _metrics.keys) {
      final metric = _metrics[name];
      if (test(name, metric)) {
        timers[name] = metric;
      }
    }
    return timers;
  }

  void _onMetricAdded(String name, Metric metric) {
    for (MetricRegistryListener listener in _listeners) {
      _notifyListenerOfAddedMetric(listener, metric, name);
    }
  }

  void _notifyListenerOfAddedMetric(MetricRegistryListener listener, Metric metric, String name) {
    if (metric is Gauge) {
      listener.onGaugeAdded(name, metric);
    } else if (metric is Counter) {
      listener.onCounterAdded(name, metric);
    } else if (metric is Histogram) {
      listener.onHistogramAdded(name, metric);
    } else if (metric is Meter) {
      listener.onMeterAdded(name, metric);
    } else if (metric is Timer) {
      listener.onTimerAdded(name, metric);
    } else {
      throw new ArgumentError("Unknown metric type: ${metric.runtimeType}");
    }
  }

  void _onMetricRemoved(String name, Metric metric) {
    for (MetricRegistryListener listener in _listeners) {
      _notifyListenerOfRemovedMetric(name, metric, listener);
    }
  }

  void _notifyListenerOfRemovedMetric(String name, Metric metric, MetricRegistryListener listener) {
    if (metric is Gauge) {
      listener.onGaugeRemoved(name);
    } else if (metric is Counter) {
      listener.onCounterRemoved(name);
    } else if (metric is Histogram) {
      listener.onHistogramRemoved(name);
    } else if (metric is Meter) {
      listener.onMeterRemoved(name);
    } else if (metric is Timer) {
      listener.onTimerRemoved(name);
    } else {
      throw new ArgumentError("Unknown metric type: ${metric.runtimeType}");
    }
  }

  void _registerAll(String prefix, MetricSet metrics) {
    for (String metricName in metrics.metrics.keys) {
      final metric = metrics.metrics[metricName];
      if (metric is MetricSet) {
        _registerAll(name([prefix, metricName]), metric);
      } else {
        register(name([prefix, metricName]), metric);
      }
    }
  }

  @override
  Map<String, Metric> get metrics => new Map.from(_metrics);
}

/// A quick and easy way of capturing the notion of default metrics.
class _MetricBuilder<T extends Metric> {
  static final _MetricBuilder<Counter> COUNTERS = new _MetricBuilder<Counter>(() => new Counter());
  static final _MetricBuilder<Histogram> HISTOGRAMS = new _MetricBuilder<Histogram>(() => new Histogram(new ExponentiallyDecayingReservoir()));
  static final _MetricBuilder<Meter> METERS = new _MetricBuilder<Meter>(() => new Meter());
  static final _MetricBuilder<Timer> TIMERS = new _MetricBuilder<Timer>(() => new Timer());

  Function _createNewInstance;

  _MetricBuilder(T createNewInstance()) : _createNewInstance = createNewInstance;

  T newMetric() => _createNewInstance();

  bool isInstance(Metric metric) => metric is T;
}
