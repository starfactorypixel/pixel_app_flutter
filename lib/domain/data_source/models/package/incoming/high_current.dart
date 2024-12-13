import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/battery_index_mixin.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/function_id_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/request_type_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';

class HighCurrentIncomingDataSourcePackage
    extends DataSourceIncomingPackage<HighCurrent>
    with
        BatteryIndexMixin,
        IsEventOrBufferRequestOrSubscriptionAnswerRequestTypeMixin,
        IsPeriodicValueStatusOrSuccessEventFunctionIdMixin {
  HighCurrentIncomingDataSourcePackage(super.source);

  @override
  BytesConverter<HighCurrent> get bytesConverter =>
      const HighCurrentConverter();

  @override
  bool get validParameterId =>
      parameterId.isHighCurrent1 || parameterId.isHighCurrent2;

  @override
  int? get batteryIndexImpl {
    if (parameterId.isHighCurrent1) return 0;
    if (parameterId.isHighCurrent2) return 1;
    return null;
  }
}
