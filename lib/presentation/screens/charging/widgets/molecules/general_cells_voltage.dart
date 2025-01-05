import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/app/app.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/screens/charging/widgets/atoms/charging_screen_list_tile.dart';

class GeneralCellsVoltage extends StatelessWidget {
  const GeneralCellsVoltage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BatteryDataCubit, BatteryDataState,
        Sequence<LowVoltageMinMaxDelta>>(
      selector: (state) => state.lowVoltageMinMaxDelta,
      builder: (context, state) {
        return SliverList.list(
          children: [
            ChargingScreenListTile<LowVoltageMinMaxDelta>(
              title: context.l10n.minCellsVoltageTileTitle,
              values: state,
              valueMapper: (value) {
                return (
                  context.l10n.voltageValue(value.min.toStringAsFixed(3)),
                  value.status,
                );
              },
            ),
            ChargingScreenListTile<LowVoltageMinMaxDelta>(
              title: context.l10n.maxCellsVoltageTileTitle,
              values: state,
              valueMapper: (value) {
                return (
                  context.l10n.voltageValue(value.max.toStringAsFixed(3)),
                  value.status,
                );
              },
            ),
            ChargingScreenListTile<LowVoltageMinMaxDelta>(
              title: context.l10n.deltaCellsVoltageTileTitle,
              values: state,
              valueMapper: (value) {
                return (
                  context.l10n.voltageValue(value.delta.toStringAsFixed(3)),
                  value.status,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
