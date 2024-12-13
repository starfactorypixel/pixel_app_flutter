import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/screens/charging/widgets/atoms/charging_screen_cell_widget.dart';

class TemperatureSensorsSection extends StatelessWidget {
  const TemperatureSensorsSection({super.key, required this.batteryIndex});

  final int batteryIndex;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      // temperatureSensorsCount - 2
      // because first two sensors are MOS and Balancer
      itemCount:
          context.read<BatteryDataCubit>().state.temperatureSensorsCount - 2,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 70,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        return BlocSelector<BatteryDataCubit, BatteryDataState,
            BatteryTemperature?>(
          // index + 3 because first two sensors are MOS and Balancer
          // and we need to start from 1
          selector: (state) =>
              state.temperature.getAt(batteryIndex)?.getAt(index + 2),
          builder: (context, state) {
            return ChargingScreenCellWidget(
              number: index + 1,
              content: context.l10n.celsiusValue(state?.value ?? 0),
            );
          },
        );
      },
    );
  }
}
