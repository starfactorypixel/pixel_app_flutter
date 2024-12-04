import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/incoming_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/outgoing/outgoing_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:re_seedwork/re_seedwork.dart';

@sealed
@immutable
class BatteryDataState with EquatableMixin {
  const BatteryDataState({
    required this.maxTemperature,
    required this.highCurrent1,
    required this.highCurrent2,
    required this.highVoltage,
    required this.lowVoltageMinMaxDelta,
    required this.temperatureFirstBatch,
    required this.temperatureSecondBatch,
    required this.temperatureThirdBatch,
    required this.lowVoltageOneToThree,
    required this.lowVoltageFourToSix,
    required this.lowVoltageSevenToNine,
    required this.lowVoltageTenToTwelve,
    required this.lowVoltageThirteenToFifteen,
    required this.lowVoltageSixteenToEighteen,
    required this.lowVoltageNineteenToTwentyOne,
    required this.lowVoltageTwentyTwoToTwentyFour,
    required this.lowVoltageTwentyFiveToTwentySeven,
    required this.lowVoltageTwentyEightToThirty,
    required this.lowVoltageThirtyOneToThirtyThree,
  });

  const BatteryDataState.initial()
      : maxTemperature = const MaxTemperature.zero(),
        highCurrent1 = const HighCurrent.zero(),
        highCurrent2 = const HighCurrent.zero(),
        highVoltage = const HighVoltage.zero(),
        lowVoltageMinMaxDelta = const LowVoltageMinMaxDelta.zero(),
        temperatureFirstBatch = const BatteryTemperatureFirstBatch.zero(),
        temperatureSecondBatch = const BatteryTemperatureSecondBatch.zero(),
        temperatureThirdBatch = const BatteryTemperatureThirdBatch.zero(),
        lowVoltageOneToThree = const BatteryLowVoltageOneToThree.zero(),
        lowVoltageFourToSix = const BatteryLowVoltageFourToSix.zero(),
        lowVoltageSevenToNine = const BatteryLowVoltageSevenToNine.zero(),
        lowVoltageTenToTwelve = const BatteryLowVoltageTenToTwelve.zero(),
        lowVoltageThirteenToFifteen =
            const BatteryLowVoltageThirteenToFifteen.zero(),
        lowVoltageSixteenToEighteen =
            const BatteryLowVoltageSixteenToEighteen.zero(),
        lowVoltageNineteenToTwentyOne =
            const BatteryLowVoltageNineteenToTwentyOne.zero(),
        lowVoltageTwentyTwoToTwentyFour =
            const BatteryLowVoltageTwentyTwoToTwentyFour.zero(),
        lowVoltageTwentyFiveToTwentySeven =
            const BatteryLowVoltageTwentyFiveToTwentySeven.zero(),
        lowVoltageTwentyEightToThirty =
            const BatteryLowVoltageTwentyEightToThirty.zero(),
        lowVoltageThirtyOneToThirtyThree =
            const BatteryLowVoltageThirtyOneToThirtyThree.zero();

  final MaxTemperature maxTemperature;
  final HighCurrent highCurrent1;
  final HighCurrent highCurrent2;
  final HighVoltage highVoltage;
  final LowVoltageMinMaxDelta lowVoltageMinMaxDelta;

  //
  final BatteryTemperatureFirstBatch temperatureFirstBatch;
  final BatteryTemperatureSecondBatch temperatureSecondBatch;
  final BatteryTemperatureThirdBatch temperatureThirdBatch;

  //
  final BatteryLowVoltageOneToThree lowVoltageOneToThree;
  final BatteryLowVoltageFourToSix lowVoltageFourToSix;
  final BatteryLowVoltageSevenToNine lowVoltageSevenToNine;
  final BatteryLowVoltageTenToTwelve lowVoltageTenToTwelve;
  final BatteryLowVoltageThirteenToFifteen lowVoltageThirteenToFifteen;
  final BatteryLowVoltageSixteenToEighteen lowVoltageSixteenToEighteen;
  final BatteryLowVoltageNineteenToTwentyOne lowVoltageNineteenToTwentyOne;
  final BatteryLowVoltageTwentyTwoToTwentyFour lowVoltageTwentyTwoToTwentyFour;
  final BatteryLowVoltageTwentyFiveToTwentySeven
      lowVoltageTwentyFiveToTwentySeven;
  final BatteryLowVoltageTwentyEightToThirty lowVoltageTwentyEightToThirty;
  final BatteryLowVoltageThirtyOneToThirtyThree
      lowVoltageThirtyOneToThirtyThree;

