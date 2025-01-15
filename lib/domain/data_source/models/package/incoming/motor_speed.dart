import 'package:pixel_app_flutter/domain/data_source/models/package/data_source_incoming_package.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/motor_index_mixin.dart';

class MotorSpeedIncomingDataSourcePackage
    extends Uint16WithStatusIncomingDataSourcePackage with MotorIndexMixin {
  MotorSpeedIncomingDataSourcePackage(super.source);

  @override
  bool get validParameterId =>
      parameterId.isMotorSpeed1 ||
      parameterId.isMotorSpeed2 ||
      parameterId.isMotorSpeed3 ||
      parameterId.isMotorSpeed4;

  @override
  int? get motorIndexImpl {
    if (parameterId.isMotorSpeed1) return 0;
    if (parameterId.isMotorSpeed2) return 1;
    if (parameterId.isMotorSpeed3) return 2;
    if (parameterId.isMotorSpeed4) return 3;
    return null;
  }
}
