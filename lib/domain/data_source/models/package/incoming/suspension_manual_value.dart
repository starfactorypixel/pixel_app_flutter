import 'package:pixel_app_flutter/domain/data_source/data_source.dart';

class SuspensionManualValueIncomingDataSourcePackage
    extends SetUint8ResultIncomingDataSourcePackage {
  SuspensionManualValueIncomingDataSourcePackage(super.source);

  @override
  bool get validParameterId => parameterId.isSuspensionValue;
}
