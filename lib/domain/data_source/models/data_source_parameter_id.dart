import 'package:meta/meta.dart';

@immutable
abstract class DataSourceParameterId {
  const DataSourceParameterId(this.value);

  factory DataSourceParameterId.fromInt(int id) {
    return all.firstWhere(
      (element) => element.value == id,
      orElse: () => DataSourceParameterId.custom(id),
    );
  }

  const factory DataSourceParameterId.authorization() =
      AuthorizationParameterId;

  const factory DataSourceParameterId.speed() = SpeedParameterId;

  const factory DataSourceParameterId.light() = LightParameterId;

  const factory DataSourceParameterId.voltage() = VoltageParameterId;

  const factory DataSourceParameterId.current() = CurrentParameterId;

  const factory DataSourceParameterId.lowVoltageMinMaxDelta1() =
      LowVoltageMinMaxDelta1ParameterId;
  const factory DataSourceParameterId.lowVoltageMinMaxDelta2() =
      LowVoltageMinMaxDelta2ParameterId;

  const factory DataSourceParameterId.highVoltage1() = HighVoltage1ParameterId;
  const factory DataSourceParameterId.highVoltage2() = HighVoltage2ParameterId;

  const factory DataSourceParameterId.highCurrent1() = HighCurrent1ParameterId;
  const factory DataSourceParameterId.highCurrent2() = HighCurrent2ParameterId;

  const factory DataSourceParameterId.maxTemperature1() =
      MaxTemperature1ParameterId;
  const factory DataSourceParameterId.maxTemperature2() =
      MaxTemperature2ParameterId;

  const factory DataSourceParameterId.batteryPercent1() =
      BatteryPercent1ParameterId;
  const factory DataSourceParameterId.batteryPercent2() =
      BatteryPercent2ParameterId;

  const factory DataSourceParameterId.custom(int id) = CustomParameterId;

  const factory DataSourceParameterId.temperature1() = Temperature1ParameterId;
  const factory DataSourceParameterId.temperature2() = Temperature2ParameterId;

  //
  const factory DataSourceParameterId.lowVoltage1() = LowVoltage1ParameterId;
  const factory DataSourceParameterId.lowVoltage2() = LowVoltage2ParameterId;

  const factory DataSourceParameterId.batteryPower1() =
      BatteryPower1ParameterId;
  const factory DataSourceParameterId.batteryPower2() =
      BatteryPower2ParameterId;

  //
  const factory DataSourceParameterId.frontSideBeam() =
      FrontSideBeamParameterId;
  const factory DataSourceParameterId.tailSideBeam() = TailSideBeamParameterId;

  const factory DataSourceParameterId.lowBeam() = LowBeamParameterId;
  const factory DataSourceParameterId.highBeam() = HighBeamParameterId;

  const factory DataSourceParameterId.frontHazardBeam() =
      FrontHazardBeamParameterId;
  const factory DataSourceParameterId.tailHazardBeam() =
      TailHazardBeamParameterId;

  const factory DataSourceParameterId.tailCustomBeam() =
      TailCustomBeamParameterId;

  const factory DataSourceParameterId.frontLeftTurnSignal() =
      FrontLeftTurnSignalParameterId;
  const factory DataSourceParameterId.frontRightTurnSignal() =
      FrontRightTurnSignalParameterId;
  const factory DataSourceParameterId.tailLeftTurnSignal() =
      TailLeftTurnSignalParameterId;
  const factory DataSourceParameterId.tailRightTurnSignal() =
      TailRightTurnSignalParameterId;

  const factory DataSourceParameterId.brakeLight() = BrakeLightParameterId;

  const factory DataSourceParameterId.reverseLight() = ReverseLightParameterId;

  const factory DataSourceParameterId.customImage() = CustomImageParameterId;

  //
  const factory DataSourceParameterId.rpm1() = RPM1ParameterId;
  const factory DataSourceParameterId.rpm2() = RPM2ParameterId;
  const factory DataSourceParameterId.rpm3() = RPM3ParameterId;
  const factory DataSourceParameterId.rpm4() = RPM4ParameterId;

