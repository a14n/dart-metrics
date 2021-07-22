import 'dart:async' show Timer;

import 'package:metrics/metrics.dart' hide Timer;

main() {
  // create a registry
  final registry = MetricRegistry();

  // start a console reporter
  ConsoleReporter(registry).start(const Duration(seconds: 5));

  // periodically execute something
  Timer.periodic(const Duration(milliseconds: 500), (_) {
    registry.counter('counter').inc();
  });
}
