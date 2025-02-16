import 'package:pixel_app_flutter/domain/data_source/models/package_data/data_source_package_data_exceptions.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';

abstract class SetValueBody extends BytesConvertible {
  const SetValueBody();

  @override
  SetValueConverter<SetValueBody> get bytesConverter;
}

abstract class SetValueConverter<T extends SetValueBody>
    extends BytesConverter<T> {
  const SetValueConverter();

  @override
  T fromBytes(List<int> bytes) {
    throw const FromBytesShouldNotBeCalledDataSourcePackageDataException(
      'SetValueConverter',
    );
  }

  List<int> getBodyBytes(T model);

  @override
  List<int> toBytes(T model) {
    return [
      FunctionId.setValueWithParam.value,
      ...getBodyBytes(model),
    ];
  }
}

abstract class SetValueResult extends BytesConvertible {
  const SetValueResult({required this.success});

  const SetValueResult.success() : success = true;

  const SetValueResult.error() : success = false;

  final bool success;

  @override
  SetValueResultConverter<SetValueResult> get bytesConverter;

  @override
  List<Object?> get props => [success];
}

abstract class SetValueResultConverter<T extends SetValueResult>
    extends BytesConverter<T> {
  const SetValueResultConverter();

  T fromBytesResult({required bool success, required List<int> body});

  @override
  T fromBytes(List<int> bytes) {
    return fromBytesResult(
      success: bytes[0] == FunctionId.okEventId,
      body: bytes.sublist(1),
    );
  }

  List<int> toBytesBody(T model);

  @override
  List<int> toBytes(T model) {
    return [
      if (model.success) FunctionId.okEventId else FunctionId.errorEventId,
      ...toBytesBody(model),
    ];
  }
}
