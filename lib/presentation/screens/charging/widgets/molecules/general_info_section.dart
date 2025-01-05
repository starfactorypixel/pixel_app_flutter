import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/app/app.dart';
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
        BlocSelector<GeneralDataCubit, GeneralDataState,
            Sequence<IntWithStatus>>(
          selector: (state) => state.batteryPercent,
          builder: (context, batteriesPercent) {
            // if (batteryPercent == null) return const SizedBox.shrink();
            return ChargingScreenListTile<IntWithStatus>(
              title: context.l10n.batteryPercentTileTitle,
              valueMapper: (v) => ('${v.value}%', v.status),
              values: batteriesPercent,
            );
          },
        ),
        //
        BlocSelector<GeneralDataCubit, GeneralDataState,
            Sequence<IntWithStatus>>(
          selector: (state) => state.power,
          builder: (context, powers) {
            return ChargingScreenListTile<IntWithStatus>(
              title: context.l10n.powerGeneralTileTitle,
              values: powers,
              valueMapper: (value) => (
                '${value.value} ${context.l10n.wattMeasurementUnit}',
                value.status,
              ),
            );
          },
        ),
        //
        BlocSelector<BatteryDataCubit, BatteryDataState, Sequence<HighVoltage>>(
          selector: (state) => state.highVoltage,
          builder: (context, highVoltages) {
            return ChargingScreenListTile<HighVoltage>(
              title: context.l10n.totalVoltageTileTitle,
              valueMapper: (value) {
                return (
                  context.l10n
                      .voltageValue((value.value / 10).toStringAsFixed(2)),
                  value.status,
                );
              },
              values: highVoltages,
            );
          },
        ),
        //
        BlocSelector<BatteryDataCubit, BatteryDataState, Sequence<HighCurrent>>(
          selector: (state) => state.highCurrent,
          builder: (context, highCurrents) {
            return ChargingScreenListTile<HighCurrent>(
              title: context.l10n.totalCurrentTileTitle,
              valueMapper: (value) => (
                (value.value / 10).toStringAsFixed(2),
                value.status,
              ),
              values: highCurrents,
            );
          },
        ),
        //
        BlocSelector<BatteryDataCubit, BatteryDataState,
            Sequence<MaxTemperature>>(
          selector: (state) => state.maxTemperature,
          builder: (context, maxTemperatures) {
            return ChargingScreenListTile<MaxTemperature>(
              title: context.l10n.maximumRegisteredTemperatureTileTitle,
              valueMapper: (value) => (
                context.l10n.celsiusValue(value.value),
                value.status,
              ),
              values: maxTemperatures,
            );
          },
        ),
      ],
    );
  }
}
