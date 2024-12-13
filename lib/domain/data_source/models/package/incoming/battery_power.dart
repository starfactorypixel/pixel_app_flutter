import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/battery_index_mixin.dart';

class BatteryPowerIncomingDataSourcePackage
    extends Int16WithStatusIncomingDataSourcePackage with BatteryIndexMixin {
  BatteryPowerIncomingDataSourcePackage(super.source);

  @override
  bool get validParameterId =>
      parameterId.isBatteryPower1 || parameterId.isBatteryPower2;

  @override
  int? get batteryIndexImpl {
    if (parameterId.isBatteryPower1) return 0;
    if (parameterId.isBatteryPower2) return 1;
    return null;
  }
}
