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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:metrics/metrics_graphite.dart';
import 'package:test/test.dart';

main() {
  group('', () {
    late ServerSocket serverSocket;
    late Graphite graphite;

    setUp(() async {
      serverSocket = await startServer(9000);
      graphite = Graphite(serverSocket.address, serverSocket.port);
    });

    tearDown(() => Future.wait([serverSocket.close(), graphite.close()]));

    test('graphite is not connected', () {
      expect(graphite.isConnected, isFalse);
      serverSocket.length.then(expectAsync1((int l) => expect(l, isZero)));
      return serverSocket.close();
    });

    test('measures failures', () {
      expect(graphite.failures, isZero);
    });

    test('connects to graphite', () {
      var con = 0;
      serverSocket.listen((s) =>
          utf8.decodeStream(s).then((_) => con++).then((_) => s.close()));
      graphite
          .connect()
          .then((_) => graphite.close())
          .then((_) => serverSocket.close())
          .then(expectAsync1((_) => expect(con, equals(1))));
    });

    test('disconnects from graphite', () {
      serverSocket.listen((s) => utf8.decodeStream(s).then((_) => s.close()));
      graphite
          .connect()
          .then((_) => graphite.close())
          .then(expectAsync1((_) => expect(graphite.isConnected, isFalse)));
    });

    test('does not allow double connections', () {
      serverSocket.listen((s) => utf8.decodeStream(s).then((_) => s.close()));
      graphite.connect().then(expectAsync1((_) {
        expect(() => graphite.connect(), throwsStateError);
      }));
    });

    test('writes values to graphite', () {
      final line = Completer<String>();
      serverSocket.listen((s) => utf8
          .decodeStream(s)
          .then((datas) => line.complete(datas))
          .then((_) => s.close()));
      graphite
          .connect()
          .then((_) => graphite.send(
              'name',
              'value',
              DateTime.fromMillisecondsSinceEpoch(
                  100 * Duration.millisecondsPerSecond)))
          .then((_) => graphite.close())
          .then((_) => line.future)
          .then(expectAsync1((s) => expect(s, equals('name value 100\n'))));
    });

    test('sanitizes names', () {
      final line = Completer<String>();
      serverSocket.listen((s) => utf8
          .decodeStream(s)
          .then((datas) => line.complete(datas))
          .then((_) => s.close()));
      graphite
          .connect()
          .then((_) => graphite.send(
              'name woo',
              'value',
              DateTime.fromMillisecondsSinceEpoch(
                  100 * Duration.millisecondsPerSecond)))
          .then((_) => graphite.close())
          .then((_) => line.future)
          .then(expectAsync1((s) => expect(s, equals('name-woo value 100\n'))));
    });

    test('sanitizes values', () {
      final line = Completer<String>();
      serverSocket.listen((s) => utf8
          .decodeStream(s)
          .then((datas) => line.complete(datas))
          .then((_) => s.close()));
      graphite
          .connect()
          .then((_) => graphite.send(
              'name',
              'value woo',
              DateTime.fromMillisecondsSinceEpoch(
                  100 * Duration.millisecondsPerSecond)))
          .then((_) => graphite.close())
          .then((_) => line.future)
          .then(expectAsync1((s) => expect(s, equals('name value-woo 100\n'))));
    });
  });
}

Future<ServerSocket> startServer(int port) =>
    ServerSocket.bind('localhost', port)
        .catchError((_) => startServer(port + 1));
