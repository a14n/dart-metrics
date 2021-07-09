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
  static final log = new Logger("ScheduledReporter");

  final MetricRegistry _registry;
  final MetricFilter? where;
  final TimeUnit durationUnit;
  final TimeUnit rateUnit;

  a.Timer? _timer;

  /// Creates a new [ScheduledReporter] instance.
  ScheduledReporter(this._registry, this.rateUnit, this.durationUnit, {this.where});

  /// Starts the reporter polling at the given [period] (the amount of time between polls).
  void start(Duration period) {
    _timer = new a.Timer.periodic(period, (_) {
      try {
        report();
      } catch (e) {
        log.warning('Exception thrown from ${this.runtimeType}#report.', e);
      }
    });
  }

  /// Stops the reporter.
  void stop() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  /// Report the current values of all metrics in the registry.
  void report() {
    reportMetrics(
        gauges: _registry.getGauges(where: where),
        counters: _registry.getCounters(where: where),
        histograms: _registry.getHistograms(where: where),
        meters: _registry.getMeters(where: where),
        timers: _registry.getTimers(where: where));
  }


  /// Called periodically by the polling thread. Subclasses should report all the given metrics.
  void reportMetrics({Map<String, Gauge> gauges,
                      Map<String, Counter> counters,
                      Map<String, Histogram> histograms,
                      Map<String, Meter> meters,
                      Map<String, Timer> timers});

  double convertDuration(num duration) => duration / durationUnit._duration.inMicroseconds;

  double convertRate(double rate) => rate * rateUnit._duration.inSeconds;
}

class TimeUnit {
  static const MICROSECONDS = const TimeUnit._('microsecond', const Duration(microseconds: 1));
  static const MILLISECONDS = const TimeUnit._('millisecond', const Duration(milliseconds: 1));
  static const SECONDS = const TimeUnit._('second', const Duration(seconds: 1));
  static const MINUTES = const TimeUnit._('minute', const Duration(minutes: 1));
  static const HOURS = const TimeUnit._('hour', const Duration(hours: 1));
  static const DAYS = const TimeUnit._('day', const Duration(days: 1));

  final String name;
  final Duration _duration;

  const TimeUnit._(this.name, this._duration);
}
