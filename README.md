# Metrics

[![Build Status](https://travis-ci.org/a14n/dart-metrics.svg)](https://travis-ci.org/a14n/dart-metrics)

This project is a port of the [Metrics](https://dropwizard.github.io/metrics/) Java library.

## Setting Up

Add the `metrics` dependency to your `pubspec.yaml`.

## Main components

### The registry

It contains a set of metrics.

```dart
final registry = new MetricRegistry();
```

### The metrics

There are several kind of metrics:

- the [Gauges](https://dropwizard.github.io/metrics/3.1.0/getting-started/#gauges).
- the [Counters](https://dropwizard.github.io/metrics/3.1.0/getting-started/#counters).
- the [Histograms](https://dropwizard.github.io/metrics/3.1.0/getting-started/#histograms).
- the [Meters](https://dropwizard.github.io/metrics/3.1.0/getting-started/#meters).
- the [Timers](https://dropwizard.github.io/metrics/3.1.0/getting-started/#timers).

### The reporters

They allows to export the collected datas. Currently there are :

- a `ConsoleReporter` that will use the `print` method to display the metrics.
- a `CsvReporter` that will write the metrics in cvs files under a provided directory.
- a `LogReporter` that will use a `Logger` from the [logging package](https://pub.dartlang.org/packages/logging).
- a `GraphiteReporter` that will send the metrics to [graphite](http://graphite.wikidot.com/).

## License
Apache 2.0
