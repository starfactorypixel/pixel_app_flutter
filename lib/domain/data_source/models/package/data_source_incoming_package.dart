import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/data_source_package_exceptions.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/battery_percent.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/incoming_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/converter_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/function_id_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/mixins/request_type_validation_mixins.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';

abstract class DataSourceIncomingPackage<T extends BytesConvertible>
    extends DataSourcePackage {
  DataSourceIncomingPackage(super.source);

  static DataSourceIncomingPackage parse(List<int> source) {
    final builders = DataSourceIncomingPackage.getBuilders();

    for (final builder in builders) {
      final package = builder(source);
      if (package.isValid()) return package;
    }

    throw ParserNotFoundDataSourceIncomingPackageException(source);
  }

  static DataSourceIncomingPackage fromConvertible({
    int firstConfigByte = 0x00,
    required int secondConfigByte,
    required int parameterId,
    required BytesConvertible convertible,
  }) {
    return parse(
      [
        DataSourcePackage.startingByte,
        ...DataSourcePackage.getBodyAndCheckSum(
          secondConfigByte: secondConfigByte,
          parameterId: parameterId,
          convertible: convertible,
          firstConfigByte: firstConfigByte,
        ),
        DataSourcePackage.endingByte,
      ],
    );
  }

  static DataSourceIncomingPackage? instanceOrNUll(List<int> package) {
    try {
      return DataSourceIncomingPackage.parse(package);
    } on Exception catch (_) {
      return null;
    }
  }

  bool isValid() {
    return directionFlag == DataSourceRequestDirection.incoming &&
        validRequestType &&
        validParameterId &&
        validFunctionId;
  }

  bool get validRequestType;

  bool get validParameterId;

  bool get validFunctionId;

  BytesConverter<T> get bytesConverter;

  static List<DataSourceIncomingPackage Function(List<int> source)>
      getBuilders<T extends BytesConvertible>() {
    return [
      AuthorizationResponseIncomingDataSourcePackage.new,
      AuthorizationInitializationResponseIncomingDataSourcePackage.new,
      //
      SpeedIncomingDataSourcePackage.new,
      VoltageIncomingDataSourcePackage.new,
      CurrentIncomingDataSourcePackage.new,
      //
      HandshakeInitialIncomingDataSourcePackage.new,
      HandshakePingIncomingDataSourcePackage.new,
      LowVoltageMinMaxDeltaIncomingDataSourcePackage.new,
      HighCurrentIncomingDataSourcePackage.new,
      BatteryPercentIncomingDataSourcePackage.new,
      HighVoltageIncomingDataSourcePackage.new,
      MaxTemperatureIncomingDataSourcePackage.new,
      BatteryTemperatureIncomingDataSourcePackage.new,
      BatteryLowVoltageIncomingDataSourcePackage.new,

      BatteryPowerIncomingDataSourcePackage.new,
      //
      TailSideBeamSetIncomingDataSourcePackage.new,
      FrontSideBeamSetIncomingDataSourcePackage.new,
      //
      LowBeamSetIncomingDataSourcePackage.new,
      HighBeamSetIncomingDataSourcePackage.new,
      //
      FrontHazardBeamSetIncomingDataSourcePackage.new,
      TailHazardBeamSetIncomingDataSourcePackage.new,
      //
      FrontLeftTurnSignalIncomingDataSourcePackage.new,
      FrontRightTurnSignalIncomingDataSourcePackage.new,
      TailLeftTurnSignalIncomingDataSourcePackage.new,
      TailRightTurnSignalIncomingDataSourcePackage.new,
      //
      ReverseLightIncomingDataSourcePackage.new,
      BrakeLightIncomingDataSourcePackage.new,
      //
      CustomImageIncomingDataSourcePackage.new,
      //
      MotorSpeedIncomingDataSourcePackage.new,
      MotorCurrentIncomingDataSourcePackage.new,
      MotorTemperatureIncomingDataSourcePackage.new,
      ControllerTemperatureIncomingDataSourcePackage.new,
      MotorVoltageIncomingDataSourcePackage.new,
      OdometerIncomingDataSourcePackage.new,
      RPMIncomingDataSourcePackage.new,
      MotorGearAndRollIncomingDataSourcePackage.new,
      MotorPowerIncomingDataSourcePackage.new,
      //
      LeftDoorIncomingDataSourcePackage.new,
      RightDoorIncomingDataSourcePackage.new,
      CabinLightIncomingDataSourcePackage.new,
      //
      WindscreenWipersIncomingDataSourcePackage.new,
      //
      SuspensionModeIncomingDataSourcePackage.new,
      SuspensionManualValueIncomingDataSourcePackage.new,
      //
      ErrorWithCodeAndSectionIncomingDataSourcePackage.new,
      //
      CustomIncomingDataSourcePackage.new,
    ];
  }

  T get dataModel => bytesConverter.fromBytes(data);
}

