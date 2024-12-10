import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/function_id_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/motor_index_mixin.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/request_type_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';

class MotorGearAndRollIncomingDataSourcePackage
    extends DataSourceIncomingPackage<MotorGearAndRoll>
    with
        IsEventOrBufferRequestOrSubscriptionAnswerRequestTypeMixin,
        IsPeriodicValueStatusFunctionIdMixin,
        MotorIndexMixin {
  MotorGearAndRollIncomingDataSourcePackage(super.source);

  @override
  BytesConverter<MotorGearAndRoll> get bytesConverter =>
      MotorGearAndRoll.converter;

  @override
  bool get validParameterId =>
      parameterId.isGearAndRoll1 ||
      parameterId.isGearAndRoll2 ||
      parameterId.isGearAndRoll3 ||
      parameterId.isGearAndRoll4;


  @override
  int? get motorIndexImpl {
    if (parameterId.isGearAndRoll1) return 0;
    if (parameterId.isGearAndRoll2) return 1;
    if (parameterId.isGearAndRoll3) return 2;
    if (parameterId.isGearAndRoll4) return 3;
    return null;
  }
}
