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

/// A reporter class for logging metrics values to a [log.Logger] periodically,
/// similar to [ConsoleReporter] or [CsvReporter], but using the logging package
/// instead.
class LogReporter extends ScheduledReporter {
  final log.Logger _logger;
  final log.Level _logLevel;

  factory LogReporter(MetricRegistry registry, {log.Logger logger, log.Level level, TimeUnit rateUnit, TimeUnit durationUnit, MetricFilter filter})
      => new LogReporter._(registry,
          logger != null ? logger : new log.Logger('metrics'),
          level != null ? level : log.Level.INFO,
          rateUnit != null ? rateUnit : TimeUnit.SECONDS,
          durationUnit != null ? durationUnit : TimeUnit.MILLISECONDS,
          filter);

  LogReporter._(MetricRegistry registry, this._logger, this._logLevel, TimeUnit rateUnit, TimeUnit durationUnit, MetricFilter filter)
      : super(registry, filter, rateUnit, durationUnit);

  @override
  void report({Map<String, Gauge> gauges,
               Map<String, Counter> counters,
               Map<String, Histogram> histograms,
               Map<String, Meter> meters,
               Map<String, Timer> timers}) {
    if (gauges != null) {
      gauges.forEach((name, gauge) {
        logGauge(name, gauge);
      });
    }

    if (counters != null) {
      counters.forEach((name, counter) {
        logCounter(name, counter);
      });
    }

    if (histograms != null) {
      histograms.forEach((name, histogram) {
        logHistogram(name, histogram);
      });
    }

    if (meters != null) {
      meters.forEach((name, meter) {
        logMeter(name, meter);
      });
    }

    if (timers != null) {
      timers.forEach((name, timer) {
        logTimer(name, timer);
      });
    }
  }

  void logGauge(String name, Gauge gauge) {
    _log('GAUGE', name, {'value': gauge.value});
  }

  void logCounter(String name, Counter counter) {
    _log('COUNTER', name, {'count': counter.count});
  }

  void logHistogram(String name, Histogram histogram) {
    final snapshot = histogram.snapshot;
    _log('HISTROGRAM', name, {
      'count': histogram.count,
      'max': snapshot.max,
      'mean': snapshot.mean,
      'min': snapshot.min,
      'stddev': snapshot.stdDev,
      'p50': snapshot.median,
      'p75': snapshot.get75thPercentile(),
      'p95': snapshot.get95thPercentile(),
      'p98': snapshot.get98thPercentile(),
      'p99': snapshot.get99thPercentile(),
      'p999': snapshot.get999thPercentile(),
    });
  }

  void logMeter(String name, Meter meter) {
    _log('METER', name, {
      'count': meter.count,
      'mean_rate': convertRate(meter.meanRate),
      'm1_rate': convertRate(meter.oneMinuteRate),
      'm5_rate': convertRate(meter.fiveMinuteRate),
      'm15_rate': convertRate(meter.fifteenMinuteRate),
      'rate_unit': 'events/${rateUnit.name}',
    });
  }

  void logTimer(String name, Timer timer) {
    final snapshot = timer.snapshot;
    _log('TIMER', name, {
      'count': timer.count,
      'max': convertDuration(snapshot.max),
      'mean': convertDuration(snapshot.mean),
      'min': convertDuration(snapshot.min),
      'stddev': convertDuration(snapshot.stdDev),
      'p50': convertDuration(snapshot.median),
      'p75': convertDuration(snapshot.get75thPercentile()),
      'p95': convertDuration(snapshot.get95thPercentile()),
      'p98': convertDuration(snapshot.get98thPercentile()),
      'p99': convertDuration(snapshot.get99thPercentile()),
      'p999': convertDuration(snapshot.get999thPercentile()),
      'mean_rate': convertRate(timer.meanRate),
      'm1_rate': convertRate(timer.oneMinuteRate),
      'm5_rate': convertRate(timer.fiveMinuteRate),
      'm15_rate': convertRate(timer.fifteenMinuteRate),
      'rate_unit': 'calls/${rateUnit.name}',
      'duration_unit': '${durationUnit.name}s',
    });
  }

  void _log(String type, String name, Map<String, dynamic> datas) {
    _logger.log(_logLevel, 'type=$type, name=$name, ${datas.keys.map((k) => '$k=${datas[k]}').join(', ')}') ;
  }
}
