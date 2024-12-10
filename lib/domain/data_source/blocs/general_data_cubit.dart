import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/app/app.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/battery_percent.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/incoming_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/implementations/battery_percent.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/implementations/uint16_with_status_body.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/wrappers/bytes_convertible_with_status.dart';
import 'package:re_seedwork/re_seedwork.dart';

@immutable
final class IntWithStatus {
  const IntWithStatus({
    required this.value,
    required this.status,
  });

  const IntWithStatus.initial()
      : value = 0,
        status = PeriodicValueStatus.normal;

  factory IntWithStatus.fromMap(Map<String, dynamic> map) {
    return IntWithStatus(
      value: map.parse('value'),
      status: PeriodicValueStatus.fromId(map.parse('status')),
    );
  }

  final int value;
  final PeriodicValueStatus status;

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'status': status.id,
    };
  }
}

extension on IntBytesConvertibleWithStatus {
  IntWithStatus toIntWithStatus([int? customValue]) =>
      IntWithStatus(value: customValue ?? value, status: status);
}

extension on Sequence<IntWithStatus> {
  Map<String, dynamic> toMap() {
    return {
      'value': this,
    };
  }
}

@sealed
@immutable
final class GeneralDataState with EquatableMixin {
  const GeneralDataState({
    required this.batteriesCount,
    required this.power,
    required this.batteryLevel,
    required this.odometer,
    required this.speed,
    required this.gear,
  });

  GeneralDataState.initial({
    required this.batteriesCount,
  })  : power = const IntWithStatus.initial(),
        batteryLevel = Sequence<IntWithStatus>.fill(
          batteriesCount,
          const IntWithStatus.initial(),
        ),
        odometer = const IntWithStatus.initial(),
        speed = const IntWithStatus.initial(),
        gear = MotorGear.unknown;

  factory GeneralDataState.fromMap(Map<String, dynamic> map) {
    return GeneralDataState(
      batteriesCount: map.parse('batteriesCount'),
      power: map.parseAndMap('power', IntWithStatus.fromMap),
      batteryLevel: map.parseAndMap('batteryLevel', sequenceFromMap),
      odometer: map.parseAndMap('odometer', IntWithStatus.fromMap),
      speed: map.parseAndMap('speed', IntWithStatus.fromMap),
      gear: map.parseAndMap('gear', MotorGear.fromId),
    );
  }

  static Sequence<IntWithStatus> sequenceFromMap(Map<String, dynamic> map) {
    return map.parse('value');
  }

  final int batteriesCount;
  final IntWithStatus power;
  final Sequence<IntWithStatus> batteryLevel;
  final IntWithStatus odometer;
  final IntWithStatus speed;
  final MotorGear gear;

  @override
  List<Object?> get props => [
        power,
        batteryLevel,
        odometer,
        speed,
        gear,
      ];

  GeneralDataState copyWith({
    int? batteriesCount,
    IntWithStatus? power,
    Sequence<IntWithStatus>? batteryLevel,
    IntWithStatus? odometer,
    IntWithStatus? speed,
    MotorGear? gear,
  }) {
    return GeneralDataState(
      batteriesCount: batteriesCount ?? this.batteriesCount,
      power: power ?? this.power,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      odometer: odometer ?? this.odometer,
      speed: speed ?? this.speed,
      gear: gear ?? this.gear,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'batteriesCount': batteriesCount,
      'power': power.toMap(),
      'batteryLevel': batteryLevel.toMap(),
      'odometer': odometer.toMap(),
      'speed': speed.toMap(),
      'gear': gear.id,
    };
  }
}

class GeneralDataCubit extends Cubit<GeneralDataState> with ConsumerBlocMixin {
  GeneralDataCubit({
    required this.dataSource,
    required int batteriesCount,
  }) : super(GeneralDataState.initial(batteriesCount: batteriesCount)) {
    subscribe<DataSourceIncomingPackage>(dataSource.packageStream, (package) {
      package
        ..voidOnPackage<BatteryPercent,
            BatteryPercentIncomingDataSourcePackage>(
          (package) => emit(
            state.copyWith(
              batteryLevel: state.batteryLevel.updateAt(
                package.batteryIndex,
                package.dataModel.toIntWithStatus(),
              ),
            ),
          ),
        )
        ..voidOnModel<Int16WithStatusBody,
            BatteryPowerIncomingDataSourcePackage>((model) {
          emit(state.copyWith(power: model.toIntWithStatus()));
        })
        ..voidOnModel<MotorGearAndRoll,
            MotorGearAndRollIncomingDataSourcePackage>((model) {
          emit(
            state.copyWith(
              gear: MotorGear.unknown,
            ),
          ); // TODO(alexandr): show something from 4 motors.
        })
        ..voidOnModel<UInt16WithStatusBody,
            MotorSpeedIncomingDataSourcePackage>((package) {
          emit(
            state.copyWith(
              speed: package.toIntWithStatus(
                0,
              ),
            ),
          ); // TODO(alexandr): show something from 4 motors.
        })
        ..voidOnModel<Uint32WithStatusBody, OdometerIncomingDataSourcePackage>(
            (model) {
          final km = model.value ~/ 10;
          emit(state.copyWith(odometer: model.toIntWithStatus(km)));
        });
    });
  }

  static Set<DataSourceParameterId> kDefaultSubscribeParameters = {
    const DataSourceParameterId.motorSpeed1(),
    const DataSourceParameterId.motorSpeed2(),
    const DataSourceParameterId.motorSpeed3(),
    const DataSourceParameterId.motorSpeed4(),
    const DataSourceParameterId.odometer(),
    const DataSourceParameterId.gearAndRoll1(),
    const DataSourceParameterId.gearAndRoll2(),
    const DataSourceParameterId.gearAndRoll3(),
    const DataSourceParameterId.gearAndRoll4(),
    const DataSourceParameterId.batteryPercent1(),
    const DataSourceParameterId.batteryPercent2(),
    const DataSourceParameterId.batteryPower(),
  };

  @protected
  final DataSource dataSource;
}
