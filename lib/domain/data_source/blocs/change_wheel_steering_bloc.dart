import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/outgoing/outgoing_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:re_seedwork/re_seedwork.dart';

part 'change_wheel_steering_bloc.freezed.dart';

@freezed
class ChangeWheelSteeringEvent extends EffectEvent with _$ChangeWheelSteeringEvent {
  const factory ChangeWheelSteeringEvent.change(WheelSteering newValue) = _Change;
}

typedef ChangeWheelSteeringState = AsyncData<WheelSteering, Object>;

class ChangeWheelSteeringBloc extends Bloc<ChangeWheelSteeringEvent, ChangeWheelSteeringState>
    with BlocEventHandlerMixin {
  ChangeWheelSteeringBloc({
    required this.dataSource,
    required this.generalDataCubit,
  }) : super(const ChangeWheelSteeringState.initial(WheelSteering.free)) {
    on<_Change>(_onChange);
  }

  @visibleForTesting
  static const List<DataSourceParameterId> kParameterIds = [
    DataSourceParameterId.wheelSteering(),
  ];

  @protected
  final DataSource dataSource;

  @protected
  final GeneralDataCubit generalDataCubit;

  Future<void> _onChange(
    _Change event,
    Emitter<AsyncData<WheelSteering, Object>> emit,
  ) async {
    emit(AsyncData.loading(event.newValue));

    try {
      final future = generalDataCubit.stream
          .firstWhere((element) => element.wheelSteering == event.newValue)
          .timeout(const Duration(seconds: 2));
      for (final parameterId in kParameterIds) {
        final res = await dataSource.sendPackage(
          OutgoingSetValuePackage(
            parameterId: parameterId,
            setValueBody: SetInt8Body(value: event.newValue.id),
          ),
        );
        if (res.isError) {
          return emit(AsyncData.failure(generalDataCubit.state.wheelSteering));
        }
      }
      await future;

      emit(AsyncData.success(event.newValue));
    } on Object catch (_) {
      emit(AsyncData.failure(generalDataCubit.state.wheelSteering));

      rethrow;
    }
  }
}
