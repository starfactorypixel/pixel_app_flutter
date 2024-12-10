import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/motor_index_mixin.dart';

class MotorTemperatureIncomingDataSourcePackage
    extends UInt16WithStatusIncomingDataSourcePackage with MotorIndexMixin {
  MotorTemperatureIncomingDataSourcePackage(super.source);

  @override
  bool get validParameterId =>
      parameterId.isMotorTemperature1 ||
      parameterId.isMotorTemperature2 ||
      parameterId.isMotorTemperature3 ||
      parameterId.isMotorTemperature4;

  @override
  int? get motorIndexImpl {
    if (parameterId.isMotorTemperature1) return 0;
    if (parameterId.isMotorTemperature2) return 1;
    if (parameterId.isMotorTemperature3) return 2;
    if (parameterId.isMotorTemperature4) return 3;
    return null;
  }
}
