import 'package:pixel_app_flutter/domain/data_source/data_source.dart';

class SuspensionModeIncomingDataSourcePackage
    extends SetUint8ResultIncomingDataSourcePackage {
  SuspensionModeIncomingDataSourcePackage(super.source);

  @override
  bool get validParameterId => parameterId.isSuspensionMode;
}
