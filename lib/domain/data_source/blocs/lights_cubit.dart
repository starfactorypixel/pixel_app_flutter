import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/incoming_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/outgoing/outgoing_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:re_seedwork/re_seedwork.dart';

typedef LightState<T> = AsyncData<T, ToggleStateError>;

@sealed
@immutable
class TwoBoolsState {
  const TwoBoolsState({
    required this.first,
    required this.second,
    required this.waitingForSwitch,
  });

  const TwoBoolsState.on()
      : first = true,
        second = true,
        waitingForSwitch = null;

  const TwoBoolsState.off()
      : first = false,
        second = false,
        waitingForSwitch = null;

  final bool first;
  final bool second;
  final bool? waitingForSwitch;

  bool get isOn => first || second;
  bool get isOff => !first && !second;
  bool get differs => first != second;
  bool get bothOn => first && second;

  int get oppositeValue => (!(differs || isOn)).toInt;
  bool get oppositeBool => !differs && !isOn;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TwoBoolsState &&
        other.first == first &&
        other.second == second &&
        other.waitingForSwitch == waitingForSwitch;
  }

  @override
  int get hashCode =>
      first.hashCode ^ second.hashCode ^ waitingForSwitch.hashCode;

  TwoBoolsState copyWith({
    bool? first,
    bool? second,
    bool? waitingForSwitch,
    bool setWaitingForSwitchToNull = false,
  }) {
    return TwoBoolsState(
      first: first ?? this.first,
      second: second ?? this.second,
      waitingForSwitch: setWaitingForSwitchToNull
          ? null
          : waitingForSwitch ?? this.waitingForSwitch,
    );
  }

  @override
  String toString() => 'TwoBoolsState(first: $first, '
      'second: $second, '
      'waitingForSwitch: $waitingForSwitch)';
}

@immutable
final class LightsState with EquatableMixin {
  const LightsState({
    required this.leftTurnSignal,
    required this.rightTurnSignal,
    required this.hazardBeam,
    required this.sideBeam,
    required this.lowBeam,
    required this.highBeam,
    required this.reverse,
    required this.brake,
    required this.cabin,
  });

  const LightsState.initial({
    this.leftTurnSignal = const AsyncData.loading(TwoBoolsState.off()),
    this.rightTurnSignal = const AsyncData.loading(TwoBoolsState.off()),
    this.hazardBeam = const AsyncData.loading(TwoBoolsState.off()),
    this.sideBeam = const AsyncData.loading(TwoBoolsState.off()),
    this.lowBeam = const AsyncData.loading(false),
    this.highBeam = const AsyncData.loading(false),
    this.reverse = const AsyncData.loading(false),
    this.brake = const AsyncData.loading(false),
    this.cabin = const AsyncData.loading(false),
  });

  final LightState<TwoBoolsState> leftTurnSignal;
  final LightState<TwoBoolsState> rightTurnSignal;
  final LightState<TwoBoolsState> hazardBeam;
  final LightState<TwoBoolsState> sideBeam;
  final LightState<bool> lowBeam;
  final LightState<bool> highBeam;
  final LightState<bool> reverse;
  final LightState<bool> brake;
  final LightState<bool> cabin;

  bool get hasFailureState => [
        leftTurnSignal,
        rightTurnSignal,
        hazardBeam,
        sideBeam,
        lowBeam,
        highBeam,
        reverse,
        brake,
        cabin,
      ].any((element) => element.isFailure);

