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

library metrics_graphite;

import 'dart:async' show Future;
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:logging/logging.dart' show Logger;

import 'package:metrics/metrics.dart';

part 'src/graphite/graphite.dart';
part 'src/graphite/graphite_reporter.dart';
part 'src/graphite/graphite_sender.dart';
