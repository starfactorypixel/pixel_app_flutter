import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/app/app.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/battery_percent.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/incoming_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/implementations/battery_percent.dart';
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

@sealed
@immutable
final class GeneralDataState with EquatableMixin {
  const GeneralDataState({
    required this.hardwareCount,
    required this.power,
    required this.batteryLevel,
    required this.odometer,
    required this.speed,
    required this.gear,
  });

  GeneralDataState.initial({
    required this.hardwareCount,
  })  : power = const IntWithStatus.initial(),
        batteryLevel = Sequence.fill(
          hardwareCount.batteries,
          const IntWithStatus.initial(),
        ),
        odometer = const IntWithStatus.initial(),
        speed = const IntWithStatus.initial(),
        gear = MotorGear.unknown;

  factory GeneralDataState.fromMap(Map<String, dynamic> map) {
    return GeneralDataState(
      hardwareCount: map.parseAndMap('hardwareCount', HardwareCount.fromMap),
      power: map.parseAndMap('power', IntWithStatus.fromMap),
      batteryLevel: Sequence.fromIterable(
        map.tryParseAndMapList('batteryLevel', IntWithStatus.fromMap),
      ),
      odometer: map.parseAndMap('odometer', IntWithStatus.fromMap),
      speed: map.parseAndMap('speed', IntWithStatus.fromMap),
      gear: map.parseAndMap('gear', MotorGear.fromId),
    );
  }

  final HardwareCount hardwareCount;
  final IntWithStatus power;
  final IntWithStatus odometer;
  final IntWithStatus speed;
  final MotorGear gear;
  final Sequence<IntWithStatus> batteryLevel;

  IntWithStatus get mergedBatteryLevel {
    if (batteryLevel.length == 1) return batteryLevel.first;
    //
    final (levelSum, status) =
        batteryLevel.fold((0, PeriodicValueStatus.normal), (a, b) {
      return (a.$1 + b.value, a.$2.id > b.status.id ? a.$2 : b.status);
    });
    //
    return IntWithStatus(
      value: levelSum ~/ batteryLevel.length,
      status: status,
    );
  }

  @override
  List<Object?> get props => [
        power,
        batteryLevel,
        odometer,
        speed,
        gear,
      ];

  GeneralDataState copyWith({
    IntWithStatus? power,
    Sequence<IntWithStatus>? batteryLevel,
    IntWithStatus? odometer,
    IntWithStatus? speed,
    MotorGear? gear,
  }) {
    return GeneralDataState(
      hardwareCount: hardwareCount,
      power: power ?? this.power,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      odometer: odometer ?? this.odometer,
      speed: speed ?? this.speed,
      gear: gear ?? this.gear,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hardwareCount': hardwareCount.toMap(),
      'power': power.toMap(),
      'batteryLevel': batteryLevel.map((e) => e.toMap()).toList(),
      'odometer': odometer.toMap(),
      'speed': speed.toMap(),
      'gear': gear.id,
    };
  }
}

class GeneralDataCubit extends Cubit<GeneralDataState> with ConsumerBlocMixin {
  GeneralDataCubit({
    required this.dataSource,
    required HardwareCount hardwareCount,
  }) : super(GeneralDataState.initial(hardwareCount: hardwareCount)) {
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
          emit(state.copyWith(gear: model.gear));
        })
        ..voidOnModel<TwoUint16WithStatusBody,
            MotorSpeedIncomingDataSourcePackage>((model) {
          final avgHundredMetersPerHour = (model.first + model.second) / 2;
          final avgKmPerHour = avgHundredMetersPerHour ~/ 10;
          emit(state.copyWith(speed: model.toIntWithStatus(avgKmPerHour)));
        })
        ..voidOnModel<Uint32WithStatusBody, OdometerIncomingDataSourcePackage>(
            (model) {
          final km = model.value ~/ 10;
          emit(state.copyWith(odometer: model.toIntWithStatus(km)));
        });
    });
  }

  static Set<DataSourceParameterId> kDefaultSubscribeParameters = {
    const DataSourceParameterId.motorSpeed(),
    const DataSourceParameterId.odometer(),
    const DataSourceParameterId.gearAndRoll(),
    const DataSourceParameterId.batteryPercent1(),
    const DataSourceParameterId.batteryPercent2(),
    const DataSourceParameterId.batteryPower(),
  };

  @protected
  final DataSource dataSource;
}
