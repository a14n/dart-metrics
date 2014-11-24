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

/// The abstract base class for all scheduled reporters (i.e., reporters which process a registry's metrics periodically).
///
///  See [ConsoleReporter], [CsvReporter], [LogReporter]
abstract class ScheduledReporter implements Reporter {
  final MetricRegistry _registry;
  final MetricFilter _filter;
  final TimeUnit durationUnit;
  final TimeUnit rateUnit;

  a.Timer _timer;

  /// Creates a new [ScheduledReporter] instance.
  ScheduledReporter(this._registry, this._filter, this.rateUnit, this.durationUnit);

  /// Starts the reporter polling at the given [period] (the amount of time between polls).
  void start(Duration period) {
    _timer = new a.Timer.periodic(period, (_) {
      try {
        _report();
      } catch (e) {
        // TODO(aa) use log
        print('Exception thrown from ${this.runtimeType}#report. Exception was suppressed. Exception was $e');
      }
    });
  }

  /// Stops the reporter.
  void stop() {
    _timer.cancel();
  }

  /**
     * Report the current values of all metrics in the registry.
     */
  void _report() {
    report(
        _registry.getGauges(where: _filter),
        _registry.getCounters(where: _filter),
        _registry.getHistograms(where: _filter),
        _registry.getMeters(where: _filter),
        _registry.getTimers(where: _filter));
  }


  /// Called periodically by the polling thread. Subclasses should report all the given metrics.
  void report(Map<String, Gauge> gauges,
              Map<String, Counter> counters,
              Map<String, Histogram> histograms,
              Map<String, Meter> meters,
              Map<String, Timer> timers);

  double convertDuration(double duration) => duration / durationUnit._duration.inMicroseconds;

  double convertRate(double rate) => rate * rateUnit._duration.inSeconds;
}

class TimeUnit {
  static const MICROSECONDS = const TimeUnit._('microsecond', const Duration(microseconds: 1));
  static const MILLISECONDS = const TimeUnit._('millisecond', const Duration(milliseconds: 1));
  static const SECONDS = const TimeUnit._('second', const Duration(seconds: 1));
  static const MINUTES = const TimeUnit._('minute', const Duration(minutes: 1));
  static const HOURS = const TimeUnit._('hour', const Duration(hours: 1));
  static const DAYS = const TimeUnit._('day', const Duration(days: 1));

  final String _name;
  final Duration _duration;

  const TimeUnit._(this._name, this._duration);
}
