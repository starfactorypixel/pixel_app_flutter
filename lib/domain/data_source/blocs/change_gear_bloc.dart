import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package/outgoing/outgoing_data_source_packages.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:re_seedwork/re_seedwork.dart';

part 'change_gear_bloc.freezed.dart';

@freezed
class ChangeGearEvent with _$ChangeGearEvent {
  const factory ChangeGearEvent.change(MotorGear newGear) = _Change;
}

typedef ChangeGearState = AsyncData<MotorGear, Object>;

class ChangeGearBloc extends Bloc<ChangeGearEvent, ChangeGearState> {
  ChangeGearBloc({
    required this.dataSource,
    required this.generalDataCubit,
    this.responseTimeout = const Duration(seconds: 2),
  }) : super(const ChangeGearState.initial(MotorGear.unknown)) {
    on<_Change>(_onChange);
  }

  @visibleForTesting
  static const List<DataSourceParameterId> kParameterIds = [
    DataSourceParameterId.transmission1(),
    DataSourceParameterId.transmission2(),
    DataSourceParameterId.transmission3(),
    DataSourceParameterId.transmission4(),
  ];

  @protected
  final DataSource dataSource;

  @protected
  final GeneralDataCubit generalDataCubit;

  @visibleForTesting
  final Duration responseTimeout;

  Future<void> _onChange(
    _Change event,
    Emitter<AsyncData<MotorGear, Object>> emit,
  ) async {
    emit(AsyncData.loading(event.newGear));

    try {
      final future = generalDataCubit.stream
          .firstWhere((element) => element.mergedGear == event.newGear)
          .timeout(responseTimeout);
      for (final parameterId in kParameterIds) {
        final res = await dataSource.sendPackage(
          OutgoingSetValuePackage(
            parameterId: parameterId,
            setValueBody: SetInt8Body(value: event.newGear.id),
          ),
        );
        if (res.isError) {
          return emit(AsyncData.failure(generalDataCubit.state.mergedGear));
        }
      }
      await future;

      emit(AsyncData.success(event.newGear));
    } on Object catch (_) {
      emit(AsyncData.failure(generalDataCubit.state.mergedGear));

      rethrow;
    }
  }
}
