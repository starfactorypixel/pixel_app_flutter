import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/data/services/data_source/mixins/default_data_source_observer_mixin.dart';
import 'package:pixel_app_flutter/data/services/data_source/mixins/package_stream_controller_mixin.dart';
import 'package:pixel_app_flutter/data/services/data_source/mixins/parse_bytes_package_mixin.dart';
import 'package:pixel_app_flutter/data/services/data_source/mixins/send_packages_mixin.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/outgoing/authorizartion.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/outgoing/outgoing_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:re_seedwork/re_seedwork.dart';

class DemoDataSource extends DataSource
    with
        ParseBytesPackageMixin,
        DefaultDataSourceObserverMixin,
        PackageStreamControllerMixin,
        SendPackagesMixin {
  DemoDataSource({
    required this.generateRandomErrors,
    required this.updatePeriodMillis,
  })  : subscriptionCallbacks = {},
        isInitialHandshake = true,
        super(key: kKey);

  @protected
  final int Function() updatePeriodMillis;

  @protected
  final bool Function() generateRandomErrors;

  static const kKey = 'demo';

  @protected
  @visibleForTesting
  bool isInitialHandshake;

  @protected
  Result<E, V> returnValueOrErrorFromList<E extends Enum, V>(
    List<E> en,
    V value,
  ) {
    if (generateRandomErrors() && math.Random().nextBool()) {
      final errorIndex = math.Random().nextInt(en.length);
      final error = en[errorIndex];
      return Result.error(error);
    }

    return Result<E, V>.value(value);
  }

  @visibleForTesting
  StreamController<List<DataSourceDevice>>? deviceStream;

  @visibleForTesting
  final Set<void Function()> subscriptionCallbacks;

  @visibleForTesting
  Timer? timer;

  @override
  Future<Result<CancelDeviceDiscoveringError, void>>
      cancelDeviceDiscovering() async {
    return returnValueOrErrorFromList(
      CancelDeviceDiscoveringError.values,
      null,
    );
  }

  @override
  Future<Result<ConnectError, void>> connect(String address) async {
    return returnValueOrErrorFromList(ConnectError.values, null);
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    timer?.cancel();
    timer = null;
  }

  @override
  Future<Result<EnableError, void>> enable() async {
    return returnValueOrErrorFromList(EnableError.values, null);
  }

  @override
  Stream<DataSourceIncomingPackage> get packageStream => controller.stream;

  @override
  Future<Result<GetDeviceListError, Stream<List<DataSourceDevice>>>>
      getDevicesStream() async {
    await deviceStream?.close();
    deviceStream = null;
    deviceStream = StreamController.broadcast();

    const device1 = DataSourceDevice(
      address: 'testAdress1',
      isBonded: true,
      name: 'Device 1(bonded)',
    );

    const device2 = DataSourceDevice(
      address: 'testAdress2',
      name: 'Device 2(unbonded)',
    );

    // Adding bonded device to stream
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 200)).then((value) {
        deviceStream?.sink.add([device1]);
      }),
    );

    // Adding unbonded device to stream
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 2500)).then((value) {
        deviceStream?.sink.add([device1, device2]);
      }),
    );

    final _deviceStream = deviceStream;
    if (_deviceStream == null) {
      return const Result.error(GetDeviceListError.unknown);
    }

    return returnValueOrErrorFromList(
      GetDeviceListError.values,
      _deviceStream.stream,
    );
  }

  @override
  Future<bool> get isAvailable async {
    if (generateRandomErrors()) {
      return math.Random().nextBool();
    }

    return true;
  }

  @override
  Future<bool> get isEnabled async {
    if (generateRandomErrors()) {
      return math.Random().nextBool();
    }

    return true;
  }

  @override
  Future<Result<SendPackageError, void>> sendPackage(
    DataSourceOutgoingPackage package,
  ) async {
    observeOutgoing(package);

    final parameterId = package.parameterId;

    return package.requestType.maybeWhen(
      bufferRequest: () => _updateValue(package),
      event: () => _updateValue(package),
      handshake: () {
        const secondConfigByte = 0x90; // 10010000(incoming 0x10)
        Future<void>.delayed(const Duration(seconds: 1)).then(
          (value) {
            DataSourceIncomingPackage responsePackage;
            if (package is OutgoingAuthorizationInitializationRequestPackage) {
              responsePackage = DataSourceIncomingPackage.fromConvertible(
                secondConfigByte: secondConfigByte,
                parameterId: const DataSourceParameterId.authorization().value,
                convertible: AuthorizationInitializationResponse(
                  method: 0x01,
                  deviceId: List.generate(6, (index) => index),
                ),
              );
            } else if (package is OutgoingAuthorizationRequestPackage) {
              responsePackage = DataSourceIncomingPackage.fromConvertible(
                secondConfigByte: secondConfigByte,
                parameterId: const DataSourceParameterId.authorization().value,
                convertible: AuthorizationResponse(
                  success: !generateRandomErrors() || Random().nextBool(),
                  uptime: Duration.zero,
                ),
              );
            } else {
              final ping = DataSourceIncomingPackage.fromConvertible(
                secondConfigByte: secondConfigByte,
                parameterId: 0xFFFF,
                convertible: const HandshakeID(0xFFFF),
              );

              responsePackage = isInitialHandshake
                  ? DataSourceIncomingPackage.fromConvertible(
                      secondConfigByte: secondConfigByte,
                      parameterId: 0,
                      convertible: const EmptyHandshakeBody(),
                    )
                  : ping;

              if (isInitialHandshake) {
                Future<void>.delayed(const Duration(seconds: 1)).then(
                  (value) {
                    observeIncoming(ping);

                    if (!controller.isClosed) controller.add(ping);
                  },
                );
              }

              isInitialHandshake = false;
            }

            observeIncoming(responsePackage);

            if (!controller.isClosed) controller.add(responsePackage);
          },
        );

        return const Result.value(null);
      },
      subscription: () {
        if (parameterId.value > OutgoingUnsubscribePackage.kOperand) {
          // Unsubscribe package
          DataSourceParameterId.fromInt(
            parameterId.value - OutgoingUnsubscribePackage.kOperand,
          )
            ..voidOn<MotorSpeedParameterId>(
              () => subscriptionCallbacks.remove(_sendNewSpeedCallback),
            )
            ..voidOn<MotorVoltageParameterId>(
              () => subscriptionCallbacks.remove(_sendNewVoltageCallback),
            )
            ..voidOn<MotorCurrentParameterId>(
              () => subscriptionCallbacks.remove(_sendNewCurrentCallback),
            )
            ..voidOn<MotorPowerParameterId>(
              () => subscriptionCallbacks.remove(_sendNewPowerCallback),
            )
            ..voidOn<MotorTemperatureParameterId>(
              () => subscriptionCallbacks
                  .remove(_sendNewMotorTemperatureCallback),
            )
            ..voidOn<ControllerTemperatureParameterId>(
              () => subscriptionCallbacks
                  .remove(_sendNewControllerTemperatureCallback),
            )
            ..voidOn<OdometerParameterId>(
              () => subscriptionCallbacks.remove(_sendNewOdometerCallback),
            )
            ..voidOn<RPMParameterId>(
              () => subscriptionCallbacks.remove(_sendNewRPMCallback),
            )
            ..voidOn<GearAndRollParameterId>(
              () => subscriptionCallbacks.remove(_sendNewGearAndRollCallback),
            )
            ..voidOn<HighVoltageParameterId>(
              () => subscriptionCallbacks.remove(_sendHighVoltageCallback),
            )
            ..voidOn<HighCurrentParameterId>(
              () => subscriptionCallbacks.remove(_sendHighCurrentCallback),
            )
            ..voidOn<MaxTemperatureParameterId>(
              () => subscriptionCallbacks.remove(_sendMaxTemperatureCallback),
            )
            ..voidOn<BatteryLevelParameterId>(
              () => subscriptionCallbacks.remove(_sendNewBatteryLevelCallback),
            )
            ..voidOn<BatteryPowerParameterId>(
              () => subscriptionCallbacks.remove(_sendNewBatteryPowerCallback),
            )
            ..voidOn<CustomParameterId>(() {
              if (parameterId.value == 0x00E0) {
                subscriptionCallbacks.remove(_sendBackLightsBlocInfoCallback);
              }
            });

          return const Result.value(null);
        }

        parameterId
          ..voidOn<MotorSpeedParameterId>(
            () => subscriptionCallbacks.add(_sendNewSpeedCallback),
          )
          ..voidOn<MotorVoltageParameterId>(
            () => subscriptionCallbacks.add(_sendNewVoltageCallback),
          )
          ..voidOn<MotorCurrentParameterId>(
            () => subscriptionCallbacks.add(_sendNewCurrentCallback),
          )
          ..voidOn<MotorPowerParameterId>(
            () => subscriptionCallbacks.add(_sendNewPowerCallback),
          )
          ..voidOn<MotorTemperatureParameterId>(
            () => subscriptionCallbacks.add(_sendNewMotorTemperatureCallback),
          )
          ..voidOn<ControllerTemperatureParameterId>(
            () => subscriptionCallbacks
                .add(_sendNewControllerTemperatureCallback),
          )
          ..voidOn<OdometerParameterId>(
            () => subscriptionCallbacks.add(_sendNewOdometerCallback),
          )
          ..voidOn<RPMParameterId>(
            () => subscriptionCallbacks.add(_sendNewRPMCallback),
          )
          ..voidOn<GearAndRollParameterId>(
            () => subscriptionCallbacks.add(_sendNewGearAndRollCallback),
          )
          ..voidOn<HighVoltageParameterId>(
            () => subscriptionCallbacks.add(_sendHighVoltageCallback),
          )
          ..voidOn<HighCurrentParameterId>(
            () => subscriptionCallbacks.add(_sendHighCurrentCallback),
          )
          ..voidOn<MaxTemperatureParameterId>(
            () => subscriptionCallbacks.add(_sendMaxTemperatureCallback),
          )
          ..voidOn<BatteryLevelParameterId>(
            () => subscriptionCallbacks.add(_sendNewBatteryLevelCallback),
          )
          ..voidOn<BatteryPowerParameterId>(
            () => subscriptionCallbacks.add(_sendNewBatteryPowerCallback),
          )
          // Lights
          ..voidOn<FrontSideBeamParameterId>(() {
            _sendSetBoolUint8ResultCallback(const FrontSideBeamParameterId());
          })
          ..voidOn<TailSideBeamParameterId>(() {
            _sendSetBoolUint8ResultCallback(const TailSideBeamParameterId());
          })
          ..voidOn<LowBeamParameterId>(() {
            _sendSetBoolUint8ResultCallback(const LowBeamParameterId());
          })
          ..voidOn<ReverseLightParameterId>(() {
            _sendSetBoolUint8ResultCallback(const ReverseLightParameterId());
          })
          ..voidOn<BrakeLightParameterId>(() {
            _sendSetBoolUint8ResultCallback(const BrakeLightParameterId());
          })
          ..voidOn<CabinLightParameterId>(() {
            _sendSetBoolUint8ResultCallback(const CabinLightParameterId());
          })
          ..voidOn<HighBeamParameterId>(() {
            _sendSetBoolUint8ResultCallback(const HighBeamParameterId());
          })
          ..voidOn<FrontHazardBeamParameterId>(() {
            _sendSetBoolUint8ResultCallback(const FrontHazardBeamParameterId());
          })
          ..voidOn<TailHazardBeamParameterId>(() {
            _sendSetBoolUint8ResultCallback(const TailHazardBeamParameterId());
          })
          ..voidOn<FrontLeftTurnSignalParameterId>(() {
            _sendSetBoolUint8ResultCallback(
              const FrontLeftTurnSignalParameterId(),
            );
          })
          ..voidOn<FrontRightTurnSignalParameterId>(() {
            _sendSetBoolUint8ResultCallback(
              const FrontRightTurnSignalParameterId(),
            );
          })
          ..voidOn<TailLeftTurnSignalParameterId>(() {
            _sendSetBoolUint8ResultCallback(
              const TailLeftTurnSignalParameterId(),
            );
          })
          ..voidOn<TailRightTurnSignalParameterId>(() {
            _sendSetBoolUint8ResultCallback(
              const TailRightTurnSignalParameterId(),
            );
          })
          ..voidOn<CustomImageParameterId>(() {
            _sendSetUint8ResultCallback(
              const CustomImageParameterId(),
            );
          })
          ..voidOn<WindscreenWipersParameterId>(() {
            _sendSetBoolUint8ResultCallback(
              const WindscreenWipersParameterId(),
            );
          })
          ..voidOn<CustomParameterId>(() {
            switch (parameterId.value) {
              case 0x00E0:
                subscriptionCallbacks.add(_sendBackLightsBlocInfoCallback);
                break;
              case ButtonFunctionId.leftDoorId:
                _sendDoorToggleResultCallback(ButtonFunctionId.leftDoor);
                break;
              case ButtonFunctionId.rightDoorId:
                _sendDoorToggleResultCallback(ButtonFunctionId.rightDoor);
                break;
            }
          });

        timer ??= Timer.periodic(
          Duration(milliseconds: updatePeriodMillis()),
          (timer) {
            for (final element in subscriptionCallbacks) {
              try {
                element();
              } catch (e, s) {
                Future<void>.error(
                  'Got error trying to send a package:\n$e',
                  s,
                );
              }
            }
          },
        );

        return const Result.value(null);
      },
      orElse: () => const Result.value(null),
    );
  }

  Result<SendPackageError, void> _updateValue(
    DataSourceOutgoingPackage package,
  ) {
    final id = package.parameterId;
    const v = DataSourceProtocolVersion.periodicRequests;

    id
      ..voidOn<MotorSpeedParameterId>(() => _sendNewSpeedCallback(version: v))
      ..voidOn<MotorCurrentParameterId>(
        () => _sendNewCurrentCallback(version: v),
      )
      ..voidOn<MotorVoltageParameterId>(
        () => _sendNewVoltageCallback(version: v),
      )
      ..voidOn<MotorPowerParameterId>(() => _sendNewPowerCallback(version: v))
      ..voidOn<OdometerParameterId>(() => _sendNewOdometerCallback(version: v))
      ..voidOn<GearAndRollParameterId>(
        () => _sendNewGearAndRollCallback(version: v),
      )
      ..voidOn<MotorTemperatureParameterId>(
        () => _sendNewMotorTemperatureCallback(version: v),
      )
      ..voidOn<ControllerTemperatureParameterId>(
        () => _sendNewControllerTemperatureCallback(version: v),
      )
      ..voidOn<RPMParameterId>(() => _sendNewRPMCallback(version: v))
      ..voidOn<LowVoltageMinMaxDeltaParameterId>(_sendNewLowVoltageCallback)
      ..voidOn<HighVoltageParameterId>(_sendHighVoltageCallback)
      ..voidOn<HighCurrentParameterId>(_sendHighCurrentCallback)
      ..voidOn<MaxTemperatureParameterId>(_sendMaxTemperatureCallback)
      ..voidOn<BatteryLevelParameterId>(
        () => _sendNewBatteryLevelCallback(version: v),
      )
      ..voidOn<BatteryPowerParameterId>(
        () => _sendNewBatteryPowerCallback(version: v),
      )
      //
      ..voidOn<TemperatureFirstBatchParameterId>(
        _sendTemperatureFirstBatchCallback,
      )
      ..voidOn<TemperatureSecondBatchParameterId>(
        _sendTemperatureSecondBatchCallback,
      )
      ..voidOn<TemperatureThirdBatchParameterId>(
        _sendTemperatureThirdBatchCallback,
      )
      //
      ..voidOn<LowVoltageOneToThreeParameterId>(
        _sendLowVoltageOneToThreeCallback,
      )
      ..voidOn<LowVoltageFourToSixParameterId>(_sendLowVoltageFourToSixCallback)
      ..voidOn<LowVoltageSevenToNineParameterId>(
        _sendLowVoltageSevenToNineCallback,
      )
      ..voidOn<LowVoltageTenToTwelveParameterId>(
        _sendLowVoltageTenToTwelveCallback,
      )
      ..voidOn<LowVoltageThirteenToFifteenParameterId>(
        _sendLowVoltageThirteenToFifteenCallback,
      )
      ..voidOn<LowVoltageSixteenToEighteenParameterId>(
        _sendLowVoltageSixteenToEighteenCallback,
      )
      ..voidOn<LowVoltageNineteenToTwentyOneParameterId>(
        _sendLowVoltageNineteenToTwentyOneCallback,
      )
      ..voidOn<LowVoltageTwentyTwoToTwentyFourParameterId>(
        _sendLowVoltageTwentyTwoToTwentyFourCallback,
      )
      ..voidOn<LowVoltageTwentyFiveToTwentySevenParameterId>(
        _sendLowVoltageTwentyFiveToTwentySevenCallback,
      )
      ..voidOn<LowVoltageTwentyEightToThirtyParameterId>(
        _sendLowVoltageTwentyEightToThirtyCallback,
      )
      ..voidOn<LowVoltageThirtyOneToThirtyThreeParameterId>(
        _sendLowVoltageThirtyOneToThirtyThreeCallback,
      )
      // Lights
      ..voidOn<FrontSideBeamParameterId>(() {
        _sendSetBoolUint8ResultCallback(
          const FrontSideBeamParameterId(),
          package.boolData,
        );
      })
      ..voidOn<TailSideBeamParameterId>(() {
        _sendSetBoolUint8ResultCallback(
          const TailSideBeamParameterId(),
          package.boolData,
        );
      })
      ..voidOn<LowBeamParameterId>(() {
        _sendSetBoolUint8ResultCallback(
          const LowBeamParameterId(),
          package.boolData,
        );
      })
      ..voidOn<ReverseLightParameterId>(() {
        _sendSetBoolUint8ResultCallback(
          const ReverseLightParameterId(),
          package.boolData,
        );
      })
      ..voidOn<BrakeLightParameterId>(() {
        _sendSetBoolUint8ResultCallback(
          const BrakeLightParameterId(),
          package.boolData,
        );
      })
      ..voidOn<CabinLightParameterId>(() {
        _sendSetBoolUint8ResultCallback(
          const CabinLightParameterId(),
          package.boolData,
        );
      })
      ..voidOn<HighBeamParameterId>(() {
        _sendSetBoolUint8ResultCallback(
          const HighBeamParameterId(),
          package.boolData,
        );
      })
      ..voidOn<FrontHazardBeamParameterId>(() {
        _sendSetBoolUint8ResultCallback(
          const FrontHazardBeamParameterId(),
          package.boolData,
        );
      })
      ..voidOn<TailHazardBeamParameterId>(() {
        _sendSetBoolUint8ResultCallback(
          const TailHazardBeamParameterId(),
          package.boolData,
        );
      })
      ..voidOn<FrontLeftTurnSignalParameterId>(() {
        _sendSetBoolUint8ResultCallback(
          const FrontLeftTurnSignalParameterId(),
          package.boolData,
        );
      })
      ..voidOn<FrontRightTurnSignalParameterId>(() {
        _sendSetBoolUint8ResultCallback(
          const FrontRightTurnSignalParameterId(),
          package.boolData,
        );
      })
      ..voidOn<TailLeftTurnSignalParameterId>(() {
        _sendSetBoolUint8ResultCallback(
          const TailLeftTurnSignalParameterId(),
          package.boolData,
        );
      })
      ..voidOn<TailRightTurnSignalParameterId>(() {
        _sendSetBoolUint8ResultCallback(
          const TailRightTurnSignalParameterId(),
          package.boolData,
        );
      })
      ..voidOn<WindscreenWipersParameterId>(() {
        _sendSetBoolUint8ResultCallback(
          const WindscreenWipersParameterId(),
          package.boolData,
        );
      })
      ..voidOn<CustomImageParameterId>(() {
        _sendSetUint8ResultCallback(
          const CustomImageParameterId(),
          package.data[1],
        );
      })
      // Doors
      ..voidOn<LeftDoorParameterId>(() {
        _sendDoorToggleResultCallback(ButtonFunctionId.leftDoor);
      })
      ..voidOn<RightDoorParameterId>(() {
        _sendDoorToggleResultCallback(ButtonFunctionId.rightDoor);
      });

    return const Result.value(null);
  }

  @override
  Future<Result<DisconnectError, void>> disconnect() async {
    return const Result.value(null);
  }

  void _sendNewSpeedCallback({
    DataSourceProtocolVersion version = DataSourceProtocolVersion.subscription,
  }) {
    _updateValueCallback(
      const DataSourceParameterId.motorSpeed(),
      TwoUint16WithStatusBody(
        status: _getRandomStatus,
        first: Random().nextInt(1001),
        second: Random().nextInt(1001),
      ),
      version,
    );
  }

  void _sendNewVoltageCallback({
    DataSourceProtocolVersion version = DataSourceProtocolVersion.subscription,
  }) {
    _sendTwoUint16Callback(
      const DataSourceParameterId.motorVoltage(),
      version: version,
    );
  }

  void _sendNewCurrentCallback({
    DataSourceProtocolVersion version = DataSourceProtocolVersion.subscription,
  }) {
    _sendTwoInt16Callback(
      const DataSourceParameterId.motorCurrent(),
      version: version,
    );
  }

  void _sendNewPowerCallback({
    DataSourceProtocolVersion version = DataSourceProtocolVersion.subscription,
  }) {
    _sendTwoInt16Callback(
      const DataSourceParameterId.motorPower(),
      version: version,
    );
  }

  void _sendNewRPMCallback({
    DataSourceProtocolVersion version = DataSourceProtocolVersion.subscription,
  }) {
    _sendTwoUint16Callback(
      const DataSourceParameterId.rpm(),
      version: version,
    );
  }

  void _sendNewMotorTemperatureCallback({
    DataSourceProtocolVersion version = DataSourceProtocolVersion.subscription,
  }) {
    _sendTwoInt16Callback(
      const MotorTemperatureParameterId(),
      version: version,
    );
  }

  void _sendNewControllerTemperatureCallback({
    DataSourceProtocolVersion version = DataSourceProtocolVersion.subscription,
  }) {
    _sendTwoInt16Callback(
      const ControllerTemperatureParameterId(),
      version: version,
    );
  }

  void _sendNewOdometerCallback({
    DataSourceProtocolVersion version = DataSourceProtocolVersion.subscription,
  }) {
    _updateValueCallback(
      const DataSourceParameterId.odometer(),
      Uint32WithStatusBody(
        value: Random().nextInt(0xFFFFFFFF),
        status: _getRandomStatus,
      ),
      version,
    );
  }

  void _sendNewGearAndRollCallback({
    DataSourceProtocolVersion version = DataSourceProtocolVersion.subscription,
  }) {
    final randomGear1 =
        MotorGear.values[Random().nextInt(MotorGear.values.length)];
    final randomGear2 =
        MotorGear.values[Random().nextInt(MotorGear.values.length)];
    final randomRoll1 = MotorRollDirection
        .values[Random().nextInt(MotorRollDirection.values.length)];
    final randomRoll2 = MotorRollDirection
        .values[Random().nextInt(MotorRollDirection.values.length)];
    _updateValueCallback(
      const DataSourceParameterId.gearAndRoll(),
      MotorGearAndRoll(
        firstMotorGear: randomGear1,
        firstMotorRollDirection: randomRoll1,
        secondMotorGear: randomGear2,
        secondMotorRollDirection: randomRoll2,
        status: _getRandomStatus,
      ),
      version,
    );
  }

  void _sendNewBatteryLevelCallback({
    DataSourceProtocolVersion version = DataSourceProtocolVersion.subscription,
  }) {
    _sendUint8Callback(
      const DataSourceParameterId.batteryLevel(),
      version: version,
      customValueGenerator: () => Random().nextInt(101),
    );
  }

  void _sendNewBatteryPowerCallback({
    DataSourceProtocolVersion version = DataSourceProtocolVersion.subscription,
  }) {
    _sendInt16Callback(
      const DataSourceParameterId.batteryPower(),
      version: version,
    );
  }

  void _sendUint8Callback(
    DataSourceParameterId id, {
    DataSourceProtocolVersion version = DataSourceProtocolVersion.subscription,
    int Function()? customValueGenerator,
  }) {
    _updateValueCallback(
      id,
      Uint8WithStatusBody(
        status: _getRandomStatus,
        value: customValueGenerator?.call() ?? randomUint8,
      ),
      version,
    );
  }

  void _sendInt16Callback(
    DataSourceParameterId id, {
    DataSourceProtocolVersion version = DataSourceProtocolVersion.subscription,
  }) {
    _updateValueCallback(
      id,
      Int16WithStatusBody(
        status: _getRandomStatus,
        value: randomInt16,
      ),
      version,
    );
  }

  void _sendTwoInt16Callback(
    DataSourceParameterId id, {
    DataSourceProtocolVersion version = DataSourceProtocolVersion.subscription,
  }) {
    _updateValueCallback(
      id,
      TwoInt16WithStatusBody(
        status: _getRandomStatus,
        first: randomInt16,
        second: randomInt16,
      ),
      version,
    );
  }

  void _sendTwoUint16Callback(
    DataSourceParameterId id, {
    DataSourceProtocolVersion version = DataSourceProtocolVersion.subscription,
  }) {
    _updateValueCallback(
      id,
      TwoUint16WithStatusBody(
        status: _getRandomStatus,
        first: randomUint16,
        second: randomUint16,
      ),
      version,
    );
  }

  void _sendNewLowVoltageCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId: const DataSourceParameterId.lowVoltageMinMaxDelta().value,
        convertible: LowVoltageMinMaxDelta(
          min: Random().nextDouble() * 65535,
          max: Random().nextDouble() * 65535,
          delta: Random().nextDouble() * 65535,
          status: _getRandomStatus,
        ),
      ),
    );
  }

  void _sendHighVoltageCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId: const DataSourceParameterId.highVoltage().value,
        convertible: HighVoltage(
          value: randomUint16,
          status: _getRandomStatus,
        ),
      ),
    );
  }

  void _sendHighCurrentCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId: const DataSourceParameterId.highCurrent().value,
        convertible: HighCurrent(
          batt1: randomInt16,
          batt2: randomInt16,
        ),
      ),
    );
  }

  void _sendMaxTemperatureCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId: const DataSourceParameterId.maxTemperature().value,
        convertible: MaxTemperature(
          value: randomInt8,
          status: _getRandomStatus,
        ),
      ),
    );
  }

  void _sendTemperatureFirstBatchCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId: const DataSourceParameterId.temperatureFirstBatch().value,
        convertible: BatteryTemperatureFirstBatch(
          balancer: randomInt8,
          mos: randomInt8,
          first: randomInt8,
          second: randomInt8,
          third: randomInt8,
          fourth: randomInt8,
          fifth: randomInt8,
        ),
      ),
    );
  }

  void _sendTemperatureSecondBatchCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId: const DataSourceParameterId.temperatureSecondBatch().value,
        convertible: BatteryTemperatureSecondBatch(
          sixth: randomInt8,
          seventh: randomInt8,
          eighth: randomInt8,
          ninth: randomInt8,
          tenth: randomInt8,
          eleventh: randomInt8,
          twelfth: randomInt8,
        ),
      ),
    );
  }

  void _sendTemperatureThirdBatchCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId: const DataSourceParameterId.temperatureThirdBatch().value,
        convertible: BatteryTemperatureThirdBatch(
          thirteenth: randomInt8,
          fourteenth: randomInt8,
          fifteenth: randomInt8,
          sixteenth: randomInt8,
          seventeenth: randomInt8,
          eighteenth: randomInt8,
          nineteenth: randomInt8,
        ),
      ),
    );
  }

  void _sendLowVoltageOneToThreeCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId: const DataSourceParameterId.lowVoltageOneToThree().value,
        convertible: BatteryLowVoltageOneToThree(
          first: randomDoubleUint16,
          second: randomDoubleUint16,
          third: randomDoubleUint16,
        ),
      ),
    );
  }

  void _sendLowVoltageFourToSixCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId: const DataSourceParameterId.lowVoltageFourToSix().value,
        convertible: BatteryLowVoltageFourToSix(
          fourth: randomDoubleUint16,
          fifth: randomDoubleUint16,
          sixth: randomDoubleUint16,
        ),
      ),
    );
  }

  void _sendLowVoltageSevenToNineCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId: const DataSourceParameterId.lowVoltageSevenToNine().value,
        convertible: BatteryLowVoltageSevenToNine(
          seventh: randomDoubleUint16,
          eighth: randomDoubleUint16,
          ninth: randomDoubleUint16,
        ),
      ),
    );
  }

  void _sendLowVoltageTenToTwelveCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId: const DataSourceParameterId.lowVoltageTenToTwelve().value,
        convertible: BatteryLowVoltageTenToTwelve(
          tenth: randomDoubleUint16,
          eleventh: randomDoubleUint16,
          twelfth: randomDoubleUint16,
        ),
      ),
    );
  }

  void _sendLowVoltageThirteenToFifteenCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId:
            const DataSourceParameterId.lowVoltageThirteenToFifteen().value,
        convertible: BatteryLowVoltageThirteenToFifteen(
          thirteenth: randomDoubleUint16,
          fourteenth: randomDoubleUint16,
          fifteenth: randomDoubleUint16,
        ),
      ),
    );
  }

  void _sendLowVoltageSixteenToEighteenCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId:
            const DataSourceParameterId.lowVoltageSixteenToEighteen().value,
        convertible: BatteryLowVoltageSixteenToEighteen(
          sixteenth: randomDoubleUint16,
          seventeenth: randomDoubleUint16,
          eighteenth: randomDoubleUint16,
        ),
      ),
    );
  }

  void _sendLowVoltageNineteenToTwentyOneCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId:
            const DataSourceParameterId.lowVoltageNineteenToTwentyOne().value,
        convertible: BatteryLowVoltageNineteenToTwentyOne(
          nineteenth: randomDoubleUint16,
          twentieth: randomDoubleUint16,
          twentyFirst: randomDoubleUint16,
        ),
      ),
    );
  }

  void _sendLowVoltageTwentyTwoToTwentyFourCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId:
            const DataSourceParameterId.lowVoltageTwentyTwoToTwentyFour().value,
        convertible: BatteryLowVoltageTwentyTwoToTwentyFour(
          twentySecond: randomDoubleUint16,
          twentyThird: randomDoubleUint16,
          twentyFourth: randomDoubleUint16,
        ),
      ),
    );
  }

  void _sendLowVoltageTwentyFiveToTwentySevenCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId:
            const DataSourceParameterId.lowVoltageTwentyFiveToTwentySeven()
                .value,
        convertible: BatteryLowVoltageTwentyFiveToTwentySeven(
          twentyFifth: randomDoubleUint16,
          twentySixth: randomDoubleUint16,
          twentySeventh: randomDoubleUint16,
        ),
      ),
    );
  }

  void _sendLowVoltageTwentyEightToThirtyCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId:
            const DataSourceParameterId.lowVoltageTwentyEightToThirty().value,
        convertible: BatteryLowVoltageTwentyEightToThirty(
          twentyEighth: randomDoubleUint16,
          twentyNinth: randomDoubleUint16,
          thirtieth: randomDoubleUint16,
        ),
      ),
    );
  }

  void _sendLowVoltageThirtyOneToThirtyThreeCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId:
            const DataSourceParameterId.lowVoltageThirtyOneToThirtyThree()
                .value,
        convertible: BatteryLowVoltageThirtyOneToThirtyThree(
          thirtyFirst: randomDoubleUint16,
          thirtySecond: randomDoubleUint16,
          thirtyThird: randomDoubleUint16,
        ),
      ),
    );
  }

  void _sendBackLightsBlocInfoCallback() {
    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId: 0x00E0,
        convertible: PlainBytesConvertible(
          [
            [
              FunctionId.okIncomingPeriodicValueId,
              FunctionId.warningIncomingPeriodicValueId,
              FunctionId.criticalIncomingPeriodicValueId,
            ][Random().nextInt(3)],
            ...List.generate(7, (index) => randomUint8),
          ],
        ),
      ),
    );
  }

  Future<void> _sendSetBoolUint8ResultCallback(
    DataSourceParameterId parameterId, [
    bool? requiredResult,
  ]) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final _requiredResult = requiredResult ?? randomBool;

    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId: parameterId.value,
        convertible: SuccessEventUint8Body(
          (!generateRandomErrors() || ninetyPercentSuccessBool
                  ? _requiredResult
                  : !_requiredResult)
              .toInt,
        ),
      ),
    );
  }

  Future<void> _sendDoorToggleResultCallback(
    ButtonFunctionId functionId, [
    bool? requiredResult,
  ]) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final rand = randomBool;
    final _requiredResult = requiredResult ?? rand;

    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId: functionId.value,
        convertible: DoorBody(
          isOpen: generateRandomErrors() ? randomBool : _requiredResult,
        ),
      ),
    );
  }

  Future<void> _sendSetUint8ResultCallback(
    DataSourceParameterId parameterId, [
    int? requiredResult,
  ]) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final _requiredResult = requiredResult ?? randomUint8;

    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: 0x95, // 10010101(incoming 0x15)
        parameterId: parameterId.value,
        convertible: SuccessEventUint8Body(
          generateRandomErrors()
              ? randomBool
                  ? randomUint8
                  : _requiredResult
              : _requiredResult,
        ),
      ),
    );
  }

  void _sendPackage(DataSourceIncomingPackage package) {
    if (controller.isClosed) return;
    onNewPackage(
      rawPackage: package.toUint8List,
      onNewPackageCallback: controller.sink.add,
    );
  }

  PeriodicValueStatus get _getRandomStatus {
    return PeriodicValueStatus.values[Random().nextInt(
      PeriodicValueStatus.values.length,
    )];
  }

  int get randomInt8 {
    return Random().nextInt(128).randomSign;
  }

  bool get ninetyPercentSuccessBool => Random().nextDouble() <= .9;

  bool get randomBool => Random().nextBool();

  int get randomUint8 => Random().nextInt(0xFF);
  int get randomUint16 => Random().nextInt(0xFFFF);
  int get randomInt16 => Random().nextInt(0x8000).randomSign;

  double get randomDoubleUint16 => Random().nextDouble() * 0xFFFF;
  double get randomDoubleUint32 => Random().nextDouble() * 0xFFFFFFFF;

  void _updateValueCallback(
    DataSourceParameterId parameterId,
    // int value,
    BytesConvertible convertible,
    DataSourceProtocolVersion version,
  ) {
    final requestType = version.when(
      subscription: () => 0x95, //'10010101'
      periodicRequests: () => 0x81, //'10000001'
    );

    _sendPackage(
      DataSourceIncomingPackage.fromConvertible(
        secondConfigByte: requestType,
        parameterId: parameterId.value,
        convertible: convertible,
      ),
    );
  }
}

extension on DataSourceOutgoingPackage {
  bool get boolData => data[1].toBool;
}

extension NumExtension<T extends num> on T {
  T get randomSign {
    return Random().nextBool() ? this * -1 as T : this;
  }
}

extension on bool {
  int get toInt => this ? 0xFF : 0;
}

extension on int {
  bool get toBool => this == 255;
}
