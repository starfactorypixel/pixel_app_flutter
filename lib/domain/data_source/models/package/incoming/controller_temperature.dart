import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/motor_index_mixin.dart';

class ControllerTemperatureIncomingDataSourcePackage
    extends UInt16WithStatusIncomingDataSourcePackage with MotorIndexMixin {
  ControllerTemperatureIncomingDataSourcePackage(super.source);

  @override
  bool get validParameterId =>
      parameterId.isControllerTemperature1 ||
      parameterId.isControllerTemperature2 ||
      parameterId.isControllerTemperature3 ||
      parameterId.isControllerTemperature4;


  @override
  int? get motorIndexImpl {
    if (parameterId.isControllerTemperature1) return 0;
    if (parameterId.isControllerTemperature2) return 1;
    if (parameterId.isControllerTemperature3) return 2;
    if (parameterId.isControllerTemperature4) return 3;
    return null;
  }
}
