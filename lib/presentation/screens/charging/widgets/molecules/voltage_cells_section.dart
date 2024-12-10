import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/screens/charging/widgets/atoms/charging_screen_cell_widget.dart';

class VoltageCellsSection extends StatelessWidget {
  const VoltageCellsSection({super.key, required this.batteryIndex});

  final int batteryIndex;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      itemCount: context.read<BatteryDataCubit>().state.cellsCount,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 70,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        return BlocSelector<BatteryDataCubit, BatteryDataState, double?>(
          // selector: selectors[index],
          selector: (state) =>
              state.batteryLowVoltage.getAt(batteryIndex)?.getAt(index),
          builder: (context, state) {
            return ChargingScreenCellWidget(
              number: index + 1,
              content: context.l10n.voltageValue(
                (state ?? 0).toStringAsFixed(3),
              ),
            );
          },
        );
      },
    );
  }
}
