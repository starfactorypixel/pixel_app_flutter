import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/app/app.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/incoming_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/outgoing/outgoing_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:re_seedwork/re_seedwork.dart';

@sealed
@immutable
class BatteryDataState with EquatableMixin {
  const BatteryDataState({
    required this.batteriesCount,
    required this.cellsCount,
    required this.temperatureSensorsCount,
    required this.maxTemperature,
    required this.highCurrent,
    required this.highVoltage,
    required this.lowVoltageMinMaxDelta,
    required this.temperature,
    required this.batteryLowVoltage,
  });

  BatteryDataState.initial({
    required this.batteriesCount,
    required this.cellsCount,
    required this.temperatureSensorsCount,
  })  : maxTemperature = Sequence.fill(
          batteriesCount,
          const MaxTemperature.zero(),
        ),
        highCurrent = Sequence<HighCurrent>.fill(
          batteriesCount,
          const HighCurrent.zero(),
        ),
        highVoltage = Sequence<HighVoltage>.fill(
          batteriesCount,
          const HighVoltage.zero(),
        ),
        lowVoltageMinMaxDelta = Sequence.fill(
          batteriesCount,
          const LowVoltageMinMaxDelta.zero(),
        ),
        temperature = Sequence.fill(
          batteriesCount,
          Sequence.fillBuilder(
            temperatureSensorsCount,
            (index) => BatteryTemperature.zero(no: index + 1),
          ),
        ),
        batteryLowVoltage = Sequence.fill(
          batteriesCount,
          Sequence.fill(cellsCount, 0),
        );

  final int batteriesCount;
  final int cellsCount;
  final int temperatureSensorsCount;

  final Sequence<MaxTemperature> maxTemperature;
  final Sequence<HighCurrent> highCurrent;
  final Sequence<HighVoltage> highVoltage;
  final Sequence<LowVoltageMinMaxDelta> lowVoltageMinMaxDelta;

  //
  final Sequence<Sequence<BatteryTemperature>> temperature;

  //
  final Sequence<Sequence<double>> batteryLowVoltage;

  BatteryDataState copyWith({
    Sequence<MaxTemperature>? maxTemperature,
    Sequence<HighCurrent>? highCurrent,
    Sequence<HighVoltage>? highVoltage,
    Sequence<LowVoltageMinMaxDelta>? lowVoltageMinMaxDelta,
    Sequence<Sequence<BatteryTemperature>>? temperature,
    Sequence<Sequence<double>>? batteryLowVoltage,
  }) {
    return BatteryDataState(
      batteriesCount: batteriesCount,
      cellsCount: cellsCount,
      temperatureSensorsCount: temperatureSensorsCount,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      highCurrent: highCurrent ?? this.highCurrent,
      highVoltage: highVoltage ?? this.highVoltage,
      lowVoltageMinMaxDelta:
          lowVoltageMinMaxDelta ?? this.lowVoltageMinMaxDelta,
      temperature: temperature ?? this.temperature,
      batteryLowVoltage: batteryLowVoltage ?? this.batteryLowVoltage,
    );
  }

  @override
  List<Object?> get props => [
        maxTemperature,
        highCurrent,
        highVoltage,
        lowVoltageMinMaxDelta,
        temperature,
        batteryLowVoltage,
      ];
}