  const factory DataSourceParameterId.motorSpeed1() = MotorSpeed1ParameterId;
  const factory DataSourceParameterId.motorSpeed2() = MotorSpeed2ParameterId;
  const factory DataSourceParameterId.motorSpeed3() = MotorSpeed3ParameterId;
  const factory DataSourceParameterId.motorSpeed4() = MotorSpeed4ParameterId;

  const factory DataSourceParameterId.motorVoltage1() =
      MotorVoltage1ParameterId;
  const factory DataSourceParameterId.motorVoltage2() =
      MotorVoltage2ParameterId;
  const factory DataSourceParameterId.motorVoltage3() =
      MotorVoltage3ParameterId;
  const factory DataSourceParameterId.motorVoltage4() =
      MotorVoltage4ParameterId;

  const factory DataSourceParameterId.motorCurrent1() =
      MotorCurrent1ParameterId;
  const factory DataSourceParameterId.motorCurrent2() =
      MotorCurrent2ParameterId;
  const factory DataSourceParameterId.motorCurrent3() =
      MotorCurrent3ParameterId;
  const factory DataSourceParameterId.motorCurrent4() =
      MotorCurrent4ParameterId;

  const factory DataSourceParameterId.motorPower1() = MotorPower1ParameterId;
  const factory DataSourceParameterId.motorPower2() = MotorPower2ParameterId;
  const factory DataSourceParameterId.motorPower3() = MotorPower3ParameterId;
  const factory DataSourceParameterId.motorPower4() = MotorPower4ParameterId;

  const factory DataSourceParameterId.gearAndRoll1() = GearAndRoll1ParameterId;
  const factory DataSourceParameterId.gearAndRoll2() = GearAndRoll2ParameterId;
  const factory DataSourceParameterId.gearAndRoll3() = GearAndRoll3ParameterId;
  const factory DataSourceParameterId.gearAndRoll4() = GearAndRoll4ParameterId;

  const factory DataSourceParameterId.transmission1() =
      Transmission1ParameterId;
  const factory DataSourceParameterId.transmission2() =
      Transmission2ParameterId;
  const factory DataSourceParameterId.transmission3() =
      Transmission3ParameterId;
  const factory DataSourceParameterId.transmission4() =
      Transmission4ParameterId;

  const factory DataSourceParameterId.motorTemperature1() =
      MotorTemperature1ParameterId;
  const factory DataSourceParameterId.motorTemperature2() =
      MotorTemperature2ParameterId;
  const factory DataSourceParameterId.motorTemperature3() =
      MotorTemperature3ParameterId;
  const factory DataSourceParameterId.motorTemperature4() =
      MotorTemperature4ParameterId;

  const factory DataSourceParameterId.controllerTemperature1() =
      ControllerTemperature1ParameterId;
  const factory DataSourceParameterId.controllerTemperature2() =
      ControllerTemperature2ParameterId;
  const factory DataSourceParameterId.controllerTemperature3() =
      ControllerTemperature3ParameterId;
  const factory DataSourceParameterId.controllerTemperature4() =
      ControllerTemperature4ParameterId;

  const factory DataSourceParameterId.odometer() = OdometerParameterId;

  const factory DataSourceParameterId.trunk() = TrunkParameterId;

  const factory DataSourceParameterId.hood() = HoodParameterId;

  const factory DataSourceParameterId.leftDoor() = LeftDoorParameterId;
  const factory DataSourceParameterId.rightDoor() = RightDoorParameterId;

  const factory DataSourceParameterId.cabinLight() = CabinLightParameterId;

  const factory DataSourceParameterId.windscreenWipers() =
      WindscreenWipersParameterId;

  bool get isAuthorization => this is AuthorizationParameterId;

  bool get isSpeed => this is SpeedParameterId;

  bool get isLight => this is LightParameterId;

  bool get isCurrent => this is CurrentParameterId;

  bool get isVoltage => this is VoltageParameterId;

