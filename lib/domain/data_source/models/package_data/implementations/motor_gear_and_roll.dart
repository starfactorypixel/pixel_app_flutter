import 'package:pixel_app_flutter/domain/data_source/extensions/int.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/wrappers/bytes_convertible_with_status.dart';

enum MotorGear {
  reverse(0x02),
  neutral(0x00),
  drive(0x01),
  low(0x03),
  boost(0x04),
  unknown(0x0F);

  const MotorGear(this.id);
  final int id;

  static MotorGear fromId(int id) {
    return MotorGear.values.firstWhere(
      (element) => element.id == id,
      orElse: () => MotorGear.unknown,
    );
  }

  R when<R>({
    required R Function() reverse,
    required R Function() neutral,
    required R Function() drive,
    required R Function() low,
    required R Function() boost,
    required R Function() unknown,
  }) {
    return switch (this) {
      MotorGear.reverse => reverse(),
      MotorGear.neutral => neutral(),
      MotorGear.drive => drive(),
      MotorGear.low => low(),
      MotorGear.boost => boost(),
      MotorGear.unknown => unknown(),
    };
  }
}

enum MotorRollDirection {
  stop(0x00),
  forward(0x01),
  reverse(0x02),
  unknown(0x0F);

  const MotorRollDirection(this.id);
  final int id;

  static MotorRollDirection fromId(int id) {
    return MotorRollDirection.values.firstWhere(
      (element) => element.id == id,
      orElse: () => MotorRollDirection.unknown,
    );
  }

  R when<R>({
    required R Function() stop,
    required R Function() forward,
    required R Function() reverse,
    required R Function() unknown,
  }) {
    return switch (this) {
      MotorRollDirection.stop => stop(),
      MotorRollDirection.forward => forward(),
      MotorRollDirection.reverse => reverse(),
      MotorRollDirection.unknown => unknown(),
    };
  }
}

class MotorGearAndRoll extends IntBytesConvertibleWithStatus {
  MotorGearAndRoll({
    required this.motorGear,
    required this.motorRollDirection,
    required super.status,
  }) : super(
          value: _toUint16(
            motorGear: motorGear,
            motorRollDirection: motorRollDirection,
          ),
        );

  factory MotorGearAndRoll.unknown() => MotorGearAndRoll(
        motorGear: MotorGear.unknown,
        motorRollDirection: MotorRollDirection.unknown,
        status: PeriodicValueStatus.normal,
      );

  MotorGearAndRoll.fromId({
    required this.motorGear,
    required this.motorRollDirection,
    required super.id,
  }) : super.fromId(
          value: _toUint16(
            motorGear: motorGear,
            motorRollDirection: motorRollDirection,
          ),
        );

  factory MotorGearAndRoll.builder(int functionId, int value) {
    final bytes = value.toBytesUint16;

    return MotorGearAndRoll.fromId(
      id: functionId,
      motorGear: MotorGear.fromId(bytes[0]),
      motorRollDirection: MotorRollDirection.fromId(bytes[1]),
    );
  }

  final MotorGear motorGear;
  final MotorRollDirection motorRollDirection;

  MotorGear get gear => motorGear;

  MotorRollDirection get rollDirection => motorRollDirection;

  static int _toUint16({
    required MotorGear motorGear,
    required MotorRollDirection motorRollDirection,
  }) {
    return [
      motorGear.id,
      motorRollDirection.id,
    ].toIntFromUint16;
  }

  @override
  List<Object?> get props => [
        ...super.props,
        motorGear,
        motorRollDirection,
      ];

  static UInt16WithStatusBytesConverter<MotorGearAndRoll> get converter =>
      const UInt16WithStatusBytesConverter(MotorGearAndRoll.builder);

  @override
  BytesConverter<MotorGearAndRoll> get bytesConverter => converter;
}
