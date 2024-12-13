import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixel_app_flutter/data/services/data_source/bluetooth_data_source.dart';
import 'package:pixel_app_flutter/data/services/data_source/mixins/parse_bytes_package_mixin.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/incoming_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/outgoing/value_request.dart';
import 'package:re_seedwork/re_seedwork.dart';

class BluetoothSerialMock extends Mock implements FlutterBluetoothSerial {}

class BluetoothConnectionMock extends Mock implements BluetoothConnection {}

class BluetoothStreamSinkMock extends Mock
    implements BluetoothStreamSink<Uint8List> {}

void main() {
  group('PopFirstExtension', () {
    final set1 = [23, 53, 123];
    final set2 = [66, 74, 34, 90];

    final bb = <int>[];
    setUp(bb.clear);
    group('popFirst() method', () {
      test(
          'returns empty list and does not '
          'remove nothing when passing 0 as count param', () {
        // arrange
        bb.addAll(set1);

        // assert
        expect(bb.popFirst(0), isEmpty);
        expect(bb, equals(set1));
        expect(bb.length, set1.length);
      });

      test(
        'returns whole list when passing as count '
        'a number bigger that buffer length, and clears the buffer',
        () {
          // arrange
          bb.addAll(set1);

          // assert
          expect(bb.popFirst(set1.length + 1), set1);
          expect(bb, isEmpty);
          expect(bb.length, 0);
        },
      );

      test(
        'returns n items(more than 0 and less than buffer length) '
        'and removes them from buffer',
        () {
          // arrange
          bb
            ..addAll(set1)
            ..addAll(set2);

          // assert
          expect(bb.popFirst(set1.length), set1);
          expect(bb, set2);
          expect(bb.length, set2.length);
        },
      );
    });
  });

  group('BluetoothDataSource', () {
    const deviceAddress = '123';
    const someRandomAddress = 'someRandomAddress';

    late StreamController<Uint8List> inputStreamController;

    final serial = BluetoothSerialMock();
    final connection = BluetoothConnectionMock();
    final sink = BluetoothStreamSinkMock();

    late BluetoothDataSource ds;

    setUp(() {
      inputStreamController = StreamController<Uint8List>();
      reset(serial);
      reset(connection);
      reset(sink);
      ds = BluetoothDataSource(
        bluetoothSerial: serial,
        permissionRequestCallback: () async => true,
        connectToAddress: (address) async => connection,
      );

      when(() => serial.isAvailable).thenAnswer((invocation) async => true);
      when(() => serial.isEnabled).thenAnswer((invocation) async => true);
      when(serial.getBondedDevices).thenAnswer(
        (invocation) async => [
          const BluetoothDevice(address: deviceAddress),
        ],
      );
      //
      when(() => connection.input)
          .thenAnswer((invocation) => inputStreamController.stream);
      when(() => connection.output).thenAnswer((invocation) => sink);
      when(sink.close).thenAnswer((_) async {});

      when(connection.close).thenAnswer((invocation) async {});
      when(connection.dispose).thenAnswer((invocation) async {});
    });

    void addBytesToStream(List<int> bytes, {int delayInMillis = 50}) {
      for (var i = 0; i < bytes.length;) {
        final nextI = i + Random().nextInt(20);
        final chunk = bytes.sublist(
          i,
          min(nextI, bytes.length),
        );
        inputStreamController.sink.add(Uint8List.fromList(chunk));

        i = nextI;
      }

      inputStreamController.close();
    }

    Future<void> assertStreamEventsCount(
      int expectableEventsCount, {
      bool awaitNoBytesInBufferToComplete = true,
    }) async {
      var incomingEvents = 0;

      final sub = ds.packageStream.listen((event) => incomingEvents++);

      await inputStreamController.done;

      if (awaitNoBytesInBufferToComplete) await ds.noBytesInBufferFuture;

      expect(incomingEvents, equals(expectableEventsCount));

      await sub.cancel();
    }

    void runActionWithZeroDelay(void Function() action) {
      Future<void>.delayed(Duration.zero).then(
        (value) => action(),
      );
    }

    group('connect method', () {
      test('returns value when device is in the bonded device list', () async {
        expect((await ds.connect(deviceAddress)).isValue, isTrue);

        verify(serial.getBondedDevices).called(1);
        verify(() => connection.input).called(1);
        verify(() => connection.output).called(1);
        verifyNever(() => serial.bondDeviceAtAddress(deviceAddress));
      });

      group("bonds device if it's not bonded", () {
        test('returns value when bonding is succesfull', () async {
          when(() => serial.bondDeviceAtAddress(someRandomAddress)).thenAnswer(
            (invocation) async => true,
          );

          expect((await ds.connect(someRandomAddress)).isValue, true);

          verify(serial.getBondedDevices).called(1);
          verify(() => connection.input).called(1);
          verify(() => connection.output).called(1);
          verify(() => serial.bondDeviceAtAddress(someRandomAddress)).called(1);
        });

        test(
            'returns ConnectError.bondingError '
            'when bonding is unsuccesfull(bondDeviceAtAddress returned false)',
            () async {
          when(() => serial.bondDeviceAtAddress(someRandomAddress)).thenAnswer(
            (invocation) async => false,
          );

          expect(
            await ds.connect(someRandomAddress),
            isA<Result<ConnectError, void>>().having(
              (result) => result.when(error: (e) => e, value: (_) => null),
              'ConnectError.bondingError',
              equals(ConnectError.bondingError),
            ),
          );

          verify(serial.getBondedDevices).called(1);
          verify(() => serial.bondDeviceAtAddress(someRandomAddress)).called(1);
          verifyNever(() => connection.input);
          verifyNever(() => connection.output);
        });

        test(
            'returns ConnectError.bondingError '
            'when bonding is unsuccesfull(bondDeviceAtAddress returned null)',
            () async {
          when(() => serial.bondDeviceAtAddress(someRandomAddress)).thenAnswer(
            (invocation) async => null,
          );

          expect(
            await ds.connect(someRandomAddress),
            isA<Result<ConnectError, void>>().having(
              (result) => result.when(error: (e) => e, value: (_) => null),
              'ConnectError.bondingError',
              equals(ConnectError.bondingError),
            ),
          );

          verify(serial.getBondedDevices).called(1);
          verify(() => serial.bondDeviceAtAddress(someRandomAddress)).called(1);
          verifyNever(() => connection.input);
          verifyNever(() => connection.output);
        });
      });
    });

    group('tryParse()', () {
      test('does nothing when buffer length is less than 9', () {
        // arrange
        ds.buffer.addAll([1, 2, 3]);

        // act
        ds.tryParse(ds.controller.add);

        // assert
        expect(ds.buffer, equals([1, 2, 3]));
      });

      group('if the first byte is not a starting byte', () {
        test('cleares the buffer if there is no starting byte in it', () async {
          // arrange
          ds.buffer.addAll([1, 2, 3, 4, 5, 6, 0, 16, 34, 23]);

          // act
          runActionWithZeroDelay(() {
            ds.tryParse(ds.controller.add);
            ds.controller.close();
          });

          // assert
          await expectLater(
            ds.controller.stream,
            neverEmits(isA<DataSourceIncomingPackage>()),
          );
          expect(ds.buffer, isEmpty);
        });

        test(
            'removes every byte until the starting one '
            'when there is a starting byte in the buffer, '
            'and does nothing more if the buffer length after byte removing '
            'is less than the minimum package length', () async {
          // arrange
          ds.buffer.addAll([1, 2, 3, 4, 5, 6, 60, 0, 16]);

          // act
          runActionWithZeroDelay(() {
            ds.tryParse(ds.controller.add);
            ds.controller.close();
          });

          // assert
          await expectLater(
            ds.controller.stream,
            neverEmits(isA<DataSourceIncomingPackage>()),
          );
          expect(ds.buffer, equals([60, 0, 16]));
        });
        test(
            'removes every byte until the starting one '
            'when there is a starting byte in the buffer, and parses the rest '
            'when in the buffer remained more than or equal '
            'to minimum package length', () async {
          // arrange
          const validPackage = [60, 0, 149, 136, 1, 3, 97, 124, 6, 75, 214, 62];
          ds.buffer.addAll([
            1, 2, 3, 4, 5, 6, //
            ...validPackage,
          ]);

          // act
          runActionWithZeroDelay(() => ds.tryParse(ds.controller.add));

          // assert
          await expectLater(
            ds.controller.stream,
            emits(isA<BatteryPowerIncomingDataSourcePackage>()),
          );
          expect(ds.buffer, isEmpty);
        });

        test(
            'removes every byte until the starting one '
            'when there is a starting byte in the buffer '
            'and does nothing more when there is no ending byte in the buffer',
            () async {
          // arrange
          const noEndingByte = [60, 0, 144, 0, 0, 0, 222, 71];
          ds.buffer.addAll([
            1, 2, 3, 4, 5, 6, // invalid beggining, should be removed
            ...noEndingByte,
          ]);

          // act
          runActionWithZeroDelay(() {
            ds.tryParse(ds.controller.add);
            ds.controller.close();
          });

          // assert
          await expectLater(
            ds.controller.stream,
            neverEmits(isA<DataSourceIncomingPackage>()),
          );
          expect(ds.buffer, equals(noEndingByte));
        });
      });

      group('there is no ending byte at index where it should be', () {
        test('if new starting byte was not found, cleares the buffer',
            () async {
          // arrange
          // Instead of 43 should be 62(ending byte)
          const endingByteInWrongPlace = [
            60, 0, 144, 0, 0, 0, 222, 71, 43, //
            62, // This is a wrong place
          ];
          ds.buffer.addAll(endingByteInWrongPlace);

          // act
          runActionWithZeroDelay(() {
            ds.tryParse(ds.controller.add);
            ds.controller.close();
          });

          // assert
          await expectLater(
            ds.controller.stream,
            neverEmits(isA<DataSourceIncomingPackage>()),
          );
          expect(ds.buffer, isEmpty);
        });
        test('if new starting byte was found, removes everything until it',
            () async {
          // arrange
          // Instead of 43 should be 62(ending byte)
          const endingByteInWrongPlace = [
            60, 0, 144, 0, 0, 0, 222, 71, 43, //
            62, 43, 60,
          ];
          ds.buffer.addAll(endingByteInWrongPlace);

          // act
          runActionWithZeroDelay(() {
            ds.tryParse(ds.controller.add);
            ds.controller.close();
          });

          // assert
          await expectLater(
            ds.controller.stream,
            neverEmits(isA<DataSourceIncomingPackage>()),
          );
          expect(ds.buffer, equals([60]));
        });
      });
    });

    group('parsing bytes into packages', () {
      test('All bytes are parsed into packages(valid bytes order)', () async {
        // arrange
        await ds.connect(deviceAddress);

        // act
        addBytesToStream(_correctBytesOrder);

        // assert
        await assertStreamEventsCount(49);
        expect(ds.buffer.length, isZero);
      });

      test('Parsing a package, which is not in the list of defined packages',
          () async {
        // arrange
        await ds.connect(deviceAddress);

        // act
        addBytesToStream(
          [
            60, //
            0, 149, //
            255, 255, //
            8, //
            97, 41, 5, 110, 254, 48, 0, 0, //
            129, 127, //
            62, //
          ],
        );

        // assert
        await assertStreamEventsCount(1);
        expect(ds.buffer.length, isZero);
      });

      group('skips invalid range of bytes and parses correctly the rest', () {
        test('(no starting byte)', () async {
          // arrange
          await ds.connect(deviceAddress);

          // act
          addBytesToStream(_noStartingByte);

          // assert
          await assertStreamEventsCount(3);
          expect(ds.buffer.length, isZero);
        });

        test(
            '(no ending byte. Parses valid packages '
            'and saves bytes without ending byte in the buffer)', () async {
          // arrange
          await ds.connect(deviceAddress);

          // act
          addBytesToStream(_noEndingByte);

          // assert
          await assertStreamEventsCount(
            3,
            awaitNoBytesInBufferToComplete: false,
          );
          expect(ds.buffer.length, equals(13));
        });
      });
    });

    test('disconnect method calls close() on connection', () async {
      // arrange
      await ds.connect(deviceAddress);

      // act
      await ds.disconnect();

      // assert
      verify(connection.close).called(1);
    });

    test(
      'cancedDeviceDiscovering calls FlutterBluetoothSerial.cancelDiscovery()',
      () async {
        // arrange
        when(serial.cancelDiscovery).thenAnswer((invocation) async {});

        // assert
        expect(
          await ds.cancelDeviceDiscovering(),
          isA<Result<CancelDeviceDiscoveringError, void>>().having(
            (p0) => p0.when(error: (_) => null, value: (_) => true),
            'returns Result.value()',
            isTrue,
          ),
        );

        verify(serial.cancelDiscovery).called(1);
      },
    );

    test(
      'getDeviceStream calls FlutterBluetoothSerial.startDiscovery() '
      'and maps all devices to DataSourceDevice',
      () async {
        // arrange
        const deviceCnt = 5;
        final devices = List.generate(
          deviceCnt,
          (index) => BluetoothDiscoveryResult(
            device: BluetoothDevice(
              address: '$index',
              name: '$index',
            ),
          ),
        );

        final controller = StreamController<BluetoothDiscoveryResult>();

        when(serial.startDiscovery).thenAnswer(
          (invocation) => controller.stream,
        );

        // act
        final res = await ds.getDevicesStream();

        // assert
        unawaited(
          expectLater(
            res.when(error: (_) => null, value: (s) => s),
            emitsInOrder(
              List.generate(
                deviceCnt,
                (index) => devices
                    .sublist(0, index + 1)
                    .map(
                      (e) => DataSourceDevice(
                        address: e.device.address,
                        name: e.device.name,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );

        await controller.addStream(Stream.fromIterable(devices));
        await controller.close();
        await ds.cachedDataSourceDevicesStreamController.close();

        verify(serial.startDiscovery).called(1);
      },
      timeout: const Timeout(Duration(seconds: 1)),
    );

    group('isAvailable', () {
      test(
        'returns true when FlutterBluetoothSerial.isAvailable returns true',
        () async {
          // arrange
          when(() => serial.isAvailable).thenAnswer((invocation) async => true);

          // assert
          expect(await ds.isAvailable, isTrue);

          verify(() => serial.isAvailable).called(1);
        },
      );
      test(
        'returns false when FlutterBluetoothSerial.isAvailable returns false',
        () async {
          // arrange
          when(() => serial.isAvailable)
              .thenAnswer((invocation) async => false);

          // assert
          expect(await ds.isAvailable, isFalse);

          verify(() => serial.isAvailable).called(1);
        },
      );
      test(
        'returns false when FlutterBluetoothSerial.isAvailable returns null',
        () async {
          // arrange
          when(() => serial.isAvailable).thenAnswer((invocation) async => null);

          // assert
          expect(await ds.isAvailable, isFalse);

          verify(() => serial.isAvailable).called(1);
        },
      );
    });
    group('isEnabled', () {
      test(
        'returns true when FlutterBluetoothSerial.isEnabled returns true',
        () async {
          // arrange
          when(() => serial.isEnabled).thenAnswer((invocation) async => true);

          // assert
          expect(await ds.isEnabled, isTrue);

          verify(() => serial.isEnabled).called(1);
        },
      );
      test(
        'returns false when FlutterBluetoothSerial.isEnabled returns false',
        () async {
          // arrange
          when(() => serial.isEnabled).thenAnswer((invocation) async => false);

          // assert
          expect(await ds.isEnabled, isFalse);

          verify(() => serial.isEnabled).called(1);
        },
      );
      test(
        'returns false when FlutterBluetoothSerial.isEnabled returns null',
        () async {
          // arrange
          when(() => serial.isEnabled).thenAnswer((invocation) async => null);

          // assert
          expect(await ds.isEnabled, isFalse);

          verify(() => serial.isEnabled).called(1);
        },
      );
    });

    group('enable()', () {
      test(
        'returns EnableError.isUnavailable '
        'if isAvailable returns false',
        () async {
          // arrange
          when(() => serial.isAvailable).thenAnswer(
            (invocation) async => false,
          );

          // assert
          expect(
            await ds.enable(),
            isA<Result<EnableError, void>>().having(
              (p0) => p0.when(error: (e) => e, value: (_) => _),
              'returns EnableError.isUnavailable',
              equals(EnableError.isUnavailable),
            ),
          );
          verifyNever(serial.requestEnable);
        },
      );

      test(
        'returns EnableError.isAlreadyEnabled '
        'if isEnabled returns true',
        () async {
          // arrange
          when(() => serial.isAvailable).thenAnswer(
            (invocation) async => true,
          );
          when(() => serial.isEnabled).thenAnswer(
            (invocation) async => true,
          );

          // assert
          expect(
            await ds.enable(),
            isA<Result<EnableError, void>>().having(
              (p0) => p0.when(error: (e) => e, value: (_) => _),
              'returns EnableError.isAlreadyEnabled',
              equals(EnableError.isAlreadyEnabled),
            ),
          );
          verifyNever(serial.requestEnable);
        },
      );

      group(
        'calls FlutterBluetoothSerial.requestEnable() when '
        'isAvailable is true and isEnabled isFalse',
        () {
          test(
            'returns EnableError.unsuccessfulEnableAttempt '
            'if FlutterBluetoothSerial.requestEnable() returns false',
            () async {
              // arrange
              when(() => serial.isAvailable).thenAnswer(
                (invocation) async => true,
              );
              when(() => serial.isEnabled).thenAnswer(
                (invocation) async => false,
              );
              when(serial.requestEnable).thenAnswer(
                (invocation) async => false,
              );

              // assert
              expect(
                await ds.enable(),
                isA<Result<EnableError, void>>().having(
                  (p0) => p0.when(error: (e) => e, value: (_) => _),
                  'returns EnableError.unsuccessfulEnableAttempt',
                  equals(EnableError.unsuccessfulEnableAttempt),
                ),
              );
              verify(serial.requestEnable).called(1);
            },
          );
          test(
            'returns EnableError.unsuccessfulEnableAttempt '
            'if FlutterBluetoothSerial.requestEnable() returns null',
            () async {
              // arrange
              when(() => serial.isAvailable).thenAnswer(
                (invocation) async => true,
              );
              when(() => serial.isEnabled).thenAnswer(
                (invocation) async => false,
              );
              when(serial.requestEnable).thenAnswer(
                (invocation) async => null,
              );

              // assert
              expect(
                await ds.enable(),
                isA<Result<EnableError, void>>().having(
                  (p0) => p0.when(error: (e) => e, value: (_) => _),
                  'returns EnableError.unsuccessfulEnableAttempt',
                  equals(EnableError.unsuccessfulEnableAttempt),
                ),
              );
              verify(serial.requestEnable).called(1);
            },
          );
          test(
            'returns Result.value() '
            'if FlutterBluetoothSerial.requestEnable() returns true',
            () async {
              // arrange
              when(() => serial.isAvailable).thenAnswer(
                (invocation) async => true,
              );
              when(() => serial.isEnabled).thenAnswer(
                (invocation) async => false,
              );
              when(serial.requestEnable).thenAnswer(
                (invocation) async => true,
              );

              // assert
              expect(
                await ds.enable(),
                isA<Result<EnableError, void>>().having(
                  (p0) => p0.isValue,
                  'returns Result.value()',
                  isTrue,
                ),
              );
              verify(serial.requestEnable).called(1);
            },
          );
        },
      );

      group('sendEvent()', () {
        test(
          'returns SendEventError.noConnection '
          'when connection was not established',
          () async {
            // assert
            expect(
              await ds.sendPackage(
                OutgoingValueRequestPackage(
                  parameterId: const DataSourceParameterId.speed(),
                ),
              ),
              isA<Result<SendPackageError, void>>().having(
                (p0) => p0.when(error: (e) => e, value: (v) => v),
                'returns SendEventError.noConnection',
                equals(SendPackageError.noConnection),
              ),
            );
          },
        );
        test(
          'adds bytes from package to connection.output '
          'and returns Result.value() when connection is established',
          () async {
            // arrange
            await ds.connect(deviceAddress);

            final package = OutgoingValueRequestPackage(
              parameterId: const DataSourceParameterId.speed(),
            );

            final bytes = package.toUint8List;

            when(() => sink.add(bytes)).thenAnswer((invocation) {});

            // assert
            expect(
              await ds.sendPackage(package),
              isA<Result<SendPackageError, void>>().having(
                (p0) => p0.isValue,
                'returns Result.value()',
                isTrue,
              ),
            );
            verify(() => sink.add(bytes)).called(1);
          },
        );
      });

      test('key getter returns always the same string', () {
        final secondInstance = BluetoothDataSource(
          bluetoothSerial: serial,
          permissionRequestCallback: () async => true,
          connectToAddress: (address) async => connection,
        );
        expect(secondInstance.key, equals(ds.key));
      });
    });

    group('observe feature', () {
      test('adds observer on new incoming event and outgoing', () async {
        await ds.connect(deviceAddress);
        final outgoingEvent = OutgoingValueRequestPackage(
          parameterId: const DataSourceParameterId.speed(),
        );
        const incomingPackage = [60, 0, 149, 84, 0, 3, 97, 124, 6, 56, 169, 62];
        // var incomingEventsCounter = 0;
        final events = <List<int>>[];
        ds.addObserver((observable) {
          observable.whenOrNull(
            rawIncomingPackage: events.add,
            outgoingPackage: events.add,
          );
        });

        // act
        await ds.sendPackage(outgoingEvent);
        inputStreamController.add(Uint8List.fromList(incomingPackage));
        await inputStreamController.close();
        await inputStreamController.done;

        // assert
        expect(
          events,
          equals([
            outgoingEvent.toUint8List,
            incomingPackage,
          ]),
        );
      });
    });

    test(
      'on dispose disposes everything that needs to be disposed',
      () async {
        // arrange
        await ds.connect(deviceAddress);
        ds.addObserver((_) {});

        // act
        ds.debouncer.run(() {});
        await ds.dispose();

        expect(ds.observers, isEmpty);
        expect(ds.debouncer.isCompleted, isTrue);
        expect(ds.subscription, isNull);
        expect(ds.controller.isClosed, isTrue);
        verify(connection.close).called(1);
        verify(connection.dispose).called(1);
      },
    );

    group('awaitNoBytesInBufferCompleter', () {
      group('noBytesInBuffer getter', () {
        test('initially is true', () {
          // assert
          expect(ds.noBytesInBuffer, isTrue);
        });

        test('becomes true when were received new bytes', () {
          ds.buffer.addAll([1, 2, 3]);
          ds.tryParse(ds.controller.add);
          expect(ds.noBytesInBuffer, isFalse);
        });

        test('becomes false when no bytes remained in buffer', () {
          ds.buffer.addAll([60, 0, 149, 84, 0, 3, 97, 124, 6, 56, 169, 62]);
          ds.tryParse(ds.controller.add);
          expect(ds.noBytesInBuffer, isTrue);
        });
      });

      group('noBytesInBufferFuture getter', () {
        test(' initially is completed', () async {
          final stopwatch = Stopwatch()..start();
          await ds.noBytesInBufferFuture;
          stopwatch.stop();
          final elapsed = stopwatch.elapsedMilliseconds;
          // Tolerance 5 milliseconds
          expect(elapsed, lessThanOrEqualTo(5));
        });

        test(
            'sets new completer when were received new bytes '
            'and does not complete until there are bytes in buffer', () async {
          ds.buffer.addAll([1, 2, 3]);
          ds.tryParse(ds.controller.add);

          await expectLater(
            ds.noBytesInBufferFuture
                .timeout(Duration(milliseconds: ds.debouncer.milliseconds * 2)),
            throwsA(isA<TimeoutException>()),
          );
        });

        test('completer when no bytes remained in buffer', () async {
          ds.buffer.addAll([60, 0, 149, 84, 0, 3, 97, 124, 6, 56, 169, 62]);
          ds.tryParse(ds.controller.add);
          final stopwatch = Stopwatch()..start();
          await ds.noBytesInBufferFuture;
          stopwatch.stop();
          final elapsed = stopwatch.elapsedMilliseconds;
          // Tolerance 5 milliseconds
          expect(elapsed, lessThanOrEqualTo(5));
        });
      });
    });

    tearDown(() {
      inputStreamController.close();
      ds.dispose();
    });
  });
}

const _noStartingByte = [
  0, 149, 6, 1, 5, 97, 127, 0, 127, 0, 120, 114, 62, //
  60, 0, 149, 6, 1, 5, 97, 128, 0, 128, 0, 106, 72, 62, //
  60, 0, 149, 6, 1, 5, 97, 129, 0, 129, 0, 9, 77, 62, //
  60, 0, 149, 84, 0, 3, 97, 124, 6, 56, 169, 62, //
];

const _noEndingByte = [
  60, 0, 144, 255, 255, 4, 29, 109, 37, 0, 138, 111, 62, //
  60, 0, 149, 6, 1, 5, 97, 137, 0, 137, 0, 17, 102, 62, //
  60, 0, 149, 6, 1, 5, 97, 138, 0, 138, 0, 180, 105, 62, //
  60, 0, 149, 6, 1, 5, 97, 139, 0, 139, 0, 215, 108, //
];

const _correctBytesOrder = [
  60, 0, 149, 6, 1, 5, 97, 127, 0, 127, 0, 120, 114, 62, //
  60, 0, 149, 6, 1, 5, 97, 128, 0, 128, 0, 106, 72, 62, //
  60, 0, 149, 6, 1, 5, 97, 129, 0, 129, 0, 9, 77, 62, //
  60, 0, 149, 84, 0, 3, 97, 124, 6, 56, 169, 62, //
  60, 0, 149, 6, 1, 5, 97, 130, 0, 130, 0, 172, 66, 62, //
  60, 0, 149, 6, 1, 5, 97, 131, 0, 131, 0, 207, 71, 62, //
  60, 0, 144, 255, 255, 4, 20, 103, 37, 0, 147, 229, 62, //
  60, 0, 149, 6, 1, 5, 97, 132, 0, 132, 0, 230, 93, 62, //
  60, 0, 149, 84, 0, 3, 97, 81, 3, 222, 109, 62, //
  60, 0, 149, 6, 1, 5, 97, 133, 0, 133, 0, 133, 88, 62, //
  60, 0, 149, 6, 1, 5, 97, 134, 0, 134, 0, 32, 87, 62, //
  60, 0, 149, 6, 1, 5, 97, 135, 0, 135, 0, 67, 82, 62, //
  60, 0, 149, 84, 0, 3, 97, 243, 7, 181, 183, 62, //
  60, 0, 149, 6, 1, 5, 97, 136, 0, 136, 0, 114, 99, 62, //
  60, 0, 144, 255, 255, 4, 29, 109, 37, 0, 138, 111, 62, //
  60, 0, 149, 6, 1, 5, 97, 137, 0, 137, 0, 17, 102, 62, //
  60, 0, 149, 6, 1, 5, 97, 138, 0, 138, 0, 180, 105, 62, //
  60, 0, 149, 6, 1, 5, 97, 139, 0, 139, 0, 215, 108, 62, //
  60, 0, 149, 84, 0, 3, 97, 180, 247, 84, 75, 62, //
  60, 0, 149, 6, 1, 5, 97, 140, 0, 140, 0, 254, 118, 62, //
  60, 0, 149, 6, 1, 5, 97, 141, 0, 141, 0, 157, 115, 62, //
  60, 0, 149, 6, 1, 5, 97, 142, 0, 142, 0, 56, 124, 62, //
  60, 0, 144, 255, 255, 4, 38, 115, 37, 0, 227, 118, 62, //
  60, 0, 149, 84, 0, 3, 97, 22, 252, 200, 105, 62, //
  60, 0, 149, 6, 1, 5, 97, 143, 0, 143, 0, 91, 121, 62, //
  60, 0, 149, 6, 1, 5, 97, 144, 0, 144, 0, 90, 30, 62, //
  60, 0, 149, 6, 1, 5, 97, 145, 0, 145, 0, 57, 27, 62, //
  60, 0, 149, 84, 0, 3, 97, 67, 242, 249, 45, 62, //
  60, 0, 149, 6, 1, 5, 97, 146, 0, 146, 0, 156, 20, 62, //
  60, 0, 149, 6, 1, 5, 97, 147, 0, 147, 0, 255, 17, 62, //
  60, 0, 144, 255, 255, 4, 32, 121, 37, 0, 3, 78, 62, //
  60, 0, 149, 6, 1, 5, 97, 148, 0, 148, 0, 214, 11, 62, //
  60, 0, 149, 6, 1, 5, 97, 149, 0, 149, 0, 181, 14, 62, //
  60, 0, 149, 84, 0, 3, 97, 87, 247, 165, 136, 62, //
  60, 0, 149, 6, 1, 5, 97, 150, 0, 150, 0, 16, 1, 62, //
  60, 0, 149, 6, 1, 5, 97, 151, 0, 151, 0, 115, 4, 62, //
  60, 0, 149, 6, 1, 5, 97, 152, 0, 152, 0, 66, 53, 62, //
  60, 0, 144, 255, 255, 4, 56, 127, 37, 0, 163, 190, 62, //
  60, 0, 149, 84, 0, 3, 97, 191, 242, 81, 248, 62, //
  60, 0, 149, 6, 1, 5, 97, 153, 0, 153, 0, 33, 48, 62, //
  60, 0, 149, 6, 1, 5, 97, 154, 0, 154, 0, 132, 63, 62, //
  60, 0, 149, 6, 1, 5, 97, 155, 0, 155, 0, 231, 58, 62, //
  60, 0, 149, 84, 0, 3, 97, 92, 252, 222, 210, 62, //
  60, 0, 149, 6, 1, 5, 97, 156, 0, 156, 0, 206, 32, 62, //
  60, 0, 149, 6, 1, 5, 97, 157, 0, 157, 0, 173, 37, 62, //
  60, 0, 144, 255, 255, 4, 65, 133, 37, 0, 203, 226, 62, //
  60, 0, 149, 6, 1, 5, 97, 158, 0, 158, 0, 8, 42, 62, //
  60, 0, 149, 6, 1, 5, 97, 159, 0, 159, 0, 107, 47, 62, //
  60, 0, 149, 84, 0, 3, 97, 13, 11, 193, 155, 62, //
];
