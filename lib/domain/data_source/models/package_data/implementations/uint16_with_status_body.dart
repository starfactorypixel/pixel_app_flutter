import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/bytes_converter.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/wrappers/bytes_convertible_with_status.dart';

@immutable
class UInt16WithStatusBody extends IntBytesConvertibleWithStatus {
  const UInt16WithStatusBody({
    required super.status,
    required super.value,
  });

  UInt16WithStatusBody.fromFunctionId({
    required super.value,
    required super.id,
  }) : super.fromId();

  const UInt16WithStatusBody.normal(
    super.value,
  ) : super.normal();

  const UInt16WithStatusBody.zero() : super.normal(0);

  factory UInt16WithStatusBody.builder(int functionId, int value) {
    return UInt16WithStatusBody.fromFunctionId(
      id: functionId,
      value: value,
    );
  }

  static UInt16WithStatusBytesConverter<UInt16WithStatusBody> get converter =>
      const UInt16WithStatusBytesConverter(UInt16WithStatusBody.builder);

  @override
  BytesConverter<UInt16WithStatusBody> get bytesConverter => converter;
}