extension VoidOnModelExtension on DataSourceIncomingPackage {
  void voidOnModel<Y extends BytesConvertible,
      T extends DataSourceIncomingPackage<Y>>(
    void Function(Y model) fn,
  ) {
    if (this is T) fn((this as T).dataModel);
  }

  void voidOnPackage<Y extends BytesConvertible,
      T extends DataSourceIncomingPackage<Y>>(
    void Function(T package) fn,
  ) {
    if (this is T) fn(this as T);
  }
}

abstract class SetUint8ResultIncomingDataSourcePackage
    extends DataSourceIncomingPackage<SetUint8ResultBody>
    with
        IsEventOrBufferRequestOrSubscriptionAnswerRequestTypeMixin,
        IsSuccessEventOrErrorEventFunctionIdMixin,
        SetUint8ResultBodyBytesConverterMixin {
  SetUint8ResultIncomingDataSourcePackage(super.source);
}

abstract class SuccessEventUint8IncomingDataSourcePackage
    extends DataSourceIncomingPackage<SuccessEventUint8Body>
    with
        IsEventOrSubscriptionAnswerRequestTypeMixin,
        IsSuccessEventFunctionIdMixin,
        SuccessEventUint8BodyBytesConverterMixin {
  SuccessEventUint8IncomingDataSourcePackage(super.source);
}

abstract class Uint8WithStatusIncomingDataSourcePackage
    extends DataSourceIncomingPackage<Uint8WithStatusBody>
    with
        IsEventOrBufferRequestOrSubscriptionAnswerRequestTypeMixin,
        IsPeriodicValueStatusFunctionIdMixin,
        Uint8WithStatusBodyBytesConverterMixin {
  Uint8WithStatusIncomingDataSourcePackage(super.source);
}

abstract class Uint32WithStatusIncomingDataSourcePackage
    extends DataSourceIncomingPackage<Uint32WithStatusBody>
    with
        IsEventOrBufferRequestOrSubscriptionAnswerRequestTypeMixin,
        IsPeriodicValueStatusFunctionIdMixin,
        Uint32WithStatusBodyBytesConverterMixin {
  Uint32WithStatusIncomingDataSourcePackage(super.source);
}

abstract class Int16WithStatusIncomingDataSourcePackage
    extends DataSourceIncomingPackage<Int16WithStatusBody>
    with
        IsEventOrBufferRequestOrSubscriptionAnswerRequestTypeMixin,
        IsPeriodicValueStatusFunctionIdMixin,
        Int16WithStatusBodyBytesConverterMixin {
  Int16WithStatusIncomingDataSourcePackage(super.source);
}

abstract class Uint16WithStatusIncomingDataSourcePackage
    extends DataSourceIncomingPackage<Uint16WithStatusBody>
    with
        IsEventOrBufferRequestOrSubscriptionAnswerRequestTypeMixin,
        IsPeriodicValueStatusFunctionIdMixin,
        UInt16WithStatusBodyBytesConverterMixin {
  Uint16WithStatusIncomingDataSourcePackage(super.source);
}

abstract class TwoUint16WithStatusIncomingDataSourcePackage
    extends DataSourceIncomingPackage<TwoUint16WithStatusBody>
    with
        IsEventOrBufferRequestOrSubscriptionAnswerRequestTypeMixin,
        IsPeriodicValueStatusFunctionIdMixin,
        TwoUint16WithStatusBodyBytesConverterMixin {
  TwoUint16WithStatusIncomingDataSourcePackage(super.source);
}

abstract class TwoInt16WithStatusIncomingDataSourcePackage
    extends DataSourceIncomingPackage<TwoInt16WithStatusBody>
    with
        IsEventOrBufferRequestOrSubscriptionAnswerRequestTypeMixin,
        IsPeriodicValueStatusFunctionIdMixin,
        TwoInt16WithStatusBodyBytesConverterMixin {
  TwoInt16WithStatusIncomingDataSourcePackage(super.source);
}
