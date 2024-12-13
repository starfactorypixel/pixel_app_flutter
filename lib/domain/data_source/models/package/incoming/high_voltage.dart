import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/battery_index_mixin.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/function_id_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/request_type_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';

class HighVoltageIncomingDataSourcePackage
    extends DataSourceIncomingPackage<HighVoltage>
    with
        BatteryIndexMixin,
        IsEventOrBufferRequestOrSubscriptionAnswerRequestTypeMixin,
        IsPeriodicValueStatusOrSuccessEventFunctionIdMixin {
  HighVoltageIncomingDataSourcePackage(super.source);

  @override
  BytesConverter<HighVoltage> get bytesConverter =>
      const HighVoltageConverter();

  @override
  bool get validParameterId =>
      parameterId.isHighVoltage1 || parameterId.isHighVoltage2;

  @override
  int? get batteryIndexImpl {
    if (parameterId.isHighVoltage1) return 0;
    if (parameterId.isHighVoltage2) return 1;
    return null;
  }
}
