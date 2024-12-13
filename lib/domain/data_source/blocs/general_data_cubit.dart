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

  IntWithStatus copyWith({
    int? value,
    PeriodicValueStatus? status,
  }) {
    return IntWithStatus(
      value: value ?? this.value,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'status': status.id,
    };
  }
}

typedef _IntValueModifier = (
  int Function(int a, int b),
  int Function(int foldValue, int length),
);

extension _SequenceExt on Sequence<IntWithStatus> {
  static int avgFold(int a, int b) => a + b;
  static int maxFold(int a, int b) => a > b ? a : b;

  static _IntValueModifier avg =
      (avgFold, (foldValue, length) => foldValue ~/ length);

  IntWithStatus merged([_IntValueModifier? valueModifier]) {
    final modifier = valueModifier ?? avg;
    if (length == 1) {
      return first.copyWith(value: modifier.$2(first.value, 1));
    }

    //
    final (foldValue, status) = fold(
      (0, PeriodicValueStatus.normal),
      (a, b) =>
          (modifier.$1(a.$1, b.value), a.$2.id > b.status.id ? a.$2 : b.status),
    );
    //
    return IntWithStatus(
      value: modifier.$2(foldValue, length),
      status: status,
    );
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
        speed = Sequence.fill(
          hardwareCount.motors,
          const IntWithStatus.initial(),
        ),
        gear = Sequence.fill(
          hardwareCount.motors,
          MotorGear.unknown,
        );

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
      speed: Sequence.fromIterable(
        map.tryParseAndMapList('speed', IntWithStatus.fromMap),
      ),
      gear: Sequence.fromIterable(
        map.tryParseAndMapList('gear', MotorGear.fromId),
      ),
    );
  }

  final HardwareCount hardwareCount;
  final Sequence<IntWithStatus> power;
  final IntWithStatus odometer;
  final Sequence<IntWithStatus> speed;
  final Sequence<MotorGear> gear;
  final Sequence<IntWithStatus> batteryPercent;

  IntWithStatus get mergedBatteryPercent => batteryPercent.merged();

  IntWithStatus get mergedPower => power.merged();

  IntWithStatus get mergedSpeed => speed.merged(
        (
          _SequenceExt.maxFold,
          (foldValue, length) => foldValue ~/ 10,
        ),
      );

  MotorGear get mergedGear {
    if (gear.length == 1) return gear.first;
    if (gear.toSet().length == 1) return gear.first;
    return MotorGear.unknown;
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
    Sequence<IntWithStatus>? speed,
    Sequence<MotorGear>? gear,
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
      'power': [for (final e in power) e.toMap()],
      'batteryPercent': [for (final e in batteryPercent) e.toMap()],
      'odometer': odometer.toMap(),
      'speed': [for (final e in speed) e.toMap()],
      'gear': [for (final e in gear) e.id],
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
        ..voidOnPackage<MotorGearAndRoll,
            MotorGearAndRollIncomingDataSourcePackage>((package) {
          emit(
            state.copyWith(
              gear: state.gear.updateAt(
                package.motorIndex,
                package.dataModel.gear,
              ),
            ),
          );
        })
        ..voidOnPackage<Uint16WithStatusBody,
            MotorSpeedIncomingDataSourcePackage>((package) {
          emit(
            state.copyWith(
              speed: state.speed.updateAt(
                package.motorIndex,
                package.dataModel.toIntWithStatus(),
              ),
            ),
          );
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