  BatteryDataState copyWith({
    MaxTemperature? maxTemperature,
    HighCurrent? highCurrent1,
    HighCurrent? highCurrent2,
    HighVoltage? highVoltage,
    LowVoltageMinMaxDelta? lowVoltageMinMaxDelta,
    BatteryTemperatureFirstBatch? temperatureFirstBatch,
    BatteryTemperatureSecondBatch? temperatureSecondBatch,
    BatteryTemperatureThirdBatch? temperatureThirdBatch,
    BatteryLowVoltageOneToThree? lowVoltageOneToThree,
    BatteryLowVoltageFourToSix? lowVoltageFourToSix,
    BatteryLowVoltageSevenToNine? lowVoltageSevenToNine,
    BatteryLowVoltageTenToTwelve? lowVoltageTenToTwelve,
    BatteryLowVoltageThirteenToFifteen? lowVoltageThirteenToFifteen,
    BatteryLowVoltageSixteenToEighteen? lowVoltageSixteenToEighteen,
    BatteryLowVoltageNineteenToTwentyOne? lowVoltageNineteenToTwentyOne,
    BatteryLowVoltageTwentyTwoToTwentyFour? lowVoltageTwentyTwoToTwentyFour,
    BatteryLowVoltageTwentyFiveToTwentySeven? lowVoltageTwentyFiveToTwentySeven,
    BatteryLowVoltageTwentyEightToThirty? lowVoltageTwentyEightToThirty,
    BatteryLowVoltageThirtyOneToThirtyThree? lowVoltageThirtyOneToThirtyThree,
  }) {
    return BatteryDataState(
      maxTemperature: maxTemperature ?? this.maxTemperature,
      highCurrent1: highCurrent1 ?? this.highCurrent1,
      highCurrent2: highCurrent2 ?? this.highCurrent2,
      highVoltage: highVoltage ?? this.highVoltage,
      lowVoltageMinMaxDelta:
          lowVoltageMinMaxDelta ?? this.lowVoltageMinMaxDelta,
      temperatureFirstBatch:
          temperatureFirstBatch ?? this.temperatureFirstBatch,
      temperatureSecondBatch:
          temperatureSecondBatch ?? this.temperatureSecondBatch,
      temperatureThirdBatch:
          temperatureThirdBatch ?? this.temperatureThirdBatch,
      lowVoltageOneToThree: lowVoltageOneToThree ?? this.lowVoltageOneToThree,
      lowVoltageFourToSix: lowVoltageFourToSix ?? this.lowVoltageFourToSix,
      lowVoltageSevenToNine:
          lowVoltageSevenToNine ?? this.lowVoltageSevenToNine,
      lowVoltageTenToTwelve:
          lowVoltageTenToTwelve ?? this.lowVoltageTenToTwelve,
      lowVoltageThirteenToFifteen:
          lowVoltageThirteenToFifteen ?? this.lowVoltageThirteenToFifteen,
      lowVoltageSixteenToEighteen:
          lowVoltageSixteenToEighteen ?? this.lowVoltageSixteenToEighteen,
      lowVoltageNineteenToTwentyOne:
          lowVoltageNineteenToTwentyOne ?? this.lowVoltageNineteenToTwentyOne,
      lowVoltageTwentyTwoToTwentyFour: lowVoltageTwentyTwoToTwentyFour ??
          this.lowVoltageTwentyTwoToTwentyFour,
      lowVoltageTwentyFiveToTwentySeven: lowVoltageTwentyFiveToTwentySeven ??
          this.lowVoltageTwentyFiveToTwentySeven,
      lowVoltageTwentyEightToThirty:
          lowVoltageTwentyEightToThirty ?? this.lowVoltageTwentyEightToThirty,
      lowVoltageThirtyOneToThirtyThree: lowVoltageThirtyOneToThirtyThree ??
          this.lowVoltageThirtyOneToThirtyThree,
    );
  }