  List<R> whenFailure<R>(
    LightsState prevState, {
    required R Function(ToggleStateError error) leftTurnSignal,
    required R Function(ToggleStateError error) rightTurnSignal,
    required R Function(ToggleStateError error) hazardBeam,
    required R Function(ToggleStateError error) sideBeam,
    required R Function(ToggleStateError error) lowBeam,
    required R Function(ToggleStateError error) highBeam,
    required R Function(ToggleStateError error) reverse,
    required R Function(ToggleStateError error) brake,
    required R Function(ToggleStateError error) cabin,
  }) {
    final leftTurnSignalError = this.leftTurnSignal.error;
    final rightTurnSignalError = this.rightTurnSignal.error;
    final hazardBeamError = this.hazardBeam.error;
    final lowBeamError = this.lowBeam.error;
    final highBeamError = this.highBeam.error;
    final sideBeamError = this.sideBeam.error;
    final reverseError = this.reverse.error;
    final brakeError = this.brake.error;
    final cabinError = this.cabin.error;

    final errors = [
      _filterError(
        leftTurnSignalError,
        prevState.leftTurnSignal.error,
        leftTurnSignal,
      ),
      _filterError(
        rightTurnSignalError,
        prevState.rightTurnSignal.error,
        rightTurnSignal,
      ),
      _filterError(
        hazardBeamError,
        prevState.hazardBeam.error,
        hazardBeam,
      ),
      _filterError(
        sideBeamError,
        prevState.sideBeam.error,
        sideBeam,
      ),
      _filterError(
        lowBeamError,
        prevState.lowBeam.error,
        lowBeam,
      ),
      _filterError(
        highBeamError,
        prevState.highBeam.error,
        highBeam,
      ),
      _filterError(
        reverseError,
        prevState.reverse.error,
        reverse,
      ),
      _filterError(
        brakeError,
        prevState.brake.error,
        brake,
      ),
      _filterError(
        cabinError,
        prevState.cabin.error,
        cabin,
      ),
    ].whereType<R>().toList();

    return errors;
  }

  R? _filterError<R>(
    ToggleStateError? current,
    ToggleStateError? prev,
    R Function(ToggleStateError) callback,
  ) {
    if (current == null) return null;
    if (current.isTimeout && prev != null && !prev.isTimeout) return null;
    if (current == prev) return null;
    return callback(current);
  }

  @override
  List<Object?> get props => [
        leftTurnSignal,
        rightTurnSignal,
        hazardBeam,
        sideBeam,
        lowBeam,
        highBeam,
        reverse,
        brake,
        cabin,
      ];

  LightsState copyWith({
    LightState<TwoBoolsState>? leftTurnSignal,
    LightState<TwoBoolsState>? rightTurnSignal,
    LightState<TwoBoolsState>? hazardBeam,
    LightState<TwoBoolsState>? sideBeam,
    LightState<bool>? lowBeam,
    LightState<bool>? highBeam,
    LightState<bool>? reverse,
    LightState<bool>? brake,
    LightState<bool>? cabin,
  }) {
    return LightsState(
      leftTurnSignal: leftTurnSignal ?? this.leftTurnSignal,
      rightTurnSignal: rightTurnSignal ?? this.rightTurnSignal,
      hazardBeam: hazardBeam ?? this.hazardBeam,
      sideBeam: sideBeam ?? this.sideBeam,
      lowBeam: lowBeam ?? this.lowBeam,
      highBeam: highBeam ?? this.highBeam,
      reverse: reverse ?? this.reverse,
      brake: brake ?? this.brake,
      cabin: cabin ?? this.cabin,
    );
  }
}

extension _ErrorExtension<V, E extends Object> on AsyncData<V, E> {
  E? get error => maybeWhen(
        orElse: (_) => null,
        failure: (payload, error) => error,
      );
}

