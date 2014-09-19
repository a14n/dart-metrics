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

/// An object which maintains mean and exponentially-weighted rate.
abstract class Metered implements Metric, Counting {
  /// Returns the number of events which have been marked.
  int get count;

  /// Returns the fifteen-minute exponentially-weighted moving average rate at
  /// which events have occurred since the meter was created.
  ///
  /// This rate has the same exponential decay factor as the fifteen-minute load
  /// average in the `top` Unix command.
  double get fifteenMinuteRate;

  /// Returns the five-minute exponentially-weighted moving average rate at
  /// which events have occurred since the meter was created.
  ///
  /// This rate has the same exponential decay factor as the five-minute load
  /// average in the `top` Unix command.
  double get fiveMinuteRate;

  /// Returns the mean rate at which events have occurred since the meter was
  /// created.
  double get meanRate;

  /// Returns the one-minute exponentially-weighted moving average rate at which
  /// events have occurred since the meter was created.
  ///
  /// This rate has the same exponential decay factor as the one-minute load
  /// average in the `top` Unix command.
  double get oneMinuteRate;
}
