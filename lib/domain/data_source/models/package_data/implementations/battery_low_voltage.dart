import 'package:pixel_app_flutter/domain/data_source/extensions/double.dart';
import 'package:pixel_app_flutter/domain/data_source/extensions/int.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';

class BatteryLowVoltage extends BytesConvertible {
  const BatteryLowVoltage({required this.no, required this.value});

  const BatteryLowVoltage.zero({required this.no}) : value = 0;

  final int no;
  final double value;

  @override
  List<Object?> get props => [no, value];

  @override
  BytesConverter<BatteryLowVoltage> get bytesConverter =>
      const BatteryLowVoltageConverter();
}

class BatteryLowVoltageConverter extends BytesConverter<BatteryLowVoltage> {
  const BatteryLowVoltageConverter();

  @override
  BatteryLowVoltage fromBytes(List<int> bytes) {
    return BatteryLowVoltage(
      no: bytes.sublist(1, 3).toIntFromUint16,
      value: bytes.sublist(3, 5).toIntFromUint16.fromMilli,
    );
  }

  @override
  List<int> toBytes(BatteryLowVoltage model) {
    return [
      FunctionId.okEventId,
      ...model.no.toBytesUint16,
      ...model.value.toMilli.toBytesUint16,
    ];
  }
}
