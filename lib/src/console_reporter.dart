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

/// A reporter which outputs measurements with a [StringSink].
class ConsoleReporter extends ScheduledReporter {
  static const _consoleWidth = 80;
  static const _leftWidth = 20;

  final StringSink _output;
  final Clock _clock;

  factory ConsoleReporter(
    MetricRegistry registry, {
    StringSink? output,
    Clock clock = const Clock(),
    TimeUnit? rateUnit,
    TimeUnit? durationUnit,
    MetricFilter? where,
  }) =>
      ConsoleReporter._(
        registry,
        output ?? _PrintStringSink(),
        clock,
        rateUnit ?? TimeUnit.seconds,
        durationUnit ?? TimeUnit.milliseconds,
        where: where,
      );

  ConsoleReporter._(
    MetricRegistry registry,
    this._output,
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
    _printWithBanner(_clock.now().toIso8601String(), '=');
    _output.writeln();

    if (gauges != null && gauges.isNotEmpty) {
      _printWithBanner("-- Gauges", '-');
      gauges.forEach((name, gauge) {
        _output.writeln(name);
        _printGauge(gauge);
      });
      _output.writeln();
    }

    if (counters != null && counters.isNotEmpty) {
      _printWithBanner("-- Counters", '-');
      counters.forEach((name, counter) {
        _output.writeln(name);
        _printCounter(counter);
      });
      _output.writeln();
    }

    if (histograms != null && histograms.isNotEmpty) {
      _printWithBanner("-- Histograms", '-');
      histograms.forEach((name, histogram) {
        _output.writeln(name);
        _printHistogram(histogram);
      });
      _output.writeln();
    }

    if (meters != null && meters.isNotEmpty) {
      _printWithBanner("-- Meters", '-');
      meters.forEach((name, meter) {
        _output.writeln(name);
        _printMeter(meter);
      });
      _output.writeln();
    }

    if (timers != null && timers.isNotEmpty) {
      _printWithBanner("-- Timers", '-');
      timers.forEach((name, timer) {
        _output.writeln(name);
        _printTimer(timer);
      });
      _output.writeln();
    }

    _output.writeln();
  }

  void _printMeter(Meter meter) {
    _printValue('count =', meter.count);
    String f(double v) =>
        '${convertRate(v).toStringAsFixed(2)} events/${rateUnit.name}';
    _printValue('mean rate =', f(meter.meanRate));
    _printValue('1-minute rate =', f(meter.oneMinuteRate));
    _printValue('5-minute rate =', f(meter.fiveMinuteRate));
    _printValue('15-minute rate =', f(meter.fifteenMinuteRate));
  }

  void _printCounter(Counter counter) => _printValue('count =', counter.count);

  void _printGauge(Gauge gauge) => _printValue('value =', gauge.value);

  void _printHistogram(Histogram histogram) {
    _printValue('count =', histogram.count);
    final snapshot = histogram.snapshot;
    _printValue('min =', snapshot.min);
    _printValue('max =', snapshot.max);
    String f(double v) => v.toStringAsFixed(2);
    _printValue('mean =', f(snapshot.mean));
    _printValue('stddev =', f(snapshot.stdDev));
    _printValue('median =', f(snapshot.median));
    _printValue('75% <=', f(snapshot.get75thPercentile()));
    _printValue('95% <=', f(snapshot.get95thPercentile()));
    _printValue('98% <=', f(snapshot.get98thPercentile()));
    _printValue('99% <=', f(snapshot.get99thPercentile()));
    _printValue('99.9% <=', f(snapshot.get999thPercentile()));
  }

  void _printTimer(Timer timer) {
    final snapshot = timer.snapshot;
    _printValue('count =', timer.count);
    String f1(double v) =>
        '${convertRate(v).toStringAsFixed(2)} calls/${rateUnit.name}';
    _printValue('mean rate =', f1(timer.meanRate));
    _printValue('1-minute rate =', f1(timer.oneMinuteRate));
    _printValue('5-minute rate =', f1(timer.fiveMinuteRate));
    _printValue('15-minute rate =', f1(timer.fifteenMinuteRate));
    String f2(num v) =>
        '${convertDuration(v).toStringAsFixed(2)} ${durationUnit.name}s';
    _printValue('min =', f2(snapshot.min));
    _printValue('max =', f2(snapshot.max));
    _printValue('mean =', f2(snapshot.mean));
    _printValue('stddev =', f2(snapshot.stdDev));
    _printValue('median =', f2(snapshot.median));
    _printValue('75% <=', f2(snapshot.get75thPercentile()));
    _printValue('95% <=', f2(snapshot.get95thPercentile()));
    _printValue('98% <=', f2(snapshot.get98thPercentile()));
    _printValue('99% <=', f2(snapshot.get99thPercentile()));
    _printValue('99.9% <=', f2(snapshot.get999thPercentile()));
  }

  void _printWithBanner(String s, String padding) {
    _output.writeln('$s '.padRight(_consoleWidth, padding));
  }

  void _printValue(String name, Object value) {
    _output.writeln('${name.padLeft(_leftWidth)} $value');
  }
}

/// A [StringSink] that write with [print].
///
/// The underliing [print] is call only on [_PrintStringSink.writeln].
class _PrintStringSink implements StringSink {
  final sb = StringBuffer();

  @override
  void write(Object? obj) {
    sb.write(obj);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    sb.writeAll(objects, separator);
  }

  @override
  void writeCharCode(int charCode) {
    sb.writeCharCode(charCode);
  }

  @override
  void writeln([Object? obj = ""]) {
    sb.write(obj);
    print(sb.toString());
    sb.clear();
  }
}
