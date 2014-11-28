import 'package:metrics/metrics.dart' hide Timer;
import 'dart:async' show Timer;

main() {
  // create a registry
  final registry = new MetricRegistry();

  // start a console reporter
  final m = new ConsoleReporter(registry)..start(const Duration(seconds: 5));

  // periodically execute something
  new Timer.periodic(const Duration(milliseconds: 500), (_){
    registry.counter('counter').inc();
  });
}