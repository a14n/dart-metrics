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

library metrics.graphite.graphite_test;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:metrics/metrics_graphite.dart';
import 'package:unittest/unittest.dart';

main() {
  group('', () {

    ServerSocket serverSocket;
    Graphite graphite;

    setUp(() {
      return startServer(9000).then((ss) {
        serverSocket = ss;
        graphite = new Graphite(serverSocket.address, serverSocket.port);
      });
    });

    tearDown(() => Future.wait([serverSocket.close(), graphite.close()]));

    test('graphite is not connected', () {
      expect(graphite.isConnected, isFalse);
      serverSocket.length.then(expectAsync((int l) => expect(l, isZero)));
      return serverSocket.close();
    });

    test('measures failures', () {
      expect(graphite.failures, isZero);
    });

    test('connects to graphite', () {
      serverSocket.length.then(expectAsync((int l) => expect(l, equals(1))));
      graphite.connect().then(expectAsync((_) => serverSocket.close()));
    });

    test('disconnects from graphite', () {
      graphite.connect()
          .then(expectAsync((_) => graphite.close()))
          .then(expectAsync((_) => expect(graphite.isConnected, isFalse)));
    });

    test('does not allow double connections', () {
      graphite.connect().then(expectAsync((_){
        expect(() => graphite.connect(), throwsStateError);
      }));
    });

    test('writes values to graphite', () {
      final line = new Completer<String>();
      serverSocket.listen((s) => s.map(UTF8.decode).listen((s) => line.complete(s)));
      graphite.connect()
          .then(expectAsync((_) => graphite.send('name', 'value', 100)))
          .then(expectAsync((_) => graphite.close()))
          .then(expectAsync((_) => line.future))
          .then(expectAsync((s) => expect(s, equals('name value 100\n'))));
    });

    test('sanitizes names', () {
      final line = new Completer<String>();
      serverSocket.listen((s) => s.map(UTF8.decode).listen((s) => line.complete(s)));
      graphite.connect()
          .then(expectAsync((_) => graphite.send('name woo', 'value', 100)))
          .then(expectAsync((_) => graphite.close()))
          .then(expectAsync((_) => line.future))
          .then(expectAsync((s) => expect(s, equals('name-woo value 100\n'))));
    });

    test('sanitizes values', () {
      final line = new Completer<String>();
      serverSocket.listen((s) => s.map(UTF8.decode).listen((s) => line.complete(s)));
      graphite.connect()
          .then(expectAsync((_) => graphite.send('name', 'value woo', 100)))
          .then(expectAsync((_) => graphite.close()))
          .then(expectAsync((_) => line.future))
          .then(expectAsync((s) => expect(s, equals('name value-woo 100\n'))));
    });

  });
}

Future<ServerSocket> startServer(int port)
    => ServerSocket.bind('localhost', port)
                   .catchError((_) => startServer(port + 1));