class LightsCubit extends Cubit<LightsState> with ConsumerBlocMixin {
  LightsCubit({
    required this.dataSource,
    this.toggleTimeout = kToggleTimeout,
    this.subscriptionTimeout = kSubscriptionTimeout,
  }) : super(const LightsState.initial()) {
    subscribe<DataSourceIncomingPackage>(dataSource.packageStream, (package) {
      package
        // SideBeam
        ..voidOnModel<SuccessEventUint8Body,
            FrontSideBeamSetIncomingDataSourcePackage>((model) {
          _onNewSideBeam(value: model.value);
        })
        ..voidOnModel<SuccessEventUint8Body,
            TailSideBeamSetIncomingDataSourcePackage>((model) {
          _onNewSideBeam(
            value: model.value,
            front: false,
          );
        })

        // LowBeam
        ..voidOnModel<SuccessEventUint8Body,
            LowBeamSetIncomingDataSourcePackage>((model) {
          emit(state.copyWith(lowBeam: AsyncData.success(model.value.toBool)));
        })
        // HighBeam
        ..voidOnModel<SuccessEventUint8Body,
            HighBeamSetIncomingDataSourcePackage>((model) {
          emit(state.copyWith(highBeam: AsyncData.success(model.value.toBool)));
        })
        // HazardBeam
        ..voidOnModel<SuccessEventUint8Body,
            FrontHazardBeamSetIncomingDataSourcePackage>((model) {
          _onNewHazardState(value: model.value);
        })
        ..voidOnModel<SuccessEventUint8Body,
            TailHazardBeamSetIncomingDataSourcePackage>((model) {
          _onNewHazardState(
            value: model.value,
            front: false,
          );
        })
        // TurnSignal
        ..voidOnModel<SuccessEventUint8Body,
            FrontLeftTurnSignalIncomingDataSourcePackage>((model) {
          _onNewTurnSignal(value: model.value);
        })
        ..voidOnModel<SuccessEventUint8Body,
            FrontRightTurnSignalIncomingDataSourcePackage>((model) {
          _onNewTurnSignal(value: model.value, left: false);
        })
        ..voidOnModel<SuccessEventUint8Body,
            TailLeftTurnSignalIncomingDataSourcePackage>((model) {
          _onNewTurnSignal(value: model.value, front: false);
        })
        ..voidOnModel<SuccessEventUint8Body,
            TailRightTurnSignalIncomingDataSourcePackage>((model) {
          _onNewTurnSignal(value: model.value, front: false, left: false);
        })
        //
        ..voidOnModel<SuccessEventUint8Body,
            ReverseLightIncomingDataSourcePackage>((model) {
          emit(state.copyWith(reverse: AsyncData.success(model.value.toBool)));
        })
        ..voidOnModel<SuccessEventUint8Body,
            BrakeLightIncomingDataSourcePackage>((model) {
          emit(state.copyWith(brake: AsyncData.success(model.value.toBool)));
        })
        ..voidOnModel<SuccessEventUint8Body,
            CabinLightIncomingDataSourcePackage>((model) {
          emit(state.copyWith(cabin: AsyncData.success(model.value.toBool)));
        });
    });
  }

  @protected
  final DataSource dataSource;

  @protected
  final Duration toggleTimeout;

  @protected
  final Duration subscriptionTimeout;

  @visibleForTesting
  static const kToggleTimeout = Duration(seconds: 1);

  @visibleForTesting
  static const kSubscriptionTimeout = Duration(seconds: 1);

  void _onNewSideBeam({
    bool front = true,
    required int value,
  }) {
    _onNewTwoBoolsState(
      newFeatureState: state.sideBeam.copyWith(
        payload: state.sideBeam.payload.copyWith(
          first: front ? value.toBool : null,
          second: front ? null : value.toBool,
        ),
      ),
      newStateBuilder: (current) => state.copyWith(sideBeam: current),
    );
  }

  void _onNewHazardState({
    bool front = true,
    required int value,
  }) {
    _onNewTwoBoolsState(
      newFeatureState: state.hazardBeam.copyWith(
        payload: state.hazardBeam.payload.copyWith(
          first: front ? value.toBool : null,
          second: front ? null : value.toBool,
        ),
      ),
      newStateBuilder: (newState) => state.copyWith(hazardBeam: newState),
    );
  }

  void _onNewTurnSignal({
    bool front = true,
    bool left = true,
    required int value,
  }) {
    _onNewTwoBoolsState(
      newFeatureState: left
          ? state.leftTurnSignal.copyWith(
              payload: state.leftTurnSignal.payload.copyWith(
                first: front ? value.toBool : null,
                second: front ? null : value.toBool,
              ),
            )
          : state.rightTurnSignal.copyWith(
              payload: state.rightTurnSignal.payload.copyWith(
                first: front ? value.toBool : null,
                second: front ? null : value.toBool,
              ),
            ),
      newStateBuilder: (newState) => left
          ? state.copyWith(leftTurnSignal: newState)
          : state.copyWith(rightTurnSignal: newState),
    );
  }

