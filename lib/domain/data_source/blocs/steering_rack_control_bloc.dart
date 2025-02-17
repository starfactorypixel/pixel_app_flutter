import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/extensions/stream.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/incoming/incoming_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/outgoing/outgoing_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:re_seedwork/re_seedwork.dart';

part 'steering_rack_control_bloc.freezed.dart';

@freezed
class SteeringRackControlEvent with _$SteeringRackControlEvent {
  const factory SteeringRackControlEvent.get() = _Get;
  const factory SteeringRackControlEvent.set(SteeringRack steeringRack) = _Set;
}

typedef SteeringRackControlState
    = AsyncData<SteeringRack, SteeringRackControlEvent>;

class SteeringRackControlBloc
    extends Bloc<SteeringRackControlEvent, SteeringRackControlState> {
  SteeringRackControlBloc({
    required this.dataSource,
    this.responseTimeout = const Duration(seconds: 2),
  }) : super(const SteeringRackControlState.initial(SteeringRack.free)) {
    on<_Get>(_onGet);
    on<_Set>(_onSet);
  }

  Future<void> _onGet(
    _Get event,
    Emitter<SteeringRackControlState> emit,
  ) async {
    emit(state.inLoading());

    try {
      await dataSource.packageStream
          .waitForType<SteeringRackIncomingDataSourcePackage>(
        action: () async {
          final result = await dataSource.sendPackage(
            OutgoingValueRequestPackage(
              parameterId: const DataSourceParameterId.steeringRack(),
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
                return AsyncData.success(SteeringRack.fromId(value));
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

  Future<void> _onSet(
    _Set event,
    Emitter<SteeringRackControlState> emit,
  ) async {
    final beforePayload = state.payload;
    emit(AsyncData.loading(event.steeringRack));

    try {
      await dataSource.packageStream
          .waitForType<SteeringRackIncomingDataSourcePackage>(
        action: () async {
          final result = await dataSource.sendPackage(
            OutgoingSetValuePackage(
              parameterId: const DataSourceParameterId.steeringRack(),
              setValueBody: SetUint8Body(value: event.steeringRack.id),
            ),
          );

          if (result.isError) {
            emit(AsyncData.failure(beforePayload, event));
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
                  beforePayload,
                  event,
                );
              },
              error: () => AsyncData.failure(
                beforePayload,
                event,
              ),
            ),
          );
        },
        timeout: responseTimeout,
      );
    } catch (e) {
      emit(AsyncData.failure(beforePayload, event));

      rethrow;
    }
  }

  @protected
  final DataSource dataSource;

  @protected
  final Duration responseTimeout;
}
