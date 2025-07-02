import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/incoming_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/outgoing/outgoing_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:re_seedwork/re_seedwork.dart';

typedef GeneralInterfaceState = AsyncData<bool, ToggleStateError>;

@immutable
class GeneralInterfacesState with EquatableMixin {
  const GeneralInterfacesState({
    required this.leftDoor,
    required this.rightDoor,
    required this.wipers,
  });

  const GeneralInterfacesState.initial()
      : leftDoor = const AsyncData.initial(false),
        rightDoor = const AsyncData.initial(false),
        wipers = const AsyncData.initial(false);

  final GeneralInterfaceState leftDoor;
  final GeneralInterfaceState rightDoor;
  final GeneralInterfaceState wipers;

  @override
  List<Object?> get props => [leftDoor, rightDoor, wipers];

  GeneralInterfacesState copyWith({
    GeneralInterfaceState? leftDoor,
    GeneralInterfaceState? rightDoor,
    GeneralInterfaceState? wipers,
  }) {
    return GeneralInterfacesState(
      leftDoor: leftDoor ?? this.leftDoor,
      rightDoor: rightDoor ?? this.rightDoor,
      wipers: wipers ?? this.wipers,
    );
  }

  bool get hasFailureState =>
      [leftDoor, rightDoor, wipers].any((element) => element.isFailure);

  List<R> whenFailure<R>(
    GeneralInterfacesState prevState, {
    required R Function(ToggleStateError error) leftDoor,
    required R Function(ToggleStateError error) rightDoor,
    required R Function(ToggleStateError error) wipers,
  }) {
    final leftError = this.leftDoor.error;
    final rightError = this.rightDoor.error;
    final wipersError = this.wipers.error;

    final errors = [
      _filterError(
        leftError,
        prevState.leftDoor.error,
        leftDoor,
      ),
      _filterError(
        rightError,
        prevState.rightDoor.error,
        rightDoor,
      ),
      _filterError(
        wipersError,
        prevState.wipers.error,
        wipers,
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
}

extension _ErrorExtension<V, E extends Object> on AsyncData<V, E> {
  E? get error => maybeWhen(
        orElse: (_) => null,
        failure: (payload, error) => error,
      );
}

class GeneralInterfacesCubit extends Cubit<GeneralInterfacesState>
    with ConsumerBlocMixin {
  GeneralInterfacesCubit({
    required this.dataSource,
    this.subscriptionTimeout = kSubscriptionTimeout,
    this.toggleTimeout = kToggleTimeout,
  }) : super(const GeneralInterfacesState.initial()) {
    subscribe<DataSourceIncomingPackage>(dataSource.packageStream, (package) {
      package
        ..voidOnModel<DoorBody, LeftDoorIncomingDataSourcePackage>((model) {
          emit(state.copyWith(leftDoor: AsyncData.success(model.isOpen)));
        })
        ..voidOnModel<DoorBody, RightDoorIncomingDataSourcePackage>((model) {
          emit(state.copyWith(rightDoor: AsyncData.success(model.isOpen)));
        })
        ..voidOnModel<WindscreenWipersBody,
            WindscreenWipersIncomingDataSourcePackage>((model) {
          emit(state.copyWith(wipers: AsyncData.success(model.isOn)));
        });
    });
  }

  @protected
  final Duration toggleTimeout;

  @protected
  final Duration subscriptionTimeout;

  @visibleForTesting
  static const kToggleTimeout = Duration(seconds: 1);

  @visibleForTesting
  static const kSubscriptionTimeout = Duration(seconds: 1);

  @protected
  final DataSource dataSource;

  void subscribeToLeftDoor([
    DataSourceParameterId parameterId =
        const DataSourceParameterId.custom(ButtonFunctionId.leftDoorId),
  ]) {

  }

  void subscribeToRightDoor([
    DataSourceParameterId parameterId =
        const DataSourceParameterId.custom(ButtonFunctionId.rightDoorId),
  ]) {

  }

  void subscribeToWindscreenWipers({
    DataSourceParameterId parameterId =
        const DataSourceParameterId.windscreenWipers(),
  }) {

  }

  void toggleLeftDoor([
    DataSourceParameterId parameterId = const DataSourceParameterId.leftDoor(),
  ]) {
    _toggleBool(
      newFeatureStateBuilder: () => state.leftDoor,
      newStateBuilder: (newState) => state.copyWith(leftDoor: newState),
      outgoingPackageBuilder: (_) =>
          OutgoingActionRequestPackage(parameterId: parameterId),
    );
  }

  void toggleRightDoor([
    DataSourceParameterId parameterId = const DataSourceParameterId.rightDoor(),
  ]) {
    _toggleBool(
      newFeatureStateBuilder: () => state.rightDoor,
      newStateBuilder: (newState) => state.copyWith(rightDoor: newState),
      outgoingPackageBuilder: (_) =>
          OutgoingActionRequestPackage(parameterId: parameterId),
    );
  }

  void toggleWindscreenWipers([
    DataSourceParameterId parameterId =
        const DataSourceParameterId.windscreenWipers(),
  ]) {
    _toggleBool(
      newFeatureStateBuilder: () => state.wipers,
      newStateBuilder: (newState) => state.copyWith(wipers: newState),
      outgoingPackageBuilder: (setTo) => OutgoingSetValuePackage(
        parameterId: parameterId,
        setValueBody: SetUint8Body(value: setTo ? 0xFF : 0),
      ),
    );
  }

  Future<void> _toggleBool({
    required AsyncData<bool, ToggleStateError> Function()
        newFeatureStateBuilder,
    required GeneralInterfacesState Function(
      AsyncData<bool, ToggleStateError> newState,
    ) newStateBuilder,
    // ignore: avoid_positional_boolean_parameters
    required DataSourceOutgoingPackage Function(bool setTo)
        outgoingPackageBuilder,
  }) async {
    final currentState = newFeatureStateBuilder();
    if (!currentState.isExecuted) return;

    final setTo = !currentState.payload;
    emit(newStateBuilder(AsyncData.loading(setTo)));

    await dataSource.sendPackage(outgoingPackageBuilder(setTo));

    final failure = await stream
        .where((event) => newFeatureStateBuilder().payload == setTo)
        .map<GeneralInterfaceState?>((event) => null)
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
}
