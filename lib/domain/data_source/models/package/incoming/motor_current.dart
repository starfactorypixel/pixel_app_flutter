import 'package:pixel_app_flutter/domain/data_source/models/package/data_source_incoming_package.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/motor_index_mixin.dart';

class MotorCurrentIncomingDataSourcePackage
    extends UInt16WithStatusIncomingDataSourcePackage with MotorIndexMixin {
  MotorCurrentIncomingDataSourcePackage(super.source);

  @override
  bool get validParameterId =>
      parameterId.isMotorCurrent1 ||
      parameterId.isMotorCurrent2 ||
      parameterId.isMotorCurrent3 ||
      parameterId.isMotorCurrent4;

  @override
  int? get motorIndexImpl {
    if (parameterId.isMotorCurrent1) return 0;
    if (parameterId.isMotorCurrent2) return 1;
    if (parameterId.isMotorCurrent3) return 2;
    if (parameterId.isMotorCurrent4) return 3;
    return null;
  }
}
