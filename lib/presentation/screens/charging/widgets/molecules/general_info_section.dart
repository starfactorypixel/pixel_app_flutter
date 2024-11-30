import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/screens/charging/widgets/atoms/charging_screen_list_tile.dart';

class GeneralInfoSection extends StatelessWidget {
  const GeneralInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: [
        BlocSelector<BatteryDataCubit, BatteryDataState, HighVoltage>(
          selector: (state) => state.highVoltage,
          builder: (context, highVoltage) {
            return ChargingScreenListTile(
              title: context.l10n.totalVoltageTileTitle,
              trailing: context.l10n.voltageValue(
                (highVoltage.value / 10).toStringAsFixed(2),
              ),
              status: highVoltage.status,
            );
          },
        ),
        BlocSelector<BatteryDataCubit, BatteryDataState, HighCurrent>(
          selector: (state) => state.highCurrent,
          builder: (context, highCurrent) {
            return ChargingScreenListTile(
              title: context.l10n.totalCurrentTileTitle,
              trailing: context.l10n.currentValue(
                (highCurrent.batt1 / 10).toStringAsFixed(2),
              ),
              status: PeriodicValueStatus.normal,
            );
          },
        ),
        BlocSelector<BatteryDataCubit, BatteryDataState, HighCurrent>(
          selector: (state) => state.highCurrent,
          builder: (context, highCurrent) {
            return ChargingScreenListTile(
              title: context.l10n.totalCurrentTileTitle,
              trailing: context.l10n.currentValue(
                (highCurrent.batt2 / 10).toStringAsFixed(2),
              ),
              status: PeriodicValueStatus.normal,
            );
          },
        ),
        BlocSelector<BatteryDataCubit, BatteryDataState, MaxTemperature>(
          selector: (state) => state.maxTemperature,
          builder: (context, maxTemperature) {
            return ChargingScreenListTile(
              title: context.l10n.maximumRegisteredTemperatureTileTitle,
              trailing: context.l10n.celsiusValue(maxTemperature.value),
              status: maxTemperature.status,
            );
          },
        ),
      ],
    );
  }
}
