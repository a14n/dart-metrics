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
  static const _CONSOLE_WIDTH = 80;
  static const _LEFT_WIDTH = 20;

  final StringSink _output;
  final Clock _clock;

  factory ConsoleReporter(MetricRegistry registry, {StringSink output, Clock clock, TimeUnit rateUnit, TimeUnit durationUnit, MetricFilter filter})
      => new ConsoleReporter._(registry,
          output != null ? output : new _PrintStringSink(),
          clock != null ? clock : Clock.defaultClock,
          rateUnit != null ? rateUnit : TimeUnit.SECONDS,
          durationUnit != null ? durationUnit : TimeUnit.MILLISECONDS,
          filter);

  ConsoleReporter._(MetricRegistry registry, this._output, this._clock, TimeUnit rateUnit, TimeUnit durationUnit, MetricFilter filter)
      : super(registry, filter, rateUnit, durationUnit);

  @override
  void report(Map<String, Gauge> gauges,
              Map<String, Counter> counters,
              Map<String, Histogram> histograms,
              Map<String, Meter> meters,
             Map<String, Timer> timers) {
    final dateTime = new DateTime.fromMillisecondsSinceEpoch(_clock.time);
    _printWithBanner(dateTime.toIso8601String(), '=');
    _output.writeln();

    if (!gauges.isEmpty) {
      _printWithBanner("-- Gauges", '-');
      gauges.forEach((name, gauge) {
        _output.writeln(name);
        _printGauge(gauge);
      });
      _output.writeln();
    }

    if (!counters.isEmpty) {
      _printWithBanner("-- Counters", '-');
      counters.forEach((name, counter) {
        _output.writeln(name);
        _printCounter(counter);
      });
      _output.writeln();
    }

    if (!histograms.isEmpty) {
      _printWithBanner("-- Histograms", '-');
      histograms.forEach((name, histogram) {
        _output.writeln(name);
        _printHistogram(histogram);
      });
      _output.writeln();
    }

    if (!meters.isEmpty) {
      _printWithBanner("-- Meters", '-');
      meters.forEach((name, meter) {
        _output.writeln(name);
        _printMeter(meter);
      });
      _output.writeln();
    }

    if (!timers.isEmpty) {
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
    String f(double v) => '${convertRate(v).toStringAsFixed(2)} events/${rateUnit._name}';
    _printValue('mean rate =', f(meter.meanRate));
    _printValue('1-minute rate =', f(meter.oneMinuteRate));
    _printValue('5-minute rate =', f(meter.fiveMinuteRate));
    _printValue('15-minute rate =', f(meter.fifteenMinuteRate));
  }

  void _printCounter(Counter counter) => _printValue('value =', counter.count);

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
    _printValue('75%% <=', f(snapshot.get75thPercentile()));
    _printValue('95%% <=', f(snapshot.get95thPercentile()));
    _printValue('98%% <=', f(snapshot.get98thPercentile()));
    _printValue('99%% <=', f(snapshot.get99thPercentile()));
    _printValue('99.9%% <=', f(snapshot.get999thPercentile()));
  }

  void _printTimer(Timer timer) {
    final Snapshot snapshot = timer.snapshot;
    _printValue('count =', timer.count);
    String f1(double v) => '${convertRate(v).toStringAsFixed(2)} calls/${rateUnit._name}';
    _printValue('mean rate =', f1(timer.meanRate));
    _printValue('1-minute rate =', f1(timer.oneMinuteRate));
    _printValue('5-minute rate =', f1(timer.fiveMinuteRate));
    _printValue('15-minute rate =', f1(timer.fifteenMinuteRate));
    String f2(num v) => '${convertDuration(v).toStringAsFixed(2)} ${durationUnit._name}';
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
    _output.writeln((s + ' ').padRight(_CONSOLE_WIDTH, padding));
  }

  void _printValue(String name, Object value) {
    _output.writeln(name.padLeft(_LEFT_WIDTH) + ' $value');
  }
}

class _PrintStringSink implements StringSink {
  StringBuffer sb = new StringBuffer();

  @override
  void write(Object obj) {
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
  void writeln([Object obj = ""]) {
    sb.write(obj);
    print(sb.toString());
    sb.clear();
  }
}
