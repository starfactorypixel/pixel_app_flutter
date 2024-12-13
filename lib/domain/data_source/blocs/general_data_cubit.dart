import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/app/app.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/battery_percent.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/incoming_data_source_packages.dart';
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
    required this.batteryPercent,
    required this.odometer,
    required this.speed,
    required this.gear,
  });

  GeneralDataState.initial({
    required this.hardwareCount,
  })  : power = Sequence.fill(
          hardwareCount.batteries,
          const IntWithStatus.initial(),
        ),
        batteryPercent = Sequence.fill(
          hardwareCount.batteries,
          const IntWithStatus.initial(),
        ),
        odometer = const IntWithStatus.initial(),
        speed = const IntWithStatus.initial(),
        gear = MotorGear.unknown;

  factory GeneralDataState.fromMap(Map<String, dynamic> map) {
    return GeneralDataState(
      hardwareCount: map.parseAndMap('hardwareCount', HardwareCount.fromMap),
      power: Sequence.fromIterable(
        map.tryParseAndMapList('power', IntWithStatus.fromMap),
      ),
      batteryPercent: Sequence.fromIterable(
        map.tryParseAndMapList('batteryPercent', IntWithStatus.fromMap),
      ),
      odometer: map.parseAndMap('odometer', IntWithStatus.fromMap),
      speed: map.parseAndMap('speed', IntWithStatus.fromMap),
      gear: map.parseAndMap('gear', MotorGear.fromId),
    );
  }

  final HardwareCount hardwareCount;
  final Sequence<IntWithStatus> power;
  final IntWithStatus odometer;
  final IntWithStatus speed;
  final MotorGear gear;
  final Sequence<IntWithStatus> batteryPercent;

  IntWithStatus get mergedBatteryPercent {
    if (batteryPercent.length == 1) return batteryPercent.first;
    //
    final (levelSum, status) =
        batteryPercent.fold((0, PeriodicValueStatus.normal), (a, b) {
      return (a.$1 + b.value, a.$2.id > b.status.id ? a.$2 : b.status);
    });
    //
    return IntWithStatus(
      value: levelSum ~/ batteryPercent.length,
      status: status,
    );
  }

  IntWithStatus get mergedPower {
    if (power.length == 1) return power.first;
    //
    final (powerSum, status) = power.fold(
      (0, PeriodicValueStatus.normal),
      (a, b) => (a.$1 + b.value, a.$2.id > b.status.id ? a.$2 : b.status),
    );
    //
    return IntWithStatus(
      value: powerSum ~/ power.length,
      status: status,
    );
  }

  @override
  List<Object?> get props => [
        power,
        batteryPercent,
        odometer,
        speed,
        gear,
      ];

  GeneralDataState copyWith({
    Sequence<IntWithStatus>? power,
    Sequence<IntWithStatus>? batteryPercent,
    IntWithStatus? odometer,
    IntWithStatus? speed,
    MotorGear? gear,
  }) {
    return GeneralDataState(
      hardwareCount: hardwareCount,
      power: power ?? this.power,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      odometer: odometer ?? this.odometer,
      speed: speed ?? this.speed,
      gear: gear ?? this.gear,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hardwareCount': hardwareCount.toMap(),
      'power': power.map((e) => e.toMap()).toList(),
      'batteryPercent': batteryPercent.map((e) => e.toMap()).toList(),
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
              batteryPercent: state.batteryPercent.updateAt(
                package.batteryIndex,
                package.dataModel.toIntWithStatus(),
              ),
            ),
          ),
        )
        ..voidOnPackage<Int16WithStatusBody,
            BatteryPowerIncomingDataSourcePackage>((package) {
          emit(
            state.copyWith(
              power: state.power.updateAt(
                package.batteryIndex,
                package.dataModel.toIntWithStatus(),
              ),
            ),
          );
        })
        ..voidOnModel<MotorGearAndRoll,
            MotorGearAndRollIncomingDataSourcePackage>((model) {
          emit(
            state.copyWith(
              gear: MotorGear.unknown,
            ),
          ); // TODO(alexandr): show something from 4 motors.
        })
        ..voidOnModel<Uint16WithStatusBody,
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
    const DataSourceParameterId.batteryPower1(),
    const DataSourceParameterId.batteryPower2(),
  };

  @protected
  final DataSource dataSource;
}
