import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/wrappers/set_value.dart';

@sealed
@immutable
class SetUint8Body extends SetValueBody {
  const SetUint8Body({required this.value});

  final int value;

  @override
  SetValueConverter<SetUint8Body> get bytesConverter =>
      const SetUint8BodyConverter();

  @override
  List<Object?> get props => [value];
}

@immutable
class SetUint8BodyConverter extends SetValueConverter<SetUint8Body> {
  const SetUint8BodyConverter();

  @override
  List<int> getBodyBytes(SetUint8Body model) => [model.value];
}

class SetUint8ResultBody extends SetValueResult {
  const SetUint8ResultBody({
    required super.success,
    required this.value,
  });

  const SetUint8ResultBody.success({
    required this.value,
  }) : super.success();

  const SetUint8ResultBody.error({
    required this.value,
  }) : super.error();

  factory SetUint8ResultBody.builder({
    required bool success,
    required int value,
  }) {
    return SetUint8ResultBody(
      success: success,
      value: value,
    );
  }

  final int value;

  T when<T>({
    required T Function(int value) success,
    required T Function() error,
  }) {
    if (this.success) return success(value);
    return error();
  }

  static SetValueResultConverter<SetUint8ResultBody> get converter =>
      const SetUint8ResultBodyConverter();

  @override
  SetValueResultConverter<SetUint8ResultBody> get bytesConverter => converter;

  @override
  List<Object?> get props => [...super.props, value];
}

class SetUint8ResultBodyConverter
    extends SetValueResultConverter<SetUint8ResultBody> {
  const SetUint8ResultBodyConverter();

  @override
  List<int> toBytesBody(SetUint8ResultBody model) {
    return [model.value];
  }

  @override
  SetUint8ResultBody fromBytesResult({
    required bool success,
    required List<int> body,
  }) {
    return SetUint8ResultBody(success: success, value: body.first);
  }
}