class BatteryDataCubit extends Cubit<BatteryDataState>
    with
        ConsumerBlocMixin,
        BlocLoggerMixin<DataSourcePackage, BatteryDataState> {
  BatteryDataCubit({
    required this.dataSource,
    required int batteriesCount,
    required int cellsCount,
    required int temperatureSensorsCount,
    this.temperatureUpdateDuration = kDefaultTemperatureUpdateDuration,
    this.voltageUpdateDuration = kDefaultVoltageUpdateDuration,
    this.temperatureParametersId = kDefaultTemperatureParameterIds,
    this.voltageParametersId = kDefaultVoltageParameterIds,
  }) : super(
          BatteryDataState.initial(
            batteriesCount: batteriesCount,
            cellsCount: cellsCount,
            temperatureSensorsCount: temperatureSensorsCount,
          ),
        ) {
    subscribe<DataSourceIncomingPackage>(dataSource.packageStream, (value) {
      value
        ..voidOnPackage<HighCurrent, HighCurrentIncomingDataSourcePackage>(
          (package) => emit(
            state.copyWith(
              highCurrent: state.highCurrent.updateAt(
                package.batteryIndex,
                package.dataModel,
              ),
            ),
          ),
        )
        ..voidOnPackage<HighVoltage, HighVoltageIncomingDataSourcePackage>(
          (package) => emit(
            state.copyWith(
              highVoltage: state.highVoltage.updateAt(
                package.batteryIndex,
                package.dataModel,
              ),
            ),
          ),
        )
        ..voidOnPackage<LowVoltageMinMaxDelta,
            LowVoltageMinMaxDeltaIncomingDataSourcePackage>(
          (package) => emit(
            state.copyWith(
              lowVoltageMinMaxDelta: state.lowVoltageMinMaxDelta.updateAt(
                package.batteryIndex,
                package.dataModel,
              ),
            ),
          ),
        )
        ..voidOnPackage<MaxTemperature,
            MaxTemperatureIncomingDataSourcePackage>(
          (package) => emit(
            state.copyWith(
              maxTemperature: state.maxTemperature.updateAt(
                package.batteryIndex,
                package.dataModel,
              ),
            ),
          ),
        )
        ..voidOnPackage<BatteryTemperature,
            BatteryTemperatureIncomingDataSourcePackage>(
          (package) {
            final temperatures = state.temperature.getAt(package.batteryIndex);
            if (temperatures == null) return;
            // no 0 is reserved
            if (package.dataModel.no == 0) return;
            emit(
              state.copyWith(
                temperature: state.temperature.updateAt(
                  package.batteryIndex,
                  temperatures.updateAt(
                    package.dataModel.no - 1,
                    package.dataModel,
                  ),
                ),
              ),
            );
          },
        )
        ..voidOnPackage<BatteryLowVoltage,
            BatteryLowVoltageIncomingDataSourcePackage>(
          (package) {
            final voltages =
                state.batteryLowVoltage.getAt(package.batteryIndex);
            if (voltages == null) return;
            // no 0 is reserved
            if (package.dataModel.no == 0) return;
            emit(
              state.copyWith(
                batteryLowVoltage: state.batteryLowVoltage.updateAt(
                  package.batteryIndex,
                  voltages.updateAt(
                    package.dataModel.no - 1,
                    package.dataModel.value,
                  ),
                ),
              ),
            );
          },
        );
    });
  }

  static Set<DataSourceParameterId> kDefaultSubscribeParameters = {
    const DataSourceParameterId.highCurrent1(),
    const DataSourceParameterId.highCurrent2(),
    const DataSourceParameterId.highVoltage1(),
    const DataSourceParameterId.highVoltage2(),
    const DataSourceParameterId.maxTemperature1(),
    const DataSourceParameterId.maxTemperature2(),
  };

  static const kDefaultTemperatureUpdateDuration = Duration(seconds: 3);
  static const kDefaultVoltageUpdateDuration = Duration(seconds: 3);

  @protected
  final DataSource dataSource;

  @protected
  final Duration temperatureUpdateDuration;

  @protected
  final Duration voltageUpdateDuration;

  @protected
  final List<DataSourceParameterId> temperatureParametersId;

  @protected
  final List<DataSourceParameterId> voltageParametersId;

  @visibleForTesting
  static const kDefaultVoltageParameterIds = [
    DataSourceParameterId.lowVoltageMinMaxDelta1(),
    DataSourceParameterId.lowVoltageMinMaxDelta2(),
    DataSourceParameterId.lowVoltage1(),
    DataSourceParameterId.lowVoltage2(),
  ];

  @visibleForTesting
  static const kDefaultTemperatureParameterIds = [
    DataSourceParameterId.temperature1(),
    DataSourceParameterId.temperature2(),
  ];

  @visibleForTesting
  Timer? temperatureTimer;

  @visibleForTesting
  Timer? voltageTimer;

  void startUpdatingTemperature() {
    cancelUpdatingTemperature();
    _sendValueRequestPackages(temperatureParametersId);
    temperatureTimer = Timer.periodic(temperatureUpdateDuration, (timer) {
      _sendValueRequestPackages(temperatureParametersId);
    });
  }

  void startUpdatingVoltage() {
    cancelUpdatingVoltage();
    _sendValueRequestPackages(voltageParametersId);
    voltageTimer = Timer.periodic(voltageUpdateDuration, (timer) {
      _sendValueRequestPackages(voltageParametersId);
    });
  }

  void cancelUpdatingTemperature() {
    temperatureTimer?.cancel();
    temperatureTimer = null;
  }

  void cancelUpdatingVoltage() {
    voltageTimer?.cancel();
    voltageTimer = null;
  }

  void _sendValueRequestPackages(List<DataSourceParameterId> ids) {
    for (final id in ids) {
      final package = OutgoingValueRequestPackage(parameterId: id);
      dataSource.sendPackage(package);
    }
  }

  @override
  Future<void> close() {
    cancelUpdatingTemperature();
    return super.close();
  }
}
