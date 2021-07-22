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

import 'src/cached_gauge_tests.dart' as cached_gauge_test;
import 'src/clock_tests.dart' as clock_test;
import 'src/console_reporter_tests.dart' as console_reporter_test;
import 'src/counter_tests.dart' as counter_test;
import 'src/derivative_gauge_tests.dart' as derivative_gauge_test;
import 'src/ewma_tests.dart' as ewma_test;
import 'src/exponentially_decaying_reservoir_tests.dart'
    as exponentially_decaying_reservoir_test;
import 'src/histogram_tests.dart' as histogram_test;
import 'src/log_reporter_tests.dart' as log_reporter_test;
import 'src/meter_approximation_tests.dart' as meter_approximation_test;
import 'src/meter_tests.dart' as meter_test;
import 'src/metric_registry_tests.dart' as metric_registry_test;
import 'src/ratio_gauge_tests.dart' as ratio_gauge_test;
import 'src/scheduled_report_tests.dart' as scheduled_report_test;
import 'src/sliding_time_window_reservoir_tests.dart'
    as sliding_time_window_reservoir_test;
import 'src/sliding_window_reservoir_tests.dart'
    as sliding_window_reservoir_test;
import 'src/uniform_snapshot_tests.dart' as uniform_snapshot_test;
import 'src/weighted_snapshot_tests.dart' as weighted_snapshot_test;

import 'src/standalone/csv_reporter_tests.dart' as csv_reporter_test;

import 'src/graphite/graphite_tests.dart' as graphite_test;

main() {
  cached_gauge_test.main();
  clock_test.main();
  console_reporter_test.main();
  counter_test.main();
  derivative_gauge_test.main();
  ewma_test.main();
  exponentially_decaying_reservoir_test.main();
  histogram_test.main();
  log_reporter_test.main();
  meter_approximation_test.main();
  meter_test.main();
  metric_registry_test.main();
  ratio_gauge_test.main();
  scheduled_report_test.main();
  sliding_time_window_reservoir_test.main();
  sliding_window_reservoir_test.main();
  uniform_snapshot_test.main();
  weighted_snapshot_test.main();

  graphite_test.main();

  csv_reporter_test.main();
}
