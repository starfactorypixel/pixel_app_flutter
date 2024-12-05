import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/battery_index_mixin.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/function_id_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/request_type_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';

class BatteryTemperatureIncomingDataSourcePackage
    extends DataSourceIncomingPackage<BatteryTemperature>
    with
        BatteryIndexMixin,
        IsEventOrBufferRequestRequestTypeMixin,
        IsSuccessEventFunctionIdMixin {
  BatteryTemperatureIncomingDataSourcePackage(super.source);

  @override
  BytesConverter<BatteryTemperature> get bytesConverter =>
      BatteryTemperatureConverter();

  @override
  bool get validParameterId =>
      parameterId.isTemperature1 || parameterId.isTemperature2;

  @override
  int? get batteryIndexImpl {
    if (parameterId.isTemperature1) return 0;
    if (parameterId.isTemperature2) return 1;
    return null;
  }
}
