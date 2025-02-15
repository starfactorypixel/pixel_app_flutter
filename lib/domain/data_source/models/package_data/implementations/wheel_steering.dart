import 'dart:math';

import 'package:pixel_app_flutter/domain/data_source/extensions/int.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/wrappers/bytes_convertible_with_status.dart';

enum WheelSteering {
  free(0x00),
  align(0x01),
  fastTurn(0x02),
  diagonal(0x03),
  blocked(0x04);

  const WheelSteering(this.id);
  final int id;

  static WheelSteering fromId(int id) {
    return WheelSteering.values.firstWhere(
      (element) => element.id == id,
      orElse: () => WheelSteering.free,
    );
  }

  R when<R>({
    required R Function() free,
    required R Function() align,
    required R Function() fastTurn,
    required R Function() diagonal,
    required R Function() blocked,
  }) {
    return switch (this) {
      WheelSteering.free => free(),
      WheelSteering.align => align(),
      WheelSteering.fastTurn => fastTurn(),
      WheelSteering.diagonal => diagonal(),
      WheelSteering.blocked => blocked(),
    };
  }

  static WheelSteering get random => values[Random().nextInt(values.length)];
}

class WheelSteeringPacket extends IntBytesConvertibleWithStatus {
  WheelSteeringPacket({
    required this.wheelSteering,
    required super.status,
  }) : super(
          value: _toUint8(
            wheelSteering: wheelSteering,
          ),
        );

  factory WheelSteeringPacket.unknown() => WheelSteeringPacket(
        wheelSteering: WheelSteering.free,
        status: PeriodicValueStatus.normal,
      );

  WheelSteeringPacket.fromId({
    required this.wheelSteering,
    required super.id,
  }) : super.fromId(
          value: _toUint8(
            wheelSteering: wheelSteering,
          ),
        );

  factory WheelSteeringPacket.builder(int functionId, int value) {
    final bytes = value.toBytesUint8;

    return WheelSteeringPacket.fromId(
      id: functionId,
      wheelSteering: WheelSteering.fromId(bytes[0]),
    );
  }

  final WheelSteering wheelSteering;

  static int _toUint8({
    required WheelSteering wheelSteering,
  }) {
    return [
      wheelSteering.id,
    ].toIntFromUint8;
  }

  @override
  List<Object?> get props => [
        ...super.props,
        wheelSteering,
      ];

  static Uint8WithStatusBytesConverter<WheelSteeringPacket> get converter =>
      const Uint8WithStatusBytesConverter(WheelSteeringPacket.builder);

  @override
  BytesConverter<WheelSteeringPacket> get bytesConverter => converter;
}
