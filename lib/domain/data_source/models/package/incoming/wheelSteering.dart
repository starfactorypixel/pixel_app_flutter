import 'package:pixel_app_flutter/domain/data_source/models/package/data_source_incoming_package.dart';

class WheelSteeringIncomingDataSourcePackage
    extends Uint8WithStatusIncomingDataSourcePackage {
  WheelSteeringIncomingDataSourcePackage(super.source);

  @override
  bool get validParameterId => parameterId.isWheelSteering;
}
