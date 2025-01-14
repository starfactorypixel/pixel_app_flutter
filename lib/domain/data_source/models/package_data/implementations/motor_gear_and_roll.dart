import 'package:pixel_app_flutter/domain/data_source/extensions/int.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/wrappers/bytes_convertible_with_status.dart';

enum MotorGear {
  reverse(0x02),
  neutral(0x00),
  drive(0x01),
  low(0x04),
  boost(0x08),
  unknown(0xFF);

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
  unknown(0xFF);

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
    required this.gear,
    required this.rollDirection,
    required super.status,
  }) : super(
          value: _toUint16(
            gear: gear,
            rollDirection: rollDirection,
          ),
        );

  factory MotorGearAndRoll.unknown() => MotorGearAndRoll(
        gear: MotorGear.unknown,
        rollDirection: MotorRollDirection.unknown,
        status: PeriodicValueStatus.normal,
      );

  MotorGearAndRoll.fromId({
    required this.gear,
    required this.rollDirection,
    required super.id,
  }) : super.fromId(
          value: _toUint16(
            gear: gear,
            rollDirection: rollDirection,
          ),
        );

  factory MotorGearAndRoll.builder(int functionId, int value) {
    final bytes = value.toBytesUint16;

    return MotorGearAndRoll.fromId(
      id: functionId,
      gear: MotorGear.fromId(bytes[0]),
      rollDirection: MotorRollDirection.fromId(bytes[1]),
    );
  }

  final MotorGear gear;
  final MotorRollDirection rollDirection;

  static int _toUint16({
    required MotorGear gear,
    required MotorRollDirection rollDirection,
  }) {
    return [
      gear.id,
      rollDirection.id,
    ].toIntFromUint16;
  }

  @override
  List<Object?> get props => [
        ...super.props,
        gear,
        rollDirection,
      ];

  static Uint16WithStatusBytesConverter<MotorGearAndRoll> get converter =>
      const Uint16WithStatusBytesConverter(MotorGearAndRoll.builder);

  @override
  BytesConverter<MotorGearAndRoll> get bytesConverter => converter;
}
