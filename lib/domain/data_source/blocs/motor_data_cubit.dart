import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/incoming_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:re_seedwork/re_seedwork.dart';

@immutable
final class MotorDataState with EquatableMixin {
  const MotorDataState({
    required this.current,
    required this.voltage,
    required this.motorTemperature,
    required this.controllerTemperature,
    required this.gearAndRoll,
    required this.rpm,
    required this.speed,
    required this.power,
    required this.motorsCount,
  });

  MotorDataState.initial({required this.motorsCount})
      : current = const TwoInt16WithStatusBody.zero(),
        voltage = const TwoUint16WithStatusBody.zero(),
        motorTemperature = const TwoInt16WithStatusBody.zero(),
        controllerTemperature = const TwoInt16WithStatusBody.zero(),
        gearAndRoll = MotorGearAndRoll.unknown(),
        rpm = const TwoUint16WithStatusBody.zero(),
        speed = const TwoUint16WithStatusBody.zero(),
        power = const TwoInt16WithStatusBody.zero();

  final TwoInt16WithStatusBody current;
  final TwoUint16WithStatusBody voltage;
  final TwoInt16WithStatusBody motorTemperature;
  final TwoInt16WithStatusBody controllerTemperature;
  final MotorGearAndRoll gearAndRoll;
  final TwoUint16WithStatusBody rpm;
  final TwoUint16WithStatusBody speed;
  final TwoInt16WithStatusBody power;
  final int motorsCount;

  MotorDataState copyWith({
    TwoInt16WithStatusBody? current,
    TwoUint16WithStatusBody? voltage,
    TwoInt16WithStatusBody? motorTemperature,
    TwoInt16WithStatusBody? controllerTemperature,
    MotorGearAndRoll? gearAndRoll,
    TwoUint16WithStatusBody? rpm,
    TwoUint16WithStatusBody? speed,
    TwoInt16WithStatusBody? power,
    int? motorsCount,
  }) {
    return MotorDataState(
      current: current ?? this.current,
      voltage: voltage ?? this.voltage,
      motorTemperature: motorTemperature ?? this.motorTemperature,
      controllerTemperature:
          controllerTemperature ?? this.controllerTemperature,
      gearAndRoll: gearAndRoll ?? this.gearAndRoll,
      rpm: rpm ?? this.rpm,
      speed: speed ?? this.speed,
      power: power ?? this.power,
      motorsCount: motorsCount ?? this.motorsCount,
    );
  }

  @override
  List<Object?> get props => [
        current,
        voltage,
        motorTemperature,
        controllerTemperature,
        gearAndRoll,
        rpm,
        speed,
        power,
        motorsCount,
      ];
}

class MotorDataCubit extends Cubit<MotorDataState> with ConsumerBlocMixin {
  MotorDataCubit({
    required this.dataSource,
    required int motorsCount,
  }) : super(MotorDataState.initial(motorsCount: motorsCount)) {
    subscribe<DataSourceIncomingPackage>(dataSource.packageStream, (value) {
      value
        ..voidOnModel<TwoUint16WithStatusBody,
            MotorVoltageIncomingDataSourcePackage>((model) {
          emit(state.copyWith(voltage: model));
        })
        ..voidOnModel<TwoInt16WithStatusBody,
            MotorCurrentIncomingDataSourcePackage>((model) {
          emit(state.copyWith(current: model));
        })
        ..voidOnModel<TwoInt16WithStatusBody,
            MotorTemperatureIncomingDataSourcePackage>((model) {
          emit(state.copyWith(motorTemperature: model));
        })
        ..voidOnModel<TwoInt16WithStatusBody,
            ControllerTemperatureIncomingDataSourcePackage>((model) {
          emit(state.copyWith(controllerTemperature: model));
        })
        ..voidOnModel<MotorGearAndRoll,
            MotorGearAndRollIncomingDataSourcePackage>((model) {
          emit(state.copyWith(gearAndRoll: model));
        })
        ..voidOnModel<TwoUint16WithStatusBody, RPMIncomingDataSourcePackage>(
            (model) {
          emit(state.copyWith(rpm: model));
        })
        ..voidOnModel<TwoUint16WithStatusBody,
            MotorSpeedIncomingDataSourcePackage>((model) {
          emit(state.copyWith(speed: model));
        })
        ..voidOnModel<TwoInt16WithStatusBody,
            MotorPowerIncomingDataSourcePackage>((model) {
          emit(state.copyWith(power: model));
        });
    });
  }

  static Set<DataSourceParameterId> kDefaultSubscribeParameters = {
    const DataSourceParameterId.motorVoltage(),
    const DataSourceParameterId.motorCurrent(),
    const DataSourceParameterId.rpm(),
    const DataSourceParameterId.gearAndRoll(),
    const DataSourceParameterId.motorSpeed(),
    const DataSourceParameterId.motorPower(),
    const DataSourceParameterId.motorTemperature(),
    const DataSourceParameterId.controllerTemperature(),
  };

  @protected
  final DataSource dataSource;
}
