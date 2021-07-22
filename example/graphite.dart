import 'dart:async' show Timer;

import 'package:metrics/metrics_graphite.dart';
import 'package:metrics/metrics.dart' show MetricRegistry;

main() {
  // create a registry
  final registry = MetricRegistry();

  // start a console reporter
  GraphiteReporter(registry, Graphite('localhost', 2003))
      .start(const Duration(seconds: 5));

  // periodically execute something
  Timer.periodic(const Duration(milliseconds: 500), (_) {
    registry.counter('counter').inc();
  });
}
