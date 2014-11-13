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

library metrics.meter_test;

import 'src/clock_tests.dart' as clock_test;
import 'src/counter_tests.dart' as counter_test;
import 'src/ewma_tests.dart' as ewma_test;
import 'src/exponentially_decaying_reservoir_tests.dart' as exponentially_decaying_reservoir_test;
import 'src/histogram_tests.dart' as histogram_test;
import 'src/meter_tests.dart' as meter_test;
import 'src/metric_registry_tests.dart' as metric_registry_test;

main() {
  clock_test.main();
  counter_test.main();
  ewma_test.main();
  exponentially_decaying_reservoir_test.main();
  histogram_test.main();
  meter_test.main();
  metric_registry_test.main();
}
