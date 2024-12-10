import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/screens/charging/widgets/atoms/charging_screen_list_tile.dart';

class MOSAndBalancerTemperature extends StatelessWidget {
  const MOSAndBalancerTemperature({super.key, required this.batteryIndex});

  final int batteryIndex;

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: [
        BlocSelector<BatteryDataCubit, BatteryDataState, BatteryTemperature?>(
          selector: (state) => state.temperature.getAt(batteryIndex)?.getAt(0),
          builder: (context, state) {
            return ChargingScreenListTile(
              title: context.l10n.mosTileTitle,
              trailing: context.l10n.celsiusValue(state?.value ?? 0),
              status: PeriodicValueStatus.normal,
            );
          },
        ),
        BlocSelector<BatteryDataCubit, BatteryDataState, BatteryTemperature?>(
          selector: (state) => state.temperature.getAt(batteryIndex)?.getAt(1),
          builder: (context, state) {
            return ChargingScreenListTile(
              title: context.l10n.balancerTileTitle,
              trailing: context.l10n.celsiusValue(state?.value ?? 0),
              status: PeriodicValueStatus.normal,
            );
          },
        ),
      ],
    );
  }
}
