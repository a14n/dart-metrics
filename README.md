# Metrics

This project is a port of the [Metrics](https://dropwizard.github.io/metrics/) Java library.

## Setting Up Maven

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

They allows to export the collected datas. Currently there are a `ConsoleReporter` and a `CsvReporter`.

## License
Apache 2.0
