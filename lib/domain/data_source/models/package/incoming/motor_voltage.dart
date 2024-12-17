import 'package:pixel_app_flutter/domain/data_source/models/package/data_source_incoming_package.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/motor_index_mixin.dart';

class MotorVoltageIncomingDataSourcePackage
    extends UInt16WithStatusIncomingDataSourcePackage with MotorIndexMixin {
  MotorVoltageIncomingDataSourcePackage(super.source);

  @override
  bool get validParameterId =>
      parameterId.isMotorVoltage1 ||
      parameterId.isMotorVoltage2 ||
      parameterId.isMotorVoltage3 ||
      parameterId.isMotorVoltage4;

  @override
  int? get motorIndexImpl {
    if (parameterId.isMotorVoltage1) return 0;
    if (parameterId.isMotorVoltage2) return 1;
    if (parameterId.isMotorVoltage3) return 2;
    if (parameterId.isMotorVoltage4) return 3;
    return null;
  }
}
