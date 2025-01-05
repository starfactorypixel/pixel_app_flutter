import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/screens/charging/widgets/atoms/charging_screen_list_tile.dart';

class MOSAndBalancerTemperature extends StatelessWidget {
  const MOSAndBalancerTemperature({super.key});

  @override
  Widget build(BuildContext context) {
    final batteriesCount =
        context.read<BatteryDataCubit>().state.batteriesCount;
    return SliverList.list(
      children: [
        BlocSelector<BatteryDataCubit, BatteryDataState,
            List<BatteryTemperature?>>(
          selector: (state) => [
            for (var i = 0; i < batteriesCount; i++)
              state.temperature.getAt(i)?.getAt(0),
          ],
          builder: (context, state) {
            return ChargingScreenListTile<BatteryTemperature?>(
              title: context.l10n.mosTileTitle,
              values: state,
              valueMapper: (value) => (
                context.l10n.celsiusValue(value?.value ?? 0),
                null,
              ),
            );
          },
        ),
        BlocSelector<BatteryDataCubit, BatteryDataState,
            List<BatteryTemperature?>>(
          selector: (state) => [
            for (var i = 0; i < batteriesCount; i++)
              state.temperature.getAt(i)?.getAt(1),
          ],
          builder: (context, state) {
            return ChargingScreenListTile<BatteryTemperature?>(
              title: context.l10n.balancerTileTitle,
              values: state,
              valueMapper: (value) => (
                context.l10n.celsiusValue(value?.value ?? 0),
                null,
              ),
            );
          },
        ),
      ],
    );
  }
}
