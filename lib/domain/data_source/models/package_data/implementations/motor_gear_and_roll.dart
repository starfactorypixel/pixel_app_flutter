import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/extensions/int.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/wrappers/bytes_convertible_with_status.dart';

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
