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

part of metrics_graphite;

/// A reporter which publishes metric values to a Graphite server.
class GraphiteReporter extends ScheduledReporter {
  static final _log = Logger('GraphiteReporter');

  final Clock _clock;
  final String? _prefix;
  final GraphiteSender _graphite;

  factory GraphiteReporter(
    MetricRegistry registry,
    GraphiteSender graphite, {
    String? prefix,
    Clock clock = const Clock(),
    TimeUnit? rateUnit,
    TimeUnit? durationUnit,
    MetricFilter? where,
  }) =>
      GraphiteReporter._(
        registry,
        graphite,
        prefix,
        clock,
        rateUnit ?? TimeUnit.seconds,
        durationUnit ?? TimeUnit.milliseconds,
        where: where,
      );

  GraphiteReporter._(
    MetricRegistry registry,
    this._graphite,
    this._prefix,
    this._clock,
    TimeUnit rateUnit,
    TimeUnit durationUnit, {
    MetricFilter? where,
  }) : super(
          registry,
          rateUnit,
          durationUnit,
          where: where,
        );

  @override
  void reportMetrics({
    Map<String, Gauge>? gauges,
    Map<String, Counter>? counters,
    Map<String, Histogram>? histograms,
    Map<String, Meter>? meters,
    Map<String, Timer>? timers,
  }) {
    final time = _clock.now();
    try {
      if (!_graphite.isConnected) {
        _graphite.connect();
      }
      if (gauges != null) {
        gauges.forEach((name, gauge) {
          reportGauge(time, name, gauge);
        });
      }
      if (counters != null) {
        counters.forEach((name, counter) {
          reportCounter(time, name, counter);
        });
      }
      if (histograms != null) {
        histograms.forEach((name, histogram) {
          reportHistogram(time, name, histogram);
        });
      }
      if (meters != null) {
        meters.forEach((name, meter) {
          reportMeter(time, name, meter);
        });
      }
      if (timers != null) {
        timers.forEach((name, timer) {
          reportTimer(time, name, timer);
        });
      }
      _graphite.flush();
    } on IOException catch (e) {
      _log.warning("Unable to report to Graphite", e);
      try {
        _graphite.close();
      } on IOException catch (e1) {
        _log.warning("Error closing Graphite", e1);
      }
    }
  }

  @override
  void stop() {
    try {
      super.stop();
    } finally {
      try {
        _graphite.close();
      } on IOException catch (e) {
        _log.fine("Error disconnecting from Graphite", e);
      }
    }
  }

  void reportGauge(DateTime time, String name, Gauge gauge) {
    _report(time, name, {'value': gauge.value});
  }

  void reportCounter(DateTime time, String name, Counter counter) {
    _report(time, name, {'count': counter.count});
  }

  void reportHistogram(DateTime time, String name, Histogram histogram) {
    final snapshot = histogram.snapshot;
    _report(time, name, {
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

  void reportMeter(DateTime time, String name, Meter meter) {
    _report(time, name, {
      'count': meter.count,
      'mean_rate': convertRate(meter.meanRate),
      'm1_rate': convertRate(meter.oneMinuteRate),
      'm5_rate': convertRate(meter.fiveMinuteRate),
      'm15_rate': convertRate(meter.fifteenMinuteRate),
      'rate_unit': 'events/${rateUnit.name}',
    });
  }

  void reportTimer(DateTime time, String name, Timer timer) {
    final snapshot = timer.snapshot;
    _report(time, name, {
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

  void _report(DateTime time, String name, Map<String, dynamic> datas) {
    datas.forEach((k, v) {
      _graphite.send(
        MetricRegistry.name([_prefix, name, k]),
        v.toString(),
        time,
      );
    });
  }
}
