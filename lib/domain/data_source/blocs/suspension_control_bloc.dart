import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/extensions/stream.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/incoming_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/outgoing/outgoing_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:re_seedwork/re_seedwork.dart';

part 'suspension_control_bloc.freezed.dart';

@freezed
class SuspensionControlEvent extends EffectEvent with _$SuspensionControlEvent {
  const factory SuspensionControlEvent.switchMode(SuspensionMode mode) =
      _SwitchMode;
  const factory SuspensionControlEvent.getManual() = _GetManual;
  const factory SuspensionControlEvent.setManual(int value) = _SetManual;
  const factory SuspensionControlEvent.getMode() = _GetMode;
}

typedef SuspensionControlState
    = AsyncData<SuspensionMode, SuspensionControlEvent>;

class SuspensionControlBloc
    extends Bloc<SuspensionControlEvent, SuspensionControlState> {
  SuspensionControlBloc({
    required this.dataSource,
    this.responseTimeout = const Duration(seconds: 2),
  }) : super(
          const SuspensionControlState.initial(
            SuspensionMode.manualMiddle(),
          ),
        ) {
    on<_GetMode>(_onGetMode);
    on<_SwitchMode>(_onSwitchMode);
    on<_GetManual>(_onGetManualValue);
    on<_SetManual>(_onSetManualValue);
  }

  @protected
  final DataSource dataSource;

  @visibleForTesting
  final Duration responseTimeout;

  Future<void> _onGetMode(
    _GetMode event,
    Emitter<AsyncData<SuspensionMode, SuspensionControlEvent>> emit,
  ) async {
    emit(state.inLoading());

    try {
      await dataSource.packageStream
          .waitForType<SuspensionModeIncomingDataSourcePackage>(
        action: () async {
          final result = await dataSource.sendPackage(
            OutgoingValueRequestPackage(
              parameterId: const DataSourceParameterId.suspensionMode(),
            ),
          );

          if (result.isError) {
            emit(state.inFailure(event));
          }
          return result.isError;
        },
        onDone: (package) async {
          emit(
            package.dataModel.when(
              success: (value) {
                return AsyncData.success(SuspensionMode.fromId(value));
              },
              error: () => state.inFailure(event),
            ),
          );
        },
        timeout: responseTimeout,
      );
    } catch (e) {
      emit(state.inFailure(event));

      rethrow;
    }

    if (state.isSuccess && state.value.isManual) {
      add(const SuspensionControlEvent.getManual());
    }
  }

  Future<void> _onGetManualValue(
    _GetManual event,
    Emitter<AsyncData<SuspensionMode, SuspensionControlEvent>> emit,
  ) async {
    emit(const AsyncData.loading(SuspensionMode.manualMiddle()));

    try {
      await dataSource.packageStream
          .waitForType<SuspensionManualValueIncomingDataSourcePackage>(
        action: () async {
          final result = await dataSource.sendPackage(
            OutgoingValueRequestPackage(
              parameterId: const DataSourceParameterId.suspensionValue(),
            ),
          );

          if (result.isError) {
            emit(state.inFailure(event));
          }
          return result.isError;
        },
        onDone: (package) async {
          emit(
            package.dataModel.when(
              success: (value) {
                return AsyncData.success(SuspensionMode.manual(value: value));
              },
              error: () => state.inFailure(event),
            ),
          );
        },
        timeout: responseTimeout,
      );
    } catch (e) {
      emit(state.inFailure(event));

      rethrow;
    }
  }

  Future<void> _onSwitchMode(
    _SwitchMode event,
    Emitter<AsyncData<SuspensionMode, SuspensionControlEvent>> emit,
  ) async {
    final beforeMode = state.payload;
    emit(AsyncData.loading(event.mode));

    try {
      await dataSource.packageStream
          .waitForType<SuspensionModeIncomingDataSourcePackage>(
        action: () async {
          final result = await dataSource.sendPackage(
            OutgoingSetValuePackage(
              parameterId: const DataSourceParameterId.suspensionMode(),
              setValueBody: SetUint8Body(value: event.mode.id),
            ),
          );

          if (result.isError) {
            emit(AsyncData.failure(beforeMode, event));
          }
          return result.isError;
        },
        onDone: (package) async {
          emit(
            package.dataModel.when(
              success: (value) {
                if (value == state.payload.id) {
                  return state.inSuccess();
                }
                return AsyncData.failure(
                  beforeMode,
                  event,
                );
              },
              error: () => AsyncData.failure(
                beforeMode,
                event,
              ),
            ),
          );
        },
        timeout: responseTimeout,
      );
    } catch (e) {
      emit(AsyncData.failure(beforeMode, event));

      rethrow;
    }

    if (state.isSuccess && state.payload.isManual) {
      add(const SuspensionControlEvent.getManual());
    }
  }

  Future<void> _onSetManualValue(
    _SetManual event,
    Emitter<AsyncData<SuspensionMode, SuspensionControlEvent>> emit,
  ) async {
    final beforeMode = state.payload;
    emit(AsyncData.loading(SuspensionMode.manual(value: event.value)));

    try {
      await dataSource.packageStream
          .waitForType<SuspensionManualValueIncomingDataSourcePackage>(
        action: () async {
          final result = await dataSource.sendPackage(
            OutgoingSetValuePackage(
              parameterId: const DataSourceParameterId.suspensionValue(),
              setValueBody: SetUint8Body(value: event.value),
            ),
          );

          if (result.isError) {
            emit(
              AsyncData.failure(
                beforeMode,
                event,
              ),
            );
          }
          return result.isError;
        },
        onDone: (package) async {
          emit(
            package.dataModel.when(
              success: (value) {
                if (value == event.value) {
                  return state.inSuccess();
                }
                return AsyncData.failure(
                  beforeMode,
                  event,
                );
              },
              error: () => AsyncData.failure(
                beforeMode,
                event,
              ),
            ),
          );
        },
        timeout: responseTimeout,
      );
    } catch (e) {
      emit(
        AsyncData.failure(
          beforeMode,
          event,
        ),
      );

      rethrow;
    }
  }
}
