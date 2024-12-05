import 'package:pixel_app_flutter/domain/data_source/extensions/int.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/wrappers/bytes_convertible_with_status.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/wrappers/mixins.dart';

class BatteryPercent extends IntBytesConvertibleWithStatus {
  const BatteryPercent({
    required super.value,
    required super.status,
  });

  const BatteryPercent.zero() : super.normal(0);

  BatteryPercent.fromFunctionId(int id, {required super.value})
      : super.fromId(id: id);

  @override
  BytesConverter<BatteryPercent> get bytesConverter =>
      const BatteryPercentConverter();
}

class BatteryPercentConverter extends BytesConverter<BatteryPercent>
    with PeriodicValueStatusOrOkEventFunctionIdMxixn {
  const BatteryPercentConverter();

  @override
  BatteryPercent fromBytes(List<int> bytes) {
    return whenFunctionId(
      body: bytes,
      dataParser: (bytes) => bytes.toIntFromUint8,
      status: (data, status) => BatteryPercent(status: status, value: data),
      okEvent: (data) {
        return BatteryPercent(status: PeriodicValueStatus.normal, value: data);
      },
    );
  }

  @override
  List<int> toBytes(BatteryPercent model) {
    return [
      ...model.status.toBytes,
      ...model.value.toBytesUint8,
    ];
  }
}
