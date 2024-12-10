import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/battery_index_mixin.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/function_id_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/request_type_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';

class BatteryLowVoltageIncomingDataSourcePackage
    extends DataSourceIncomingPackage<BatteryLowVoltage>
    with
        BatteryIndexMixin,
        IsEventOrBufferRequestRequestTypeMixin,
        IsSuccessEventFunctionIdMixin {
  BatteryLowVoltageIncomingDataSourcePackage(super.source);

  @override
  BytesConverter<BatteryLowVoltage> get bytesConverter =>
      const BatteryLowVoltageConverter();

  @override
  bool get validParameterId =>
      parameterId.isLowVoltage1 || parameterId.isLowVoltage2;

  @override
  int? get batteryIndexImpl {
    if (parameterId.isLowVoltage1) return 0;
    if (parameterId.isLowVoltage2) return 1;
    return null;
  }
}
