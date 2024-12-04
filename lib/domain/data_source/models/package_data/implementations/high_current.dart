import 'package:pixel_app_flutter/domain/data_source/extensions/int.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/wrappers/bytes_convertible_with_status.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/wrappers/mixins.dart';

class HighCurrent extends IntBytesConvertibleWithStatus {
  const HighCurrent({
    required super.value,
    required super.status,
  });

  const HighCurrent.zero() : super.normal(0);

  HighCurrent.fromFunctionId(int id, {required super.value})
      : super.fromId(id: id);

  @override
  BytesConverter<HighCurrent> get bytesConverter =>
      const HighCurrentConverter();
}

class HighCurrentConverter extends BytesConverter<HighCurrent>
    with PeriodicValueStatusOrOkEventFunctionIdMxixn {
  const HighCurrentConverter();

  @override
  HighCurrent fromBytes(List<int> bytes) {
    return whenFunctionId(
      body: bytes,
      dataParser: (bytes) => bytes.toIntFromInt16,
      status: (data, status) => HighCurrent(status: status, value: data),
      okEvent: (data) {
        return HighCurrent(status: PeriodicValueStatus.normal, value: data);
      },
    );
  }

  @override
  List<int> toBytes(HighCurrent model) {
    return [
      ...model.status.toBytes,
      ...model.value.toBytesInt16,
    ];
  }
}
