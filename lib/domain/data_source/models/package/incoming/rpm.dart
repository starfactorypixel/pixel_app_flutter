import 'package:pixel_app_flutter/domain/data_source/models/package/data_source_incoming_package.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/motor_index_mixin.dart';

class RPMIncomingDataSourcePackage
    extends UInt16WithStatusIncomingDataSourcePackage with MotorIndexMixin {
  RPMIncomingDataSourcePackage(super.source);

  @override
  bool get validParameterId =>
      parameterId.isRPM1 ||
      parameterId.isRPM2 ||
      parameterId.isRPM3 ||
      parameterId.isRPM4;

  @override
  int? get motorIndexImpl {
    if (parameterId.isRPM1) return 0;
    if (parameterId.isRPM2) return 1;
    if (parameterId.isRPM3) return 2;
    if (parameterId.isRPM4) return 3;
    return null;
  }
}