  void _onNewTwoBoolsState({
    required AsyncData<TwoBoolsState, ToggleStateError> newFeatureState,
    required LightsState Function(
      AsyncData<TwoBoolsState, ToggleStateError> newState,
    ) newStateBuilder,
  }) {
    final newFeaturePayload = newFeatureState.payload;
    final waitingFor = newFeaturePayload.waitingForSwitch;

    if (waitingFor == null || waitingFor == newFeaturePayload.bothOn) {
      emit(
        newStateBuilder(
          AsyncData.success(
            newFeaturePayload.copyWith(
              setWaitingForSwitchToNull: true,
            ),
          ),
        ),
      );

      return;
    }

    emit(newStateBuilder(newFeatureState));
  }

  void _sendSubscriptionPackages(List<DataSourceParameterId> parameterIds) {

  }

  void _sendSetValuePackages(
    List<DataSourceParameterId> parameterIds,
    int value,
  ) {
    dataSource.sendPackages(
      parameterIds
          .map(
            (e) => OutgoingSetValuePackage(
              parameterId: e,
              setValueBody: SetUint8Body(value: value),
            ),
          )
          .toList(),
    );
  }

  // subscribe methods
  void subscribeToSideBeam() {
    _subscribeTo<TwoBoolsState>(
      kSideBeamParameterIds,
      newFeatureStateBuilder: () => state.sideBeam,
      newStateBuilder: (newState) => state.copyWith(sideBeam: newState),
      loadingState: const TwoBoolsState.off(),
    );
  }

  void subscribeToTurnSignals() {
    _subscribeTo<TwoBoolsState>(
      kLeftTurnSignalParameterIds,
      newFeatureStateBuilder: () => state.leftTurnSignal,
      newStateBuilder: (newState) => state.copyWith(leftTurnSignal: newState),
      loadingState: const TwoBoolsState.off(),
    );
    _subscribeTo<TwoBoolsState>(
      kRightTurnSignalParameterIds,
      newFeatureStateBuilder: () => state.rightTurnSignal,
      newStateBuilder: (newState) => state.copyWith(rightTurnSignal: newState),
      loadingState: const TwoBoolsState.off(),
    );
  }

  void subscribeToHazardBeam() {
    _subscribeTo<TwoBoolsState>(
      kHazardBeamParameterIds,
      newFeatureStateBuilder: () => state.hazardBeam,
      newStateBuilder: (newState) => state.copyWith(hazardBeam: newState),
      loadingState: const TwoBoolsState.off(),
    );
  }

  void subscribeToLowBeam() {
    _subscribeTo<bool>(
      kLowBeamParameterIds,
      newFeatureStateBuilder: () => state.lowBeam,
      newStateBuilder: (newState) => state.copyWith(lowBeam: newState),
      loadingState: false,
    );
  }

  void subscribeToHighBeam() {
    _subscribeTo<bool>(
      kHighBeamParameterIds,
      newFeatureStateBuilder: () => state.highBeam,
      newStateBuilder: (newState) => state.copyWith(highBeam: newState),
      loadingState: false,
    );
  }

  void subscribeToReverseLight() {
    _subscribeTo<bool>(
      kReverseLightParameterIds,
      newFeatureStateBuilder: () => state.reverse,
      newStateBuilder: (newState) => state.copyWith(reverse: newState),
      loadingState: false,
    );
  }

  void subscribeToBrakeLight() {
    _subscribeTo<bool>(
      kBrakeLightParameterIds,
      newFeatureStateBuilder: () => state.brake,
      newStateBuilder: (newState) => state.copyWith(brake: newState),
      loadingState: false,
    );
  }

  void subscribeToCabinLight() {
    _subscribeTo<bool>(
      kCabinLightParameterIds,
      newFeatureStateBuilder: () => state.cabin,
      newStateBuilder: (newState) => state.copyWith(cabin: newState),
      loadingState: false,
    );
  }

