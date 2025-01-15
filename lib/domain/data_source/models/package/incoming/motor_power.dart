import 'package:pixel_app_flutter/domain/data_source/models/package/data_source_incoming_package.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/motor_index_mixin.dart';

class MotorPowerIncomingDataSourcePackage
    extends Int16WithStatusIncomingDataSourcePackage with MotorIndexMixin {
  MotorPowerIncomingDataSourcePackage(super.source);

  @override
  bool get validParameterId =>
      parameterId.isMotorPower1 ||
      parameterId.isMotorPower2 ||
      parameterId.isMotorPower3 ||
      parameterId.isMotorPower4;

  @override
  int? get motorIndexImpl {
    if (parameterId.isMotorPower1) return 0;
    if (parameterId.isMotorPower2) return 1;
    if (parameterId.isMotorPower3) return 2;
    if (parameterId.isMotorPower4) return 3;
    return null;
  }
}
