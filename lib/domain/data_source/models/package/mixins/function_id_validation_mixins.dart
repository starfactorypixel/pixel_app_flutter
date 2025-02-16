import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';

mixin IsPeriodicValueStatusFunctionIdMixin<T extends BytesConvertible>
    on DataSourceIncomingPackage<T> {
  @override
  bool get validFunctionId =>
      data.isNotEmpty && PeriodicValueStatus.isValid(data[0]);
}

mixin IsSuccessEventFunctionIdMixin<T extends BytesConvertible>
    on DataSourceIncomingPackage<T> {
  @override
  bool get validFunctionId =>
      data.isNotEmpty && data[0] == FunctionId.okEventId;
}

mixin IsSuccessEventOrErrorEventFunctionIdMixin<T extends BytesConvertible>
    on DataSourceIncomingPackage<T> {
  @override
  bool get validFunctionId =>
      data.isNotEmpty &&
      (data[0] == FunctionId.okEventId || data[0] == FunctionId.errorEventId);
}

mixin IsPeriodicValueStatusOrSuccessEventFunctionIdMixin<
    T extends BytesConvertible> on DataSourceIncomingPackage<T> {
  @override
  bool get validFunctionId =>
      data.isNotEmpty &&
      (data[0] == FunctionId.okEventId || PeriodicValueStatus.isValid(data[0]));
}
