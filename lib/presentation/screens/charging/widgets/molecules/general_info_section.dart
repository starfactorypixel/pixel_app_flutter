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
    final batteriesCount =
        context.read<BatteryDataCubit>().state.batteriesCount;
    final isOneBattery = batteriesCount == 1;

    return SliverList.list(
      children: [
        if (!isOneBattery)
          for (int i = 0; i < batteriesCount; i++)
            BlocSelector<GeneralDataCubit, GeneralDataState, IntWithStatus?>(
              selector: (state) => state.batteryPercent.getAt(i),
              builder: (context, batteryPercent) {
                if (batteryPercent == null) return const SizedBox.shrink();
                return ChargingScreenListTile(
                  title: context.l10n.batteryPercentNTileTitle(i + 1),
                  trailing: '${batteryPercent.value}%',
                  status: batteryPercent.status,
                );
              },
            ),
        if (!isOneBattery)
          for (int i = 0; i < batteriesCount; i++)
            BlocSelector<GeneralDataCubit, GeneralDataState, IntWithStatus?>(
              selector: (state) => state.power.getAt(i),
              builder: (context, power) {
                if (power == null) return const SizedBox.shrink();
                return ChargingScreenListTile(
                  title: context.l10n.powerNTileTitle(i + 1),
                  trailing:
                      '${power.value} ${context.l10n.wattMeasurementUnit}',
                  status: power.status,
                );
              },
            ),
        for (int i = 0; i < batteriesCount; i++)
          BlocSelector<BatteryDataCubit, BatteryDataState, HighVoltage?>(
            selector: (state) => state.highVoltage.getAt(i),
            builder: (context, highVoltage) {
              if (highVoltage == null) return const SizedBox.shrink();
              return ChargingScreenListTile(
                title: isOneBattery
                    ? context.l10n.totalVoltageTileTitle
                    : context.l10n.totalVoltageNTileTitle(i + 1),
                trailing: context.l10n.voltageValue(
                  (highVoltage.value / 10).toStringAsFixed(2),
                ),
                status: highVoltage.status,
              );
            },
          ),
        //
        for (int i = 0; i < batteriesCount; i++)
          BlocSelector<BatteryDataCubit, BatteryDataState, HighCurrent?>(
            selector: (state) => state.highCurrent.getAt(i),
            builder: (context, highCurrent) {
              if (highCurrent == null) return const SizedBox.shrink();
              return ChargingScreenListTile(
                title: isOneBattery
                    ? context.l10n.totalCurrentTileTitle
                    : context.l10n.totalCurrentNTileTitle(i + 1),
                trailing: context.l10n.currentValue(
                  (highCurrent.value / 10).toStringAsFixed(2),
                ),
                status: highCurrent.status,
              );
            },
          ),
        //
        for (int i = 0; i < batteriesCount; i++)
          BlocSelector<BatteryDataCubit, BatteryDataState, MaxTemperature?>(
            selector: (state) => state.maxTemperature.getAt(i),
            builder: (context, maxTemperature) {
              if (maxTemperature == null) return const SizedBox.shrink();
              return ChargingScreenListTile(
                title: isOneBattery
                    ? context.l10n.maximumRegisteredTemperatureTileTitle
                    : context.l10n
                        .maximumRegisteredTemperatureNTileTitle(i + 1),
                trailing: context.l10n.celsiusValue(maxTemperature.value),
                status: maxTemperature.status,
              );
            },
          ),
      ],
    );
  }
}