  @override
  List<Object?> get props => [
        maxTemperature,
        highCurrent1,
        highCurrent2,
        highVoltage,
        lowVoltageMinMaxDelta,
        temperatureFirstBatch,
        temperatureSecondBatch,
        temperatureThirdBatch,
        lowVoltageOneToThree,
        lowVoltageFourToSix,
        lowVoltageSevenToNine,
        lowVoltageTenToTwelve,
        lowVoltageThirteenToFifteen,
        lowVoltageSixteenToEighteen,
        lowVoltageNineteenToTwentyOne,
        lowVoltageTwentyTwoToTwentyFour,
        lowVoltageTwentyFiveToTwentySeven,
        lowVoltageTwentyEightToThirty,
        lowVoltageThirtyOneToThirtyThree,
      ];
}

class BatteryDataCubit extends Cubit<BatteryDataState>
    with
        ConsumerBlocMixin,
        BlocLoggerMixin<DataSourcePackage, BatteryDataState> {
  BatteryDataCubit({
    required this.dataSource,
    this.temperatureUpdateDuration = kDefaultTemperatureUpdateDuration,
    this.voltageUpdateDuration = kDefaultVoltageUpdateDuration,
    this.temperatureParametersId = kDefaultTemperatureParameterIds,
    this.voltageParametersId = kDefaultVoltageParameterIds,
  }) : super(const BatteryDataState.initial()) {
    subscribe<DataSourceIncomingPackage>(dataSource.packageStream, (value) {
      value
        ..voidOnModel<HighCurrent, HighCurrent1IncomingDataSourcePackage>(
          (model) => emit(state.copyWith(highCurrent1: model)),
        )
        ..voidOnModel<HighCurrent, HighCurrent2IncomingDataSourcePackage>(
          (model) => emit(state.copyWith(highCurrent2: model)),
        )
        ..voidOnModel<HighVoltage, HighVoltageIncomingDataSourcePackage>(
          (model) => emit(state.copyWith(highVoltage: model)),
        )
        ..voidOnModel<MaxTemperature, MaxTemperatureIncomingDataSourcePackage>(
          (model) => emit(state.copyWith(maxTemperature: model)),
        )
        ..voidOnModel<BatteryTemperatureFirstBatch,
            BatteryTemperatureFirstBatchIncomingDataSourcePackage>(
          (model) => emit(
            state.copyWith(temperatureFirstBatch: model),
          ),
        )
        ..voidOnModel<BatteryTemperatureSecondBatch,
            BatteryTemperatureSecondBatchIncomingDataSourcePackage>(
          (model) => emit(
            state.copyWith(temperatureSecondBatch: model),
          ),
        )
        ..voidOnModel<BatteryTemperatureThirdBatch,
            BatteryTemperatureThirdBatchIncomingDataSourcePackage>(
          (model) => emit(
            state.copyWith(temperatureThirdBatch: model),
          ),
        )
        ..voidOnModel<BatteryLowVoltageOneToThree,
            BatteryLowVoltageOneToThreeIncomingDataSourcePackage>(
          (model) => emit(
            state.copyWith(lowVoltageOneToThree: model),
          ),
        )
        ..voidOnModel<BatteryLowVoltageFourToSix,
            BatteryLowVoltageFourToSixIncomingDataSourcePackage>(
          (model) => emit(
            state.copyWith(lowVoltageFourToSix: model),
          ),
        )
        ..voidOnModel<LowVoltageMinMaxDelta,
            LowVoltageMinMaxDeltaIncomingDataSourcePackage>(
          (model) => emit(
            state.copyWith(lowVoltageMinMaxDelta: model),
          ),
        )
        ..voidOnModel<BatteryLowVoltageSevenToNine,
            BatteryLowVoltageSevenToNineIncomingDataSourcePackage>(
          (model) => emit(
            state.copyWith(lowVoltageSevenToNine: model),
          ),
        )
        ..voidOnModel<BatteryLowVoltageTenToTwelve,
            BatteryLowVoltageTenToTwelveIncomingDataSourcePackage>(
          (model) => emit(
            state.copyWith(lowVoltageTenToTwelve: model),
          ),
        )
        ..voidOnModel<BatteryLowVoltageThirteenToFifteen,
            BatteryLowVoltageThirteenToFifteenIncomingDataSourcePackage>(
          (model) => emit(
            state.copyWith(lowVoltageThirteenToFifteen: model),
          ),
        )
        ..voidOnModel<BatteryLowVoltageSixteenToEighteen,
            BatteryLowVoltageSixteenToEighteenIncomingDataSourcePackage>(
          (model) => emit(
            state.copyWith(lowVoltageSixteenToEighteen: model),
          ),
        )
        ..voidOnModel<BatteryLowVoltageNineteenToTwentyOne,
            BatteryLowVoltageNineteenToTwentyOneIncomingDataSourcePackage>(
          (model) => emit(
            state.copyWith(lowVoltageNineteenToTwentyOne: model),
          ),
        )
        ..voidOnModel<BatteryLowVoltageTwentyTwoToTwentyFour,
            BatteryLowVoltageTwentyTwoToTwentyFourIncomingDataSourcePackage>(
          (model) => emit(
            state.copyWith(lowVoltageTwentyTwoToTwentyFour: model),
          ),
        )
        ..voidOnModel<BatteryLowVoltageTwentyFiveToTwentySeven,
            BatteryLowVoltageTwentyFiveToTwentySevenIncomingDataSourcePackage>(
          (model) => emit(
            state.copyWith(lowVoltageTwentyFiveToTwentySeven: model),
          ),
        )
        ..voidOnModel<BatteryLowVoltageTwentyEightToThirty,
            BatteryLowVoltageTwentyEightToThirtyIncomingDataSourcePackage>(
          (model) => emit(
            state.copyWith(lowVoltageTwentyEightToThirty: model),
          ),
        )
        ..voidOnModel<BatteryLowVoltageThirtyOneToThirtyThree,
            BatteryLowVoltageThirtyOneToThirtyThreeIncomingDataSourcePackage>(
          (model) => emit(
            state.copyWith(lowVoltageThirtyOneToThirtyThree: model),
          ),
        );
    });
  }

  static Set<DataSourceParameterId> kDefaultSubscribeParameters = {
    const DataSourceParameterId.highCurrent1(),
    const DataSourceParameterId.highCurrent2(),
    const DataSourceParameterId.highVoltage(),
    const DataSourceParameterId.maxTemperature(),
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
    DataSourceParameterId.lowVoltageMinMaxDelta(),
    DataSourceParameterId.lowVoltageOneToThree(),
    DataSourceParameterId.lowVoltageFourToSix(),
    DataSourceParameterId.lowVoltageSevenToNine(),
    DataSourceParameterId.lowVoltageTenToTwelve(),
    DataSourceParameterId.lowVoltageThirteenToFifteen(),
    DataSourceParameterId.lowVoltageSixteenToEighteen(),
    DataSourceParameterId.lowVoltageNineteenToTwentyOne(),
    DataSourceParameterId.lowVoltageTwentyTwoToTwentyFour(),
    DataSourceParameterId.lowVoltageTwentyFiveToTwentySeven(),
    DataSourceParameterId.lowVoltageTwentyEightToThirty(),
    DataSourceParameterId.lowVoltageThirtyOneToThirtyThree(),
  ];

  @visibleForTesting
  static const kDefaultTemperatureParameterIds = [
    DataSourceParameterId.temperatureFirstBatch(),
    DataSourceParameterId.temperatureSecondBatch(),
    DataSourceParameterId.temperatureThirdBatch(),
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