  bool get isLowVoltageMinMaxDelta1 =>
      this is LowVoltageMinMaxDelta1ParameterId;
  bool get isLowVoltageMinMaxDelta2 =>
      this is LowVoltageMinMaxDelta2ParameterId;

  bool get isHighVoltage1 => this is HighVoltage1ParameterId;
  bool get isHighVoltage2 => this is HighVoltage2ParameterId;

  bool get isHighCurrent1 => this is HighCurrent1ParameterId;
  bool get isHighCurrent2 => this is HighCurrent2ParameterId;

  bool get isMaxTemperature1 => this is MaxTemperature1ParameterId;
  bool get isMaxTemperature2 => this is MaxTemperature2ParameterId;

  bool get isBatteryPercent1 => this is BatteryPercent1ParameterId;
  bool get isBatteryPercent2 => this is BatteryPercent2ParameterId;

  bool get isTemperature1 => this is Temperature1ParameterId;
  bool get isTemperature2 => this is Temperature2ParameterId;

  //

  bool get isLowVoltage1 => this is LowVoltage1ParameterId;
  bool get isLowVoltage2 => this is LowVoltage2ParameterId;

  bool get isBatteryPower1 => this is BatteryPower1ParameterId;
  bool get isBatteryPower2 => this is BatteryPower2ParameterId;

  bool get isFrontSideBeam => this is FrontSideBeamParameterId;
  bool get isTailSideBeam => this is TailSideBeamParameterId;

  bool get isLowBeam => this is LowBeamParameterId;
  bool get isHighBeam => this is HighBeamParameterId;

  bool get isFrontHazardBeam => this is FrontHazardBeamParameterId;
  bool get isTailHazardBeam => this is TailHazardBeamParameterId;

  bool get isTailCustomBeam => this is TailCustomBeamParameterId;

  bool get isFrontLeftTurnSignal => this is FrontLeftTurnSignalParameterId;
  bool get isFrontRightTurnSignal => this is FrontRightTurnSignalParameterId;
  bool get isTailLeftTurnSignal => this is TailLeftTurnSignalParameterId;
  bool get isTailRightTurnSignal => this is TailRightTurnSignalParameterId;

  bool get isBrakeLight => this is BrakeLightParameterId;

  bool get isReverseLight => this is ReverseLightParameterId;

  bool get isCustomImage => this is CustomImageParameterId;

  //
  bool get isRPM1 => this is RPM1ParameterId;
  bool get isRPM2 => this is RPM2ParameterId;
  bool get isRPM3 => this is RPM3ParameterId;
  bool get isRPM4 => this is RPM4ParameterId;

  bool get isMotorSpeed1 => this is MotorSpeed1ParameterId;
  bool get isMotorSpeed2 => this is MotorSpeed2ParameterId;
  bool get isMotorSpeed3 => this is MotorSpeed3ParameterId;
  bool get isMotorSpeed4 => this is MotorSpeed4ParameterId;

  bool get isMotorVoltage1 => this is MotorVoltage1ParameterId;
  bool get isMotorVoltage2 => this is MotorVoltage2ParameterId;
  bool get isMotorVoltage3 => this is MotorVoltage3ParameterId;
  bool get isMotorVoltage4 => this is MotorVoltage4ParameterId;

  bool get isMotorCurrent1 => this is MotorCurrent1ParameterId;
  bool get isMotorCurrent2 => this is MotorCurrent2ParameterId;
  bool get isMotorCurrent3 => this is MotorCurrent3ParameterId;
  bool get isMotorCurrent4 => this is MotorCurrent4ParameterId;

  bool get isMotorPower1 => this is MotorPower1ParameterId;
  bool get isMotorPower2 => this is MotorPower2ParameterId;
  bool get isMotorPower3 => this is MotorPower3ParameterId;
  bool get isMotorPower4 => this is MotorPower4ParameterId;

  bool get isGearAndRoll1 => this is GearAndRoll1ParameterId;
  bool get isGearAndRoll2 => this is GearAndRoll2ParameterId;
  bool get isGearAndRoll3 => this is GearAndRoll3ParameterId;
  bool get isGearAndRoll4 => this is GearAndRoll4ParameterId;

