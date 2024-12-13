import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/bytes_converter.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/wrappers/bytes_convertible_with_status.dart';

@immutable
class Uint16WithStatusBody extends IntBytesConvertibleWithStatus {
  const Uint16WithStatusBody({
    required super.status,
    required super.value,
  });

  Uint16WithStatusBody.fromFunctionId({
    required super.value,
    required super.id,
  }) : super.fromId();

  const Uint16WithStatusBody.normal(
    super.value,
  ) : super.normal();

  const Uint16WithStatusBody.zero() : super.normal(0);

  factory Uint16WithStatusBody.builder(int functionId, int value) {
    return Uint16WithStatusBody.fromFunctionId(
      id: functionId,
      value: value,
    );
  }

  static Uint16WithStatusBytesConverter<Uint16WithStatusBody> get converter =>
      const Uint16WithStatusBytesConverter(Uint16WithStatusBody.builder);

  @override
  BytesConverter<Uint16WithStatusBody> get bytesConverter => converter;
}