  Future<void> _subscribeTo<T>(
    List<DataSourceParameterId> parameterIds, {
    required AsyncData<T, ToggleStateError> Function() newFeatureStateBuilder,
    required LightsState Function(
      AsyncData<T, ToggleStateError> newState,
    ) newStateBuilder,
    required T loadingState,
  }) async {
    emit(newStateBuilder(AsyncData.loading(loadingState)));

    _sendSubscriptionPackages(parameterIds);

    final failure = await stream
        .where((event) => newFeatureStateBuilder().isExecuted)
        .map<LightsState?>((event) => null)
        .first
        .timeout(
      subscriptionTimeout,
      onTimeout: () async {
        return newStateBuilder(
          newFeatureStateBuilder().inFailure(
            const ToggleStateError.timeout(),
          ),
        );
      },
    );

    if (isClosed) return;
    if (failure != null) emit(failure);
  }

  static const kSideBeamParameterIds = [
    DataSourceParameterId.frontSideBeam(),
    DataSourceParameterId.tailSideBeam(),
  ];

  static const kLeftTurnSignalParameterIds = [
    DataSourceParameterId.frontLeftTurnSignal(),
    DataSourceParameterId.tailLeftTurnSignal(),
  ];

  static const kRightTurnSignalParameterIds = [
    DataSourceParameterId.frontRightTurnSignal(),
    DataSourceParameterId.tailRightTurnSignal(),
  ];

  static const kHazardBeamParameterIds = [
    DataSourceParameterId.frontHazardBeam(),
    DataSourceParameterId.tailHazardBeam(),
  ];

  static const kLowBeamParameterIds = [
    DataSourceParameterId.lowBeam(),
  ];

  static const kHighBeamParameterIds = [
    DataSourceParameterId.highBeam(),
  ];

  static const kReverseLightParameterIds = [
    DataSourceParameterId.reverseLight(),
  ];

  static const kBrakeLightParameterIds = [
    DataSourceParameterId.brakeLight(),
  ];

  static const kCabinLightParameterIds = [
    DataSourceParameterId.cabinLight(),
  ];

  void toggleSideBeam() {
    _toggleTwoBools(
      newStateBuilder: (newState) => state.copyWith(sideBeam: newState),
      newFeatureStateBuilder: () => state.sideBeam,
      parameterIds: kSideBeamParameterIds,
    );
  }

  void _toggleLeftTurnSignal() {
    _toggleTwoBools(
      newStateBuilder: (newState) => state.copyWith(leftTurnSignal: newState),
      newFeatureStateBuilder: () => state.leftTurnSignal,
      parameterIds: kLeftTurnSignalParameterIds,
    );
  }

  void toggleLeftTurnSignal() {
    if (state.rightTurnSignal.payload.isOn) _toggleRightTurnSignal();
    if (state.hazardBeam.payload.isOn) _toggleHazardBeam();

    _toggleLeftTurnSignal();
  }

  void _toggleRightTurnSignal() {
    _toggleTwoBools(
      newStateBuilder: (newState) => state.copyWith(rightTurnSignal: newState),
      newFeatureStateBuilder: () => state.rightTurnSignal,
      parameterIds: kRightTurnSignalParameterIds,
    );
  }

  void toggleRightTurnSignal() {
    if (state.leftTurnSignal.payload.isOn) _toggleLeftTurnSignal();
    if (state.hazardBeam.payload.isOn) _toggleHazardBeam();

    _toggleRightTurnSignal();
  }

  void _toggleHazardBeam() {
    _toggleTwoBools(
      newStateBuilder: (newState) => state.copyWith(hazardBeam: newState),
      newFeatureStateBuilder: () => state.hazardBeam,
      parameterIds: kHazardBeamParameterIds,
    );
  }

  void toggleHazardBeam() {
    if (state.leftTurnSignal.payload.isOn) _toggleLeftTurnSignal();
    if (state.rightTurnSignal.payload.isOn) _toggleRightTurnSignal();

    _toggleHazardBeam();
  }