  bool get isTransmission1 => this is Transmission1ParameterId;
  bool get isTransmission2 => this is Transmission2ParameterId;
  bool get isTransmission3 => this is Transmission3ParameterId;
  bool get isTransmission4 => this is Transmission4ParameterId;

  bool get isMotorTemperature1 => this is MotorTemperature1ParameterId;
  bool get isMotorTemperature2 => this is MotorTemperature2ParameterId;
  bool get isMotorTemperature3 => this is MotorTemperature3ParameterId;
  bool get isMotorTemperature4 => this is MotorTemperature4ParameterId;

  bool get isControllerTemperature1 =>
      this is ControllerTemperature1ParameterId;
  bool get isControllerTemperature2 =>
      this is ControllerTemperature2ParameterId;
  bool get isControllerTemperature3 =>
      this is ControllerTemperature3ParameterId;
  bool get isControllerTemperature4 =>
      this is ControllerTemperature4ParameterId;

  bool get isOdometer => this is OdometerParameterId;

  bool get isTrunk => this is TrunkParameterId;

  bool get isHood => this is HoodParameterId;

  bool get isLeftDoor => this is LeftDoorParameterId;

  bool get isRightDoor => this is RightDoorParameterId;

  bool get isCabinLight => this is CabinLightParameterId;

  bool get isWindscreenWipers => this is WindscreenWipersParameterId;

  void voidOn<T extends DataSourceParameterId>(void Function() function) {
    if (this is T) function();
  }

  static List<DataSourceParameterId> get all {
    return const [
      DataSourceParameterId.authorization(),
      DataSourceParameterId.speed(),
      DataSourceParameterId.light(),
      DataSourceParameterId.voltage(),
      DataSourceParameterId.current(),
      //
      DataSourceParameterId.highCurrent1(),
      DataSourceParameterId.highCurrent2(),
      DataSourceParameterId.highVoltage1(),
      DataSourceParameterId.highVoltage2(),
      DataSourceParameterId.maxTemperature1(),
      DataSourceParameterId.maxTemperature2(),
      DataSourceParameterId.lowVoltageMinMaxDelta1(),
      DataSourceParameterId.lowVoltageMinMaxDelta2(),
      DataSourceParameterId.batteryPercent1(),
      DataSourceParameterId.batteryPercent2(),
      //
      DataSourceParameterId.temperature1(),
      DataSourceParameterId.temperature2(),
      //
      DataSourceParameterId.lowVoltage1(),
      DataSourceParameterId.lowVoltage2(),
      //
      DataSourceParameterId.frontSideBeam(),
      DataSourceParameterId.tailSideBeam(),
      DataSourceParameterId.lowBeam(),
      DataSourceParameterId.highBeam(),
      DataSourceParameterId.frontHazardBeam(),
      DataSourceParameterId.tailHazardBeam(),
      DataSourceParameterId.tailCustomBeam(),
      DataSourceParameterId.frontLeftTurnSignal(),
      DataSourceParameterId.frontRightTurnSignal(),
      DataSourceParameterId.tailLeftTurnSignal(),
      DataSourceParameterId.tailRightTurnSignal(),
      DataSourceParameterId.brakeLight(),
      DataSourceParameterId.reverseLight(),
      DataSourceParameterId.customImage(),
      //
      DataSourceParameterId.rpm1(),
      DataSourceParameterId.rpm2(),
      DataSourceParameterId.rpm3(),
      DataSourceParameterId.rpm4(),
      DataSourceParameterId.motorSpeed1(),
      DataSourceParameterId.motorSpeed2(),
      DataSourceParameterId.motorSpeed3(),
      DataSourceParameterId.motorSpeed4(),
      DataSourceParameterId.motorVoltage1(),
      DataSourceParameterId.motorVoltage2(),
      DataSourceParameterId.motorVoltage3(),
      DataSourceParameterId.motorVoltage4(),
      DataSourceParameterId.motorCurrent1(),
      DataSourceParameterId.motorCurrent2(),
      DataSourceParameterId.motorCurrent3(),
      DataSourceParameterId.motorCurrent4(),
      DataSourceParameterId.motorPower1(),
      DataSourceParameterId.motorPower2(),
      DataSourceParameterId.motorPower3(),
      DataSourceParameterId.motorPower4(),
      DataSourceParameterId.gearAndRoll1(),
      DataSourceParameterId.gearAndRoll2(),
      DataSourceParameterId.gearAndRoll3(),
      DataSourceParameterId.gearAndRoll4(),
      DataSourceParameterId.transmission1(),
      DataSourceParameterId.transmission2(),
      DataSourceParameterId.transmission3(),
      DataSourceParameterId.transmission4(),
      DataSourceParameterId.motorTemperature1(),
      DataSourceParameterId.motorTemperature2(),
      DataSourceParameterId.motorTemperature3(),
      DataSourceParameterId.motorTemperature4(),
      DataSourceParameterId.controllerTemperature1(),
      DataSourceParameterId.controllerTemperature2(),
      DataSourceParameterId.controllerTemperature3(),
      DataSourceParameterId.controllerTemperature4(),
      DataSourceParameterId.odometer(),
      DataSourceParameterId.batteryPower1(),
      DataSourceParameterId.batteryPower2(),
      //
      DataSourceParameterId.trunk(),
      DataSourceParameterId.hood(),
      DataSourceParameterId.leftDoor(),
      DataSourceParameterId.rightDoor(),
      DataSourceParameterId.cabinLight(),
      //
      DataSourceParameterId.windscreenWipers(),
    ];
  }

