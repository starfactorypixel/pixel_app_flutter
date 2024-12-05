import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/battery_index_mixin.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/function_id_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/request_type_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/implementations/battery_percent.dart';

class BatteryPercentIncomingDataSourcePackage
    extends DataSourceIncomingPackage<BatteryPercent>
    with
        BatteryIndexMixin,
        IsEventOrBufferRequestOrSubscriptionAnswerRequestTypeMixin,
        IsPeriodicValueStatusOrSuccessEventFunctionIdMixin {
  BatteryPercentIncomingDataSourcePackage(super.source);

  @override
  BytesConverter<BatteryPercent> get bytesConverter =>
      const BatteryPercentConverter();

  @override
  bool get validParameterId =>
      parameterId.isBatteryPercent1 || parameterId.isBatteryPercent2;

  @override
  int? get batteryIndexImpl {
    if (parameterId.isBatteryPercent1) return 0;
    if (parameterId.isBatteryPercent2) return 1;
    return null;
  }
}
