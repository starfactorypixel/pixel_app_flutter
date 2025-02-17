import 'package:pixel_app_flutter/domain/data_source/data_source.dart';

class SteeringRackIncomingDataSourcePackage
    extends SetUint8ResultIncomingDataSourcePackage {
  SteeringRackIncomingDataSourcePackage(super.source);

  @override
  bool get validParameterId => parameterId.isSteeringRack;
}