  final int value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DataSourceParameterId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class AuthorizationParameterId extends DataSourceParameterId {
  const AuthorizationParameterId() : super(0x0001);
}

class SpeedParameterId extends DataSourceParameterId {
  const SpeedParameterId() : super(125);
}

class LightParameterId extends DataSourceParameterId {
  const LightParameterId() : super(513);
}

class VoltageParameterId extends DataSourceParameterId {
  const VoltageParameterId() : super(174);
}

class CurrentParameterId extends DataSourceParameterId {
  const CurrentParameterId() : super(239);
}

class CustomParameterId extends DataSourceParameterId {
  const CustomParameterId(super.id);
}

class LowVoltageMinMaxDelta1ParameterId extends DataSourceParameterId {
  const LowVoltageMinMaxDelta1ParameterId() : super(0x018E);
}

class LowVoltageMinMaxDelta2ParameterId extends DataSourceParameterId {
  const LowVoltageMinMaxDelta2ParameterId() : super(0x018F);
}

class HighVoltage1ParameterId extends DataSourceParameterId {
  const HighVoltage1ParameterId() : super(0x018C);
}

class HighVoltage2ParameterId extends DataSourceParameterId {
  const HighVoltage2ParameterId() : super(0x018D);
}

class HighCurrent1ParameterId extends DataSourceParameterId {
  const HighCurrent1ParameterId() : super(0x0184);
}

class HighCurrent2ParameterId extends DataSourceParameterId {
  const HighCurrent2ParameterId() : super(0x0185);
}

class BatteryPercent1ParameterId extends DataSourceParameterId {
  const BatteryPercent1ParameterId() : super(0x0186);
}

class BatteryPercent2ParameterId extends DataSourceParameterId {
  const BatteryPercent2ParameterId() : super(0x0187);
}

class MaxTemperature1ParameterId extends DataSourceParameterId {
  const MaxTemperature1ParameterId() : super(0x0192);
}

class MaxTemperature2ParameterId extends DataSourceParameterId {
  const MaxTemperature2ParameterId() : super(0x0193);
}

class Temperature1ParameterId extends DataSourceParameterId {
  const Temperature1ParameterId() : super(0x0194);
}

class Temperature2ParameterId extends DataSourceParameterId {
  const Temperature2ParameterId() : super(0x0195);
}

class LowVoltage1ParameterId extends DataSourceParameterId {
  const LowVoltage1ParameterId() : super(0x0190);
}

class LowVoltage2ParameterId extends DataSourceParameterId {
  const LowVoltage2ParameterId() : super(0x0191);
}

class BatteryPower1ParameterId extends DataSourceParameterId {
  const BatteryPower1ParameterId() : super(0x0188);
}

class BatteryPower2ParameterId extends DataSourceParameterId {
  const BatteryPower2ParameterId() : super(0x0189);
}

// Lights
abstract class SideBeamParameterId extends DataSourceParameterId {
  const SideBeamParameterId(super.value);
}

class FrontSideBeamParameterId extends SideBeamParameterId {
  const FrontSideBeamParameterId() : super(0x01C4);
}

class TailSideBeamParameterId extends SideBeamParameterId {
  const TailSideBeamParameterId() : super(0x01E4);
}

class LowBeamParameterId extends DataSourceParameterId {
  const LowBeamParameterId() : super(0x01C5);
}

class HighBeamParameterId extends DataSourceParameterId {
  const HighBeamParameterId() : super(0x01C6);
}

class FrontHazardBeamParameterId extends DataSourceParameterId {
  const FrontHazardBeamParameterId() : super(0x01C9);
}

class TailHazardBeamParameterId extends DataSourceParameterId {
  const TailHazardBeamParameterId() : super(0x01E9);
}

class TailCustomBeamParameterId extends DataSourceParameterId {
  const TailCustomBeamParameterId() : super(0x01EA);
}

class FrontLeftTurnSignalParameterId extends DataSourceParameterId {
  const FrontLeftTurnSignalParameterId() : super(0x01C7);
}

class FrontRightTurnSignalParameterId extends DataSourceParameterId {
  const FrontRightTurnSignalParameterId() : super(0x01C8);
}

class TailLeftTurnSignalParameterId extends DataSourceParameterId {
  const TailLeftTurnSignalParameterId() : super(0x01E7);
}

class TailRightTurnSignalParameterId extends DataSourceParameterId {
  const TailRightTurnSignalParameterId() : super(0x01E8);
}

class BrakeLightParameterId extends DataSourceParameterId {
  const BrakeLightParameterId() : super(0x01E5);
}

class ReverseLightParameterId extends DataSourceParameterId {
  const ReverseLightParameterId() : super(0x01E6);
}

class CustomImageParameterId extends DataSourceParameterId {
  const CustomImageParameterId() : super(0x01EB);
}

class RPM1ParameterId extends DataSourceParameterId {
  const RPM1ParameterId() : super(0x010E);
}

class RPM2ParameterId extends DataSourceParameterId {
  const RPM2ParameterId() : super(0x010F);
}

class RPM3ParameterId extends DataSourceParameterId {
  const RPM3ParameterId() : super(0x013E);
}

class RPM4ParameterId extends DataSourceParameterId {
  const RPM4ParameterId() : super(0x013F);
}

class MotorSpeed1ParameterId extends DataSourceParameterId {
  const MotorSpeed1ParameterId() : super(0x0110);
}

class MotorSpeed2ParameterId extends DataSourceParameterId {
  const MotorSpeed2ParameterId() : super(0x0111);
}

class MotorSpeed3ParameterId extends DataSourceParameterId {
  const MotorSpeed3ParameterId() : super(0x0140);
}

class MotorSpeed4ParameterId extends DataSourceParameterId {
  const MotorSpeed4ParameterId() : super(0x0141);
}

class MotorVoltage1ParameterId extends DataSourceParameterId {
  const MotorVoltage1ParameterId() : super(0x0112);
}

class MotorVoltage2ParameterId extends DataSourceParameterId {
  const MotorVoltage2ParameterId() : super(0x0113);
}

class MotorVoltage3ParameterId extends DataSourceParameterId {
  const MotorVoltage3ParameterId() : super(0x0142);
}

class MotorVoltage4ParameterId extends DataSourceParameterId {
  const MotorVoltage4ParameterId() : super(0x0143);
}

class MotorCurrent1ParameterId extends DataSourceParameterId {
  const MotorCurrent1ParameterId() : super(0x0114);
}

class MotorCurrent2ParameterId extends DataSourceParameterId {
  const MotorCurrent2ParameterId() : super(0x0115);
}

class MotorCurrent3ParameterId extends DataSourceParameterId {
  const MotorCurrent3ParameterId() : super(0x0144);
}

class MotorCurrent4ParameterId extends DataSourceParameterId {
  const MotorCurrent4ParameterId() : super(0x0145);
}

class MotorPower1ParameterId extends DataSourceParameterId {
  const MotorPower1ParameterId() : super(0x0116);
}

class MotorPower2ParameterId extends DataSourceParameterId {
  const MotorPower2ParameterId() : super(0x0117);
}

class MotorPower3ParameterId extends DataSourceParameterId {
  const MotorPower3ParameterId() : super(0x0146);
}

class MotorPower4ParameterId extends DataSourceParameterId {
  const MotorPower4ParameterId() : super(0x0147);
}

class GearAndRoll1ParameterId extends DataSourceParameterId {
  const GearAndRoll1ParameterId() : super(0x0118);
}

class GearAndRoll2ParameterId extends DataSourceParameterId {
  const GearAndRoll2ParameterId() : super(0x0119);
}

class GearAndRoll3ParameterId extends DataSourceParameterId {
  const GearAndRoll3ParameterId() : super(0x0148);
}

class GearAndRoll4ParameterId extends DataSourceParameterId {
  const GearAndRoll4ParameterId() : super(0x0149);
}

class Transmission1ParameterId extends DataSourceParameterId {
  const Transmission1ParameterId() : super(0x0106);
}

class Transmission2ParameterId extends DataSourceParameterId {
  const Transmission2ParameterId() : super(0x0107);
}

class Transmission3ParameterId extends DataSourceParameterId {
  const Transmission3ParameterId() : super(0x0136);
}

class Transmission4ParameterId extends DataSourceParameterId {
  const Transmission4ParameterId() : super(0x0137);
}

class MotorTemperature1ParameterId extends DataSourceParameterId {
  const MotorTemperature1ParameterId() : super(0x011A);
}

class MotorTemperature2ParameterId extends DataSourceParameterId {
  const MotorTemperature2ParameterId() : super(0x011B);
}

class MotorTemperature3ParameterId extends DataSourceParameterId {
  const MotorTemperature3ParameterId() : super(0x014A);
}

class MotorTemperature4ParameterId extends DataSourceParameterId {
  const MotorTemperature4ParameterId() : super(0x014B);
}

class ControllerTemperature1ParameterId extends DataSourceParameterId {
  const ControllerTemperature1ParameterId() : super(0x011C);
}

class ControllerTemperature2ParameterId extends DataSourceParameterId {
  const ControllerTemperature2ParameterId() : super(0x011D);
}

class ControllerTemperature3ParameterId extends DataSourceParameterId {
  const ControllerTemperature3ParameterId() : super(0x014C);
}

class ControllerTemperature4ParameterId extends DataSourceParameterId {
  const ControllerTemperature4ParameterId() : super(0x014D);
}

class OdometerParameterId extends DataSourceParameterId {
  const OdometerParameterId() : super(0x014E);
}

class TrunkParameterId extends DataSourceParameterId {
  const TrunkParameterId() : super(0x0184);
}

class HoodParameterId extends DataSourceParameterId {
  const HoodParameterId() : super(0x0185);
}

class LeftDoorParameterId extends DataSourceParameterId {
  const LeftDoorParameterId() : super(0x0187);
}

class RightDoorParameterId extends DataSourceParameterId {
  const RightDoorParameterId() : super(0x0188);
}

class CabinLightParameterId extends DataSourceParameterId {
  const CabinLightParameterId() : super(0x0189);
}

class WindscreenWipersParameterId extends DataSourceParameterId {
  const WindscreenWipersParameterId() : super(0x00CA);
}