  void toggleLowBeam() {
    _toggleBool(
      newFeatureStateBuilder: () => state.lowBeam,
      newStateBuilder: (newState) => state.copyWith(lowBeam: newState),
      parameterIds: kLowBeamParameterIds,
    );
  }

  void toggleHighBeam() {
    _toggleBool(
      newFeatureStateBuilder: () => state.highBeam,
      newStateBuilder: (newState) => state.copyWith(highBeam: newState),
      parameterIds: kHighBeamParameterIds,
    );
  }

  void toggleReverseLight() {
    _toggleBool(
      newFeatureStateBuilder: () => state.reverse,
      newStateBuilder: (newState) => state.copyWith(reverse: newState),
      parameterIds: kReverseLightParameterIds,
    );
  }

  void toggleBrakeLight() {
    _toggleBool(
      newFeatureStateBuilder: () => state.brake,
      newStateBuilder: (newState) => state.copyWith(brake: newState),
      parameterIds: kBrakeLightParameterIds,
    );
  }

  void toggleCabinLight() {
    _toggleBool(
      newFeatureStateBuilder: () => state.cabin,
      newStateBuilder: (newState) => state.copyWith(cabin: newState),
      parameterIds: kCabinLightParameterIds,
    );
  }

  Future<void> _toggleBool({
    required AsyncData<bool, ToggleStateError> Function()
        newFeatureStateBuilder,
    required LightsState Function(
      AsyncData<bool, ToggleStateError> newState,
    ) newStateBuilder,
    required List<DataSourceParameterId> parameterIds,
  }) async {
    final currentState = newFeatureStateBuilder();
    if (!currentState.isExecuted) return;

    final setTo = !currentState.payload;
    emit(newStateBuilder(AsyncData.loading(setTo)));
    _sendSetValuePackages(
      parameterIds,
      setTo.toInt,
    );

    final failure = await stream
        .where((event) => newFeatureStateBuilder().payload == setTo)
        .map<LightState<bool>?>((event) => null)
        .first
        .timeout(
      toggleTimeout,
      onTimeout: () async {
        return AsyncData.failure(
          currentState.payload,
          const ToggleStateError.timeout(),
        );
      },
    );

    if (isClosed) return;
    if (failure != null) emit(newStateBuilder(failure));
  }

  Future<void> _toggleTwoBools({
    required AsyncData<TwoBoolsState, ToggleStateError> Function()
        newFeatureStateBuilder,
    required LightsState Function(
      AsyncData<TwoBoolsState, ToggleStateError> newState,
    ) newStateBuilder,
    required List<DataSourceParameterId> parameterIds,
  }) async {
    final currentState = newFeatureStateBuilder();
    if (!currentState.isExecuted) return;

    emit(
      newStateBuilder(
        AsyncData.loading(
          const TwoBoolsState.off().copyWith(
            waitingForSwitch: currentState.payload.oppositeBool,
          ),
        ),
      ),
    );

    _sendSetValuePackages(
      parameterIds,
      currentState.payload.oppositeValue,
    );

    final failure = await stream
        .where((event) {
          final currentState = newFeatureStateBuilder();
          final payload = currentState.payload;
          return !payload.differs &&
              currentState.isSuccess &&
              payload.waitingForSwitch == null;
        })
        .map<LightState<TwoBoolsState>?>((event) => null)
        .first
        .timeout(
          toggleTimeout,
          onTimeout: () async {
            final currentState = newFeatureStateBuilder();
            final payload = currentState.payload;

            if (payload.differs || payload.waitingForSwitch != payload.isOn) {
              final failure = payload.differs
                  ? ToggleStateError.differs(
                      first: payload.first,
                      second: payload.second,
                    )
                  : const ToggleStateError.timeout();

              return AsyncData.failure(
                payload,
                failure,
              );
            }
            return null;
          },
        );

    if (isClosed) return;
    if (failure != null) emit(newStateBuilder(failure));
  }
}

extension on int {
  bool get toBool => this == 0xFF;
}

extension on bool {
  int get toInt => this ? 0xFF : 0;
}
