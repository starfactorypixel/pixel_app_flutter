import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/molecules/cell_sliver_grid_builder.dart';

class TemperatureSensorsSection extends StatelessWidget {
  const TemperatureSensorsSection({super.key, required this.batteryIndex});

  final int batteryIndex;

  @override
  Widget build(BuildContext context) {
    return CellSliverGridBuilder<BatteryDataCubit, BatteryDataState,
        BatteryTemperature?>(
      // temperatureSensorsCount - 2
      // because first two sensors are MOS and Balancer
      itemCount:
          context.read<BatteryDataCubit>().state.temperatureSensorsCount - 2,
      // index + 3 because first two sensors are MOS and Balancer
      // and we need to start from 1
      selector: (state, index) =>
          state.temperature.getAt(batteryIndex)?.getAt(index + 2),
      contentBuilder: (context, data) =>
          (context.l10n.celsiusValue(data?.value ?? 0), null),
    );
  }
}
