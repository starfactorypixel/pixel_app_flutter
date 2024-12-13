import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/data/services/data_source/mixins/default_data_source_observer_mixin.dart';
import 'package:pixel_app_flutter/data/services/data_source/mixins/package_stream_controller_mixin.dart';
import 'package:pixel_app_flutter/data/services/data_source/mixins/parse_bytes_package_mixin.dart';
import 'package:pixel_app_flutter/data/services/data_source/mixins/send_packages_mixin.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
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
    required this.hardwareCount,
  })  : subscriptionParameters = {},
        isInitialHandshake = true,
        super(key: kKey);

  @protected
  final int Function() updatePeriodMillis;

  @protected
  final bool Function() generateRandomErrors;

  @protected
  final HardwareCount Function() hardwareCount;

  MainEcuMockManager? _mockManager;

  @visibleForTesting
  MainEcuMockManager get mockManager {
    return _mockManager ??
        MainEcuMockManager(
          mockedResponses: mockedResponses,
          hardwareCount: hardwareCount(),
          sendPackage: _sendPackage,
          updateCallback: _updateValueCallback,
        );
  }

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
  final Set<DataSourceParameterId> subscriptionParameters;

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

    return package.requestType.maybeWhen(
      bufferRequest: () => mockManager.handlePeriodicPackage(package),
      event: () => mockManager.handlePeriodicPackage(package),
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
                Future<void>.delayed(const Duration(milliseconds: 300)).then(
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
        final parameterId = package.parameterId;
        if (parameterId.value > OutgoingUnsubscribePackage.kOperand) {
          // Unsubscribe package
          subscriptionParameters.remove(
            DataSourceParameterId.fromInt(
              parameterId.value - OutgoingUnsubscribePackage.kOperand,
            ),
          );

          return const Result.value(null);
        }

        if (mockManager.checkAvailableForSubscription(parameterId)) {
          subscriptionParameters.add(parameterId);
        } else {
          mockManager.handlePeriodicPackage(package);
        }

        timer ??= Timer.periodic(
          Duration(milliseconds: updatePeriodMillis()),
          (timer) {
            for (final element in subscriptionParameters) {
              try {
                mockManager.handleSubscriptionParameterId(element);
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

  @override
  Future<Result<DisconnectError, void>> disconnect() async {
    return const Result.value(null);
  }

  @visibleForTesting
  List<MainEcuMockResponse> get mockedResponses => [
        MainEcuMockResponseUpdateCallbackWrapper(
          ids: {
            const DataSourceParameterId.motorSpeed1(),
            const DataSourceParameterId.motorSpeed2(),
            const DataSourceParameterId.motorSpeed3(),
            const DataSourceParameterId.motorSpeed4(),
          },
          convertible: TwoUint16WithStatusBody(
            status: _getRandomStatus,
            first: Random().nextInt(1001),
            second: Random().nextInt(1001),
          ),
        ),
        MainEcuMockResponseWrapper(
          ids: {
            const DataSourceParameterId.motorVoltage1(),
            const DataSourceParameterId.motorVoltage2(),
            const DataSourceParameterId.motorVoltage3(),
            const DataSourceParameterId.motorVoltage4(),
            const DataSourceParameterId.rpm1(),
            const DataSourceParameterId.rpm2(),
            const DataSourceParameterId.rpm3(),
            const DataSourceParameterId.rpm4(),
          },
          respondCallback: (id, version, _, [__]) => _sendTwoUint16Callback(
            id,
            version,
          ),
        ),
        MainEcuMockResponseWrapper(
          ids: {
            const DataSourceParameterId.motorCurrent1(),
            const DataSourceParameterId.motorCurrent2(),
            const DataSourceParameterId.motorCurrent3(),
            const DataSourceParameterId.motorCurrent4(),
            const DataSourceParameterId.motorPower1(),
            const DataSourceParameterId.motorPower2(),
            const DataSourceParameterId.motorPower3(),
            const DataSourceParameterId.motorPower4(),
            const DataSourceParameterId.motorTemperature1(),
            const DataSourceParameterId.motorTemperature2(),
            const DataSourceParameterId.motorTemperature3(),
            const DataSourceParameterId.motorTemperature4(),
            const DataSourceParameterId.controllerTemperature1(),
            const DataSourceParameterId.controllerTemperature2(),
            const DataSourceParameterId.controllerTemperature3(),
            const DataSourceParameterId.controllerTemperature4(),
          },
          respondCallback: (id, version, _, [__]) => _sendTwoInt16Callback(
            id,
            version,
          ),
        ),
        MainEcuMockResponseWrapper(
          ids: {
            const DataSourceParameterId.gearAndRoll1(),
            const DataSourceParameterId.gearAndRoll2(),
            const DataSourceParameterId.gearAndRoll3(),
            const DataSourceParameterId.gearAndRoll4(),
          },
          respondCallback: (id, version, manager, [package]) {
            final randomGear =
                MotorGear.values[Random().nextInt(MotorGear.values.length)];
            final randomRoll = MotorRollDirection
                .values[Random().nextInt(MotorRollDirection.values.length)];
            return manager.updateCallback(
              id,
              MotorGearAndRoll(
                gear: randomGear,
                rollDirection: randomRoll,
                status: _getRandomStatus,
              ),
              version,
            );
          },
        ),
        MainEcuMockResponseWrapper(
          ids: {
            const DataSourceParameterId.temperature1(),
            const DataSourceParameterId.temperature2(),
          },
          respondCallback: (id, version, manager, [_]) {
            for (var i = 1;
                i <= manager.hardwareCount.temperatureSensors;
                i++) {
              manager.updateCallback(
                id,
                BatteryTemperature(
                  no: i,
                  value: randomInt8,
                ),
                version,
              );
            }

            return const Result.value(null);
          },
        ),
        MainEcuMockResponseWrapper(
          ids: {
            const DataSourceParameterId.lowVoltage1(),
            const DataSourceParameterId.lowVoltage2(),
          },
          respondCallback: (id, version, manager, [_]) {
            for (var i = 1; i <= manager.hardwareCount.batteryCells; i++) {
              manager.updateCallback(
                id,
                BatteryLowVoltage(
                  no: i,
                  value: randomDoubleUint16,
                ),
                version,
              );
            }

            return const Result.value(null);
          },
        ),
        MainEcuMockResponseUpdateCallbackWrapper(
          ids: {
            const DataSourceParameterId.lowVoltageMinMaxDelta1(),
            const DataSourceParameterId.lowVoltageMinMaxDelta2(),
          },
          convertible: LowVoltageMinMaxDelta(
            min: Random().nextDouble() * 65535,
            max: Random().nextDouble() * 65535,
            delta: Random().nextDouble() * 65535,
            status: _getRandomStatus,
          ),
        ),
        MainEcuMockResponseUpdateCallbackWrapper(
          ids: {
            const DataSourceParameterId.highVoltage1(),
            const DataSourceParameterId.highVoltage2(),
          },
          convertible: HighVoltage(
            value: randomUint16,
            status: _getRandomStatus,
          ),
        ),
        MainEcuMockResponseUpdateCallbackWrapper(
          ids: {
            const DataSourceParameterId.highCurrent1(),
            const DataSourceParameterId.highCurrent2(),
          },
          convertible: HighCurrent(
            value: randomInt16,
            status: _getRandomStatus,
          ),
        ),
        MainEcuMockResponseUpdateCallbackWrapper(
          ids: {
            const DataSourceParameterId.batteryPercent1(),
            const DataSourceParameterId.batteryPercent2(),
          },
          convertible: BatteryPercent(
            value: Random().nextInt(101),
            status: _getRandomStatus,
          ),
        ),
        MainEcuMockResponseWrapper(
          ids: {
            const DataSourceParameterId.batteryPower1(),
            const DataSourceParameterId.batteryPower2(),
          },
          respondCallback: (id, version, manager, [_]) => _sendInt16Callback(
            id,
            version,
          ),
        ),
        MainEcuMockResponseUpdateCallbackWrapper(
          ids: {
            const DataSourceParameterId.maxTemperature1(),
            const DataSourceParameterId.maxTemperature2(),
          },
          convertible: MaxTemperature(
            value: randomInt8,
            status: _getRandomStatus,
          ),
        ),
        // Lights
        MainEcuMockResponseWrapper(
          ids: {
            const FrontSideBeamParameterId(),
            const TailSideBeamParameterId(),
            const LowBeamParameterId(),
            const ReverseLightParameterId(),
            const BrakeLightParameterId(),
            const CabinLightParameterId(),
            const HighBeamParameterId(),
            const FrontHazardBeamParameterId(),
            const TailHazardBeamParameterId(),
            const FrontLeftTurnSignalParameterId(),
            const FrontRightTurnSignalParameterId(),
            const TailLeftTurnSignalParameterId(),
            const TailRightTurnSignalParameterId(),
            const WindscreenWipersParameterId(),
          },
          // All of the ids above are unavailable for subscription
          unavailableForSubscriptionIds: {},
          respondCallback: (id, version, manager, [package]) {
            _sendSetBoolUint8ResultCallback(
              id,
              DataSourceProtocolVersion.subscription,
              package?.requestType.maybeWhen(
                orElse: () => null,
                bufferRequest: () => package.boolData,
                event: () => package.boolData,
              ),
            );

            return const Result.value(null);
          },
        ),
        MainEcuMockResponseWrapper(
          ids: {const CustomImageParameterId()},
          respondCallback: (id, version, manager, [package]) {
            _sendSetUint8ResultCallback(id, version, package?.data[1]);

            return const Result.value(null);
          },
        ),
        MainEcuMockResponseUpdateCallbackWrapper(
          ids: {const CustomParameterId(0x00E0)},
          convertible: PlainBytesConvertible(
            [
              _getRandomStatus.id,
              ...List.generate(7, (index) => randomUint8),
            ],
          ),
        ),
        // Doors
        MainEcuMockResponseWrapper(
          ids: {
            const LeftDoorParameterId(),
            const RightDoorParameterId(),
            const CustomParameterId(ButtonFunctionId.leftDoorId),
            const CustomParameterId(ButtonFunctionId.rightDoorId),
          },
          unavailableForSubscriptionIds: {},
          respondCallback: (id, version, manager, [_]) {
            final functionId = switch (id) {
              const LeftDoorParameterId() => ButtonFunctionId.leftDoor,
              const RightDoorParameterId() => ButtonFunctionId.rightDoor,
              _ => ButtonFunctionId.fromValue(id.value),
            };
            _sendDoorToggleResultCallback(functionId);

            return const Result.value(null);
          },
        ),
      ];

  Result<SendPackageError, void> _sendInt16Callback(
    DataSourceParameterId id,
    DataSourceProtocolVersion version,
  ) {
    return _updateValueCallback(
      id,
      Int16WithStatusBody(
        status: _getRandomStatus,
        value: randomInt16,
      ),
      version,
    );
  }

  Result<SendPackageError, void> _sendTwoInt16Callback(
    DataSourceParameterId id,
    DataSourceProtocolVersion version,
  ) {
    return _updateValueCallback(
      id,
      TwoInt16WithStatusBody(
        status: _getRandomStatus,
        first: randomInt16,
        second: randomInt16,
      ),
      version,
    );
  }

  Result<SendPackageError, void> _sendTwoUint16Callback(
    DataSourceParameterId id,
    DataSourceProtocolVersion version,
  ) {
    return _updateValueCallback(
      id,
      TwoUint16WithStatusBody(
        status: _getRandomStatus,
        first: randomUint16,
        second: randomUint16,
      ),
      version,
    );
  }

  Future<void> _sendSetBoolUint8ResultCallback(
    DataSourceParameterId parameterId,
    DataSourceProtocolVersion version, [
    bool? requiredResult,
  ]) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final _requiredResult = requiredResult ?? randomBool;

    _updateValueCallback(
      parameterId,
      SuccessEventUint8Body(
        (!generateRandomErrors() || ninetyPercentSuccessBool
                ? _requiredResult
                : !_requiredResult)
            .toInt,
      ),
      version,
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
    DataSourceParameterId parameterId,
    DataSourceProtocolVersion version, [
    int? requiredResult,
  ]) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final _requiredResult = requiredResult ?? randomUint8;

    _updateValueCallback(
      parameterId,
      SuccessEventUint8Body(
        generateRandomErrors()
            ? randomBool
                ? randomUint8
                : _requiredResult
            : _requiredResult,
      ),
      version,
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

  Result<SendPackageError, void> _updateValueCallback(
    DataSourceParameterId parameterId,
    BytesConvertible convertible,
    DataSourceProtocolVersion version, [
    DataSourceOutgoingPackage? package,
  ]) {
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

    return const Result.value(null);
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

@visibleForTesting
final class MainEcuMockManager {
  const MainEcuMockManager({
    required this.mockedResponses,
    required this.hardwareCount,
    required this.sendPackage,
    required this.updateCallback,
  });

  final List<MainEcuMockResponse> mockedResponses;
  final HardwareCount hardwareCount;
  final void Function(DataSourceIncomingPackage package) sendPackage;
  final Result<SendPackageError, void> Function(
    DataSourceParameterId parameterId,
    BytesConvertible convertible,
    DataSourceProtocolVersion version, [
    DataSourceOutgoingPackage? package,
  ]) updateCallback;

  bool checkAvailableForSubscription(DataSourceParameterId id) {
    return mockedResponses.any(
      (element) => element.checkAvailableForSubscription(id),
    );
  }

  Result<SendPackageError, void> handle(
    DataSourceParameterId id,
    DataSourceProtocolVersion version, [
    DataSourceOutgoingPackage? package,
  ]) {
    for (final response in mockedResponses) {
      if (response.ids.contains(id)) {
        return response.respond(
          id,
          version,
          this,
          package,
        );
      }
    }

    return const Result.error(SendPackageError.unknown);
  }

  Result<SendPackageError, void> handlePeriodicPackage(
    DataSourceOutgoingPackage package,
  ) {
    return handle(
      package.parameterId,
      DataSourceProtocolVersion.periodicRequests,
      package,
    );
  }

  Result<SendPackageError, void> handleSubscriptionParameterId(
    DataSourceParameterId id,
  ) {
    return handle(
      id,
      DataSourceProtocolVersion.subscription,
    );
  }
}

abstract class MainEcuMockResponse {
  const MainEcuMockResponse({
    required this.ids,
    this.unavailableForSubscriptionIds,
  });

  final Set<DataSourceParameterId> ids;

  /// Null - if all [ids] are available for subscription
  /// Empty - if all [ids] are unavailable for subscription
  /// Otherwise - list of unavailable ids
  ///
  /// By default all [ids] are available for subscription
  final Set<DataSourceParameterId>? unavailableForSubscriptionIds;

  bool checkAvailableForSubscription(DataSourceParameterId id) {
    if (!ids.contains(id)) return false;
    final unavailableIds = unavailableForSubscriptionIds;
    if (unavailableIds == null) return true;
    if (unavailableIds.isEmpty) return false;
    return !unavailableIds.contains(id);
  }

  Result<SendPackageError, void> respond(
    DataSourceParameterId id,
    DataSourceProtocolVersion version,
    MainEcuMockManager manager, [
    DataSourceOutgoingPackage? package,
  ]);
}

final class MainEcuMockResponseWrapper extends MainEcuMockResponse {
  const MainEcuMockResponseWrapper({
    required super.ids,
    required this.respondCallback,
    super.unavailableForSubscriptionIds,
  });

  final Result<SendPackageError, void> Function(
    DataSourceParameterId id,
    DataSourceProtocolVersion version,
    MainEcuMockManager manager, [
    DataSourceOutgoingPackage? package,
  ]) respondCallback;

  @override
  Result<SendPackageError, void> respond(
    DataSourceParameterId id,
    DataSourceProtocolVersion version,
    MainEcuMockManager manager, [
    DataSourceOutgoingPackage? package,
  ]) =>
      respondCallback(id, version, manager, package);
}

final class MainEcuMockResponseUpdateCallbackWrapper
    extends MainEcuMockResponse {
  const MainEcuMockResponseUpdateCallbackWrapper({
    required super.ids,
    required this.convertible,
    super.unavailableForSubscriptionIds,
  });

  final BytesConvertible convertible;

  @override
  Result<SendPackageError, void> respond(
    DataSourceParameterId id,
    DataSourceProtocolVersion version,
    MainEcuMockManager manager, [
    DataSourceOutgoingPackage? package,
  ]) {
    return manager.updateCallback(id, convertible, version, package);
  }
}
