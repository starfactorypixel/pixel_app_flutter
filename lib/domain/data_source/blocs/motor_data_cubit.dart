import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/app/app.dart';
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
      : current = Sequence.fill(motorsCount, const Int16WithStatusBody.zero()),
        voltage = Sequence.fill(motorsCount, const Uint16WithStatusBody.zero()),
        motorTemperature = Sequence.fill(
          motorsCount,
          const Int16WithStatusBody.zero(),
        ),
        controllerTemperature = Sequence.fill(
          motorsCount,
          const Int16WithStatusBody.zero(),
        ),
        gearAndRoll = Sequence.fill(motorsCount, MotorGearAndRoll.unknown()),
        rpm = Sequence.fill(motorsCount, const Uint16WithStatusBody.zero()),
        speed = Sequence.fill(motorsCount, const Uint16WithStatusBody.zero()),
        power = Sequence.fill(motorsCount, const Int16WithStatusBody.zero());

  final Sequence<Int16WithStatusBody> current;
  final Sequence<Uint16WithStatusBody> voltage;
  final Sequence<Int16WithStatusBody> motorTemperature;
  final Sequence<Int16WithStatusBody> controllerTemperature;
  final Sequence<MotorGearAndRoll> gearAndRoll;
  final Sequence<Uint16WithStatusBody> rpm;
  final Sequence<Uint16WithStatusBody> speed;
  final Sequence<Int16WithStatusBody> power;
  final int motorsCount;

  MotorDataState copyWith({
    Sequence<Int16WithStatusBody>? current,
    Sequence<Uint16WithStatusBody>? voltage,
    Sequence<Int16WithStatusBody>? motorTemperature,
    Sequence<Int16WithStatusBody>? controllerTemperature,
    Sequence<MotorGearAndRoll>? gearAndRoll,
    Sequence<Uint16WithStatusBody>? rpm,
    Sequence<Uint16WithStatusBody>? speed,
    Sequence<Int16WithStatusBody>? power,
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
        ..voidOnPackage<Uint16WithStatusBody,
            MotorVoltageIncomingDataSourcePackage>((package) {
          emit(
            state.copyWith(
              voltage: state.voltage.updateAt(
                package.motorIndex,
                package.dataModel,
              ),
            ),
          );
        })
        ..voidOnPackage<Int16WithStatusBody,
            MotorCurrentIncomingDataSourcePackage>((package) {
          emit(
            state.copyWith(
              current: state.current.updateAt(
                package.motorIndex,
                package.dataModel,
              ),
            ),
          );
        })
        ..voidOnPackage<Int16WithStatusBody,
            MotorTemperatureIncomingDataSourcePackage>((package) {
          emit(
            state.copyWith(
              motorTemperature: state.motorTemperature
                  .updateAt(package.motorIndex, package.dataModel),
            ),
          );
        })
        ..voidOnPackage<Int16WithStatusBody,
            ControllerTemperatureIncomingDataSourcePackage>((package) {
          emit(
            state.copyWith(
              controllerTemperature: state.controllerTemperature
                  .updateAt(package.motorIndex, package.dataModel),
            ),
          );
        })
        ..voidOnPackage<MotorGearAndRoll,
            MotorGearAndRollIncomingDataSourcePackage>((package) {
          emit(
            state.copyWith(
              gearAndRoll: state.gearAndRoll.updateAt(
                package.motorIndex,
                package.dataModel,
              ),
            ),
          );
        })
        ..voidOnPackage<Uint16WithStatusBody, RPMIncomingDataSourcePackage>(
            (package) {
          emit(
            state.copyWith(
              rpm: state.rpm.updateAt(
                package.motorIndex,
                package.dataModel,
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
                package.dataModel,
              ),
            ),
          );
        })
        ..voidOnPackage<Int16WithStatusBody,
            MotorPowerIncomingDataSourcePackage>((package) {
          emit(
            state.copyWith(
              power: state.power.updateAt(
                package.motorIndex,
                package.dataModel,
              ),
            ),
          );
        });
    });
  }

  static Set<DataSourceParameterId> kDefaultSubscribeParameters = {
    const DataSourceParameterId.motorVoltage1(),
    const DataSourceParameterId.motorVoltage2(),
    const DataSourceParameterId.motorVoltage3(),
    const DataSourceParameterId.motorVoltage4(),
    const DataSourceParameterId.motorCurrent1(),
    const DataSourceParameterId.motorCurrent2(),
    const DataSourceParameterId.motorCurrent3(),
    const DataSourceParameterId.motorCurrent4(),
    const DataSourceParameterId.rpm1(),
    const DataSourceParameterId.rpm2(),
    const DataSourceParameterId.rpm3(),
    const DataSourceParameterId.rpm4(),
    const DataSourceParameterId.gearAndRoll1(),
    const DataSourceParameterId.gearAndRoll2(),
    const DataSourceParameterId.gearAndRoll3(),
    const DataSourceParameterId.gearAndRoll4(),
    const DataSourceParameterId.motorSpeed1(),
    const DataSourceParameterId.motorSpeed2(),
    const DataSourceParameterId.motorSpeed3(),
    const DataSourceParameterId.motorSpeed4(),
    const DataSourceParameterId.motorPower1(),
    const DataSourceParameterId.motorPower2(),
    const DataSourceParameterId.motorPower3(),
    const DataSourceParameterId.motorPower4(),
    const DataSourceParameterId.motorTemperature1(),
    const DataSourceParameterId.motorTemperature2(),
    const DataSourceParameterId.motorTemperature3(),
    const DataSourceParameterId.motorTemperature4(),
    const DataSourceParameterId.controllerTemperature1(),
    const DataSourceParameterId.controllerTemperature2(),
    const DataSourceParameterId.controllerTemperature3(),
    const DataSourceParameterId.controllerTemperature4(),
  };

  @protected
  final DataSource dataSource;
}
