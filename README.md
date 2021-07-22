# Metrics

[![Build Status](https://github.com/a14n/dart-metrics/actions/workflows/dart.yml/badge.svg)](https://github.com/a14n/dart-metrics/actions/workflows/dart.yml)

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

### Running the tests

To run the tests, you first need to generate the Mockito mocks.

To generate them using build_runner run the command
```
$ dart run build_runner build
```

Note that running this on Windows (at least at the time of writing this) there is a bug where it
tries to have the imports use backslashes instead of forward slashes (probably because Windows uses
backslashes in file paths), so it'll generate some bad mock files with `import '..\lib\mock.dart'`
that you'll need to (at least for now) manually change to `import '../lib/mock.dart'`.

## License
Apache 2.0
