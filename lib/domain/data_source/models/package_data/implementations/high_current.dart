import 'package:pixel_app_flutter/domain/data_source/extensions/int.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';

class HighCurrent extends BytesConvertible {
  const HighCurrent({
    required this.batt1,
    required this.batt2,
  });

  final int batt1;
  final int batt2;

  const HighCurrent.zero()
      : batt1 = 0,
        batt2 = 0;

  @override
  List<Object?> get props => [batt1, batt2];

  @override
  BytesConverter<HighCurrent> get bytesConverter =>
      const HighCurrentConverter();
}

class HighCurrentConverter extends BytesConverter<HighCurrent> {
  const HighCurrentConverter();

  @override
  HighCurrent fromBytes(List<int> bytes) {
    return HighCurrent(
      batt1: bytes.sublist(0, 2).toIntFromInt16,
      batt2: bytes.sublist(2, 4).toIntFromInt16,
    );
  }

  @override
  List<int> toBytes(HighCurrent model) {
    return [
      ...model.batt1.toBytesInt16,
      ...model.batt2.toBytesInt16,
    ];
  }
}
