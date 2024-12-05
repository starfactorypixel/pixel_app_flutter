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
  const factory DataSourceParameterId.custom(int id) = CustomParameterId;

  const factory DataSourceParameterId.temperature1() = Temperature1ParameterId;
  const factory DataSourceParameterId.temperature2() = Temperature2ParameterId;
  //
  const factory DataSourceParameterId.lowVoltage1() = LowVoltage1ParameterId;
  const factory DataSourceParameterId.lowVoltage2() = LowVoltage2ParameterId;
  const factory DataSourceParameterId.batteryLevel() = BatteryLevelParameterId;
  const factory DataSourceParameterId.batteryPower() = BatteryPowerParameterId;

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
  const factory DataSourceParameterId.rpm() = RPMParameterId;
  const factory DataSourceParameterId.motorSpeed() = MotorSpeedParameterId;
  const factory DataSourceParameterId.motorVoltage() = MotorVoltageParameterId;
  const factory DataSourceParameterId.motorCurrent() = MotorCurrentParameterId;
  const factory DataSourceParameterId.motorPower() = MotorPowerParameterId;
  const factory DataSourceParameterId.gearAndRoll() = GearAndRollParameterId;
  const factory DataSourceParameterId.motorTemperature() =
      MotorTemperatureParameterId;
  const factory DataSourceParameterId.controllerTemperature() =
      ControllerTemperatureParameterId;
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

  bool get isTemperature1 => this is Temperature1ParameterId;
  bool get isTemperature2 => this is Temperature2ParameterId;

  //

  bool get isLowVoltage1 => this is LowVoltage1ParameterId;
  bool get isLowVoltage2 => this is LowVoltage2ParameterId;
  bool get isBatteryLevel => this is BatteryLevelParameterId;
  bool get isBatteryPower => this is BatteryPowerParameterId;

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
  bool get isRPM => this is RPMParameterId;
  bool get isMotorSpeed => this is MotorSpeedParameterId;
  bool get isMotorVoltage => this is MotorVoltageParameterId;
  bool get isMotorCurrent => this is MotorCurrentParameterId;
  bool get isMotorPower => this is MotorPowerParameterId;
  bool get isGearAndRoll => this is GearAndRollParameterId;
  bool get isMotorTemperature => this is MotorTemperatureParameterId;
  bool get isControllerTemperature => this is ControllerTemperatureParameterId;
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
      DataSourceParameterId.rpm(),
      DataSourceParameterId.motorSpeed(),
      DataSourceParameterId.motorVoltage(),
      DataSourceParameterId.motorCurrent(),
      DataSourceParameterId.motorPower(),
      DataSourceParameterId.gearAndRoll(),
      DataSourceParameterId.motorTemperature(),
      DataSourceParameterId.controllerTemperature(),
      DataSourceParameterId.odometer(),
      DataSourceParameterId.batteryLevel(),
      DataSourceParameterId.batteryPower(),
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

class BatteryLevelParameterId extends DataSourceParameterId {
  const BatteryLevelParameterId() : super(0x0056);
}

class BatteryPowerParameterId extends DataSourceParameterId {
  const BatteryPowerParameterId() : super(0x0057);
}

// Lights
abstract class SideBeamParameterId extends DataSourceParameterId {
  const SideBeamParameterId(super.value);
}

class FrontSideBeamParameterId extends SideBeamParameterId {
  const FrontSideBeamParameterId() : super(0x00C4);
}

class TailSideBeamParameterId extends SideBeamParameterId {
  const TailSideBeamParameterId() : super(0x00E4);
}

class LowBeamParameterId extends DataSourceParameterId {
  const LowBeamParameterId() : super(0x00C5);
}

class HighBeamParameterId extends DataSourceParameterId {
  const HighBeamParameterId() : super(0x00C6);
}

class FrontHazardBeamParameterId extends DataSourceParameterId {
  const FrontHazardBeamParameterId() : super(0x00C9);
}

class TailHazardBeamParameterId extends DataSourceParameterId {
  const TailHazardBeamParameterId() : super(0x00E9);
}

class TailCustomBeamParameterId extends DataSourceParameterId {
  const TailCustomBeamParameterId() : super(0x00EA);
}

class FrontLeftTurnSignalParameterId extends DataSourceParameterId {
  const FrontLeftTurnSignalParameterId() : super(0x00C7);
}

class FrontRightTurnSignalParameterId extends DataSourceParameterId {
  const FrontRightTurnSignalParameterId() : super(0x00C8);
}

class TailLeftTurnSignalParameterId extends DataSourceParameterId {
  const TailLeftTurnSignalParameterId() : super(0x00E7);
}

class TailRightTurnSignalParameterId extends DataSourceParameterId {
  const TailRightTurnSignalParameterId() : super(0x00E8);
}

class BrakeLightParameterId extends DataSourceParameterId {
  const BrakeLightParameterId() : super(0x00E5);
}

class ReverseLightParameterId extends DataSourceParameterId {
  const ReverseLightParameterId() : super(0x00E6);
}

class CustomImageParameterId extends DataSourceParameterId {
  const CustomImageParameterId() : super(0x00EB);
}

class RPMParameterId extends DataSourceParameterId {
  const RPMParameterId() : super(0x0105);
}

class MotorSpeedParameterId extends DataSourceParameterId {
  const MotorSpeedParameterId() : super(0x0106);
}

class MotorVoltageParameterId extends DataSourceParameterId {
  const MotorVoltageParameterId() : super(0x0107);
}

class MotorCurrentParameterId extends DataSourceParameterId {
  const MotorCurrentParameterId() : super(0x0108);
}

class MotorPowerParameterId extends DataSourceParameterId {
  const MotorPowerParameterId() : super(0x0109);
}

class GearAndRollParameterId extends DataSourceParameterId {
  const GearAndRollParameterId() : super(0x010A);
}

class MotorTemperatureParameterId extends DataSourceParameterId {
  const MotorTemperatureParameterId() : super(0x010B);
}

class ControllerTemperatureParameterId extends DataSourceParameterId {
  const ControllerTemperatureParameterId() : super(0x010C);
}

class OdometerParameterId extends DataSourceParameterId {
  const OdometerParameterId() : super(0x010D);
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
