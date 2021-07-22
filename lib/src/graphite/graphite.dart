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

/// A client to a Carbon server via TCP.
class Graphite implements GraphiteSender {
  final host;
  final int port;

  Future<Socket>? _socket;
  int _failures = 0;

  /// Creates a new client which connects to the given address.
  ///
  /// See [Socket.connect] for parameters.
  Graphite(this.host, this.port);

  @override
  Future connect() {
    if (_socket != null) throw new StateError('Already connected');
    return _socket = Socket.connect(host, port);
  }

  @override
  Future send(String name, String value, int timeInSeconds) {
    sanitize(String s) => s.replaceAll(new RegExp(r'\s+'), '-');
    if (!isConnected) connect();
    return _socket!.then((sock) {
      sock.writeln('${sanitize(name)} ${sanitize(value)} $timeInSeconds');
      _failures = 0;
    }).catchError((_) {
      _failures++;
    });
  }

  @override
  Future flush() {
    if (_socket == null) return new Future.value();
    return _socket!.then((s) => s.flush());
  }

  @override
  bool get isConnected => _socket != null;

  @override
  int get failures => _failures;

  @override
  Future close() {
    if (_socket == null) return new Future.value();
    final sock = _socket!;
    _socket = null;
    return sock.then((s) => Future.wait([s.drain(), s.close()]));
  }
}