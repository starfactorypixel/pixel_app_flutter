import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/battery_index_mixin.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/function_id_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/request_type_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';

class MaxTemperatureIncomingDataSourcePackage
    extends DataSourceIncomingPackage<MaxTemperature>
    with
        BatteryIndexMixin,
        IsEventOrBufferRequestOrSubscriptionAnswerRequestTypeMixin,
        IsPeriodicValueStatusOrSuccessEventFunctionIdMixin {
  MaxTemperatureIncomingDataSourcePackage(super.source);

  @override
  BytesConverter<MaxTemperature> get bytesConverter =>
      const MaxTemperatureConverter();

  @override
  bool get validParameterId =>
      parameterId.isMaxTemperature1 || parameterId.isMaxTemperature2;

  @override
  int? get batteryIndexImpl {
    if (parameterId.isMaxTemperature1) return 0;
    if (parameterId.isMaxTemperature2) return 1;
    return null;
  }
}
