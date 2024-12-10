import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/bytes_convertible.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/function_id.dart';

class BatteryTemperature extends BytesConvertible {
  const BatteryTemperature({
    required this.no,
    required this.value,
  });

  const BatteryTemperature.zero({required this.no}) : value = 0;

  final int no;
  final int value;

  T whenNo<T>({
    required T Function() mos,
    required T Function() balancer,
    required T Function(int no) temp,
  }) {
    if (no == 1) return mos();
    if (no == 2) return balancer();
    return temp(no - 2);
  }

  @override
  List<Object?> get props => [no, value];

  @override
  BytesConverter<BatteryTemperature> get bytesConverter =>
      BatteryTemperatureConverter();
}

class BatteryTemperatureConverter extends BytesConverter<BatteryTemperature> {
  @override
  BatteryTemperature fromBytes(List<int> bytes) {
    return BatteryTemperature(
      no: bytes[1],
      value: bytes[2],
    );
  }

  @override
  List<int> toBytes(BatteryTemperature model) {
    return [
      FunctionId.okEventId,
      model.no,
      model.value,
    ];
  }
}
