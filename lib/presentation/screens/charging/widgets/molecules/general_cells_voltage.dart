import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/screens/charging/widgets/atoms/charging_screen_list_tile.dart';

class GeneralCellsVoltage extends StatelessWidget {
  const GeneralCellsVoltage({super.key, required this.batteryIndex});

  final int batteryIndex;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BatteryDataCubit, BatteryDataState,
        LowVoltageMinMaxDelta?>(
      selector: (state) => state.lowVoltageMinMaxDelta.getAt(batteryIndex),
      builder: (context, state) {
        if (state == null) return SliverList.list(children: const []);
        return SliverList(
          delegate: SliverChildListDelegate(
            [
              ChargingScreenListTile(
                title: context.l10n.minCellsVoltageTileTitle,
                trailing:
                    context.l10n.voltageValue(state.min.toStringAsFixed(3)),
                status: state.status,
              ),
              ChargingScreenListTile(
                title: context.l10n.maxCellsVoltageTileTitle,
                trailing:
                    context.l10n.voltageValue(state.max.toStringAsFixed(3)),
                status: state.status,
              ),
              ChargingScreenListTile(
                title: context.l10n.deltaCellsVoltageTileTitle,
                trailing:
                    context.l10n.voltageValue(state.delta.toStringAsFixed(3)),
                status: state.status,
              ),
            ],
          ),
        );
      },
    );
  }
}
