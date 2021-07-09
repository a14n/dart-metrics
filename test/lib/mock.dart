
import 'package:metrics/metrics.dart';

T registryRegisterMockShim<T extends Metric>(String? name, T? metric) {
  return metric!;
}