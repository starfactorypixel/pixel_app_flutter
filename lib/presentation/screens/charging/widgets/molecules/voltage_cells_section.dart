import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/molecules/cell_sliver_grid_builder.dart';

class VoltageCellsSection extends StatelessWidget {
  const VoltageCellsSection({super.key, required this.batteryIndex});

  final int batteryIndex;

  @override
  Widget build(BuildContext context) {
    return CellSliverGridBuilder<BatteryDataCubit, BatteryDataState, double?>(
      itemCount: context.read<BatteryDataCubit>().state.cellsCount,
      selector: (state, index) {
        return state.batteryLowVoltage.getAt(batteryIndex)?.getAt(index);
      },
      contentBuilder: (context, data) {
        return (
          context.l10n.voltageValue((data ?? 0).toStringAsFixed(3)),
          null,
        );
      },
    );
  }
}
