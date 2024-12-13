import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pixel_app_flutter/domain/data_source/models/hardware_count.dart';
import 'package:re_seedwork/re_seedwork.dart';

part 'get_hardware_count_bloc.freezed.dart';

@freezed
class GetHardwareCountEvent extends EffectEvent with _$GetHardwareCountEvent {
  const factory GetHardwareCountEvent.get() = _Get;
}

typedef GetHardwareCountState = AsyncData<Optional<HardwareCount>, Object>;

class GetHardwareCountBloc
    extends Bloc<GetHardwareCountEvent, GetHardwareCountState>
    with BlocEventHandlerMixin {
  GetHardwareCountBloc()
      : super(const GetHardwareCountState.initial(Optional.undefined())) {
    handleEvent<_Get, Result<Object, void>>(
      inLoading: () => state.inLoading(),
      inFailure: () => state.inFailure(),
      action: (_) async => const Result.value(null),
      onActionResult: (actionResult) async {
        return actionResult.when(
          error: (error) => state.inFailure(),
          value: (_) async {
            // TODO(Radomir): implement dynamic arguments passing
            // when esp32 will be able to send battery,
            // cells and temperature sensors count
            return const GetHardwareCountState.success(
              Optional.presented(
                HardwareCount(
                  batteries: 2,
                  motors: 4,
                  batteryCells: 20,
                  temperatureSensors: 10,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
