import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/app/extensions.dart';
import 'package:pixel_app_flutter/presentation/app/icons.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/statistic_item.dart';
import 'package:re_seedwork/re_seedwork.dart';

class StatisticWidget extends StatelessWidget {
  const StatisticWidget({super.key, this.useWrap = false});

  @protected
  final bool useWrap;

  @override
  Widget build(BuildContext context) {
    final batteriesCount =
        context.read<GeneralDataCubit>().state.batteriesCount;
    final items = <Widget>[
      for (int i = 0; i < batteriesCount; ++i)
        BlocSelector<GeneralDataCubit, GeneralDataState, IntWithStatus?>(
          selector: (state) => state.batteryLevel.getAt(i),
          builder: (context, state) {
            return BatteryLevelStatisticItem(item: state);
          },
        ),
      BlocSelector<GeneralDataCubit, GeneralDataState, IntWithStatus>(
        selector: (state) => state.odometer,
        builder: (context, state) => OdometerStatisticItem(item: state),
      ),
      BlocSelector<GeneralDataCubit, GeneralDataState, IntWithStatus>(
        selector: (state) => state.power,
        builder: (context, state) => PowerStatisticItem(item: state),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(right: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.statisticInfoPanelTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          if (useWrap)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Wrap(
                runSpacing: 16,
                spacing: 85,
                children: items
                    .map(
                      (child) => SizedBox(
                        width: 150,
                        child: FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: child,
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
          else
            FittedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: items.divideBy(const SizedBox(height: 10)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class BatteryLevelStatisticItem extends StatelessWidget {
  const BatteryLevelStatisticItem({super.key, required this.item});

  @protected
  final IntWithStatus? item;

  @override
  Widget build(BuildContext context) {
    final _item = item;
    return _item == null
        ? const SizedBox.shrink()
        : StatisticItem(
            icon: PixelIcons.battery,
            value: '${_item.value}%',
            customColor: context.colorFromStatus(_item.status),
          );
  }
}

class OdometerStatisticItem extends StatelessWidget {
  const OdometerStatisticItem({super.key, required this.item});

  @protected
  final IntWithStatus item;

  @override
  Widget build(BuildContext context) {
    return StatisticItem(
      icon: PixelIcons.speedometer,
      value: context.l10n.km(item.value),
      measurementUnit: context.l10n.kmMeasurementUnit,
      customColor: context.colorFromStatus(item.status),
    );
  }
}

class PowerStatisticItem extends StatelessWidget {
  const PowerStatisticItem({super.key, required this.item});

  @protected
  final IntWithStatus item;

  @override
  Widget build(BuildContext context) {
    final value = item.value;
    return StatisticItem(
      icon: value < 1 ? PixelIcons.batteryMinus : PixelIcons.batteryPlus,
      value: '${value.abs()}',
      measurementUnit: context.l10n.wattMeasurementUnit,
      customColor: context.colorFromStatus(
        item.status,
        onNormal: () {
          return value > 0 ? context.colors.successPastel : null;
        },
      ),
    );
  }
}
