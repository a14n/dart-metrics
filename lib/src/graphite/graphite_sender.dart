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

part of metrics_graphite;

abstract class GraphiteSender {
  /// Connects to the server.
  Future connect();

  /// Sends the given measurement to the server.
  void send(String name, String value, int timeInSeconds);

  /// Flushes buffer, if applicable.
  Future flush();

  /// Returns true if ready to send data.
  bool get isConnected;

  /// Returns the number of failed writes to the server.
  int get failures;

  /// Close the connection to the server.
  Future close();
}