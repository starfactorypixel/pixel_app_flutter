import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/extensions.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/responsive_padding.dart';

@RoutePage()
class MotorScreen extends StatelessWidget {
  const MotorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final motorsCount = context.read<MotorDataCubit>().state.motorsCount;

    return ResponsivePadding(
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < motorsCount; ++i)
                _ItemHorizontal(value: '#${i + 1}'),
            ],
          ),
          Container(
            height: 24,
          ),
          _TwoValuesTableRow.builder(
            parameterName: context.l10n.speedTileTitle,
            builder: () {
              final state =
                  context.select((MotorDataCubit cubit) => cubit.state.speed);

              return (
                ['${state.first ~/ 10}', '${state.second ~/ 10}'],
                context.colorFromStatus(state.status),
              );
            },
            unitOfMeasurement: context.l10n.kmPerHourMeasurenentUnit,
          ),
          _TwoValuesTableRow.builder(
            parameterName: context.l10n.rpmTileTitle,
            builder: () {
              final state =
                  context.select((MotorDataCubit cubit) => cubit.state.rpm);
              return (
                ['${state.first}', '${state.second}'],
                context.colorFromStatus(state.status),
              );
            },
            unitOfMeasurement: context.l10n.rpmMeasurementUnit,
          ),
          _TwoValuesTableRow.builder(
            parameterName: context.l10n.voltageTileTitle,
            builder: () {
              final state =
                  context.select((MotorDataCubit cubit) => cubit.state.voltage);
              return (
                [
                  (state.first / 10).toStringAsFixed(1),
                  (state.second / 10).toStringAsFixed(1),
                ],
                context.colorFromStatus(state.status),
              );
            },
            unitOfMeasurement: context.l10n.voltMeasurementUnit,
          ),
          _TwoValuesTableRow.builder(
            parameterName: context.l10n.currentTileTitle,
            builder: () {
              final state =
                  context.select((MotorDataCubit cubit) => cubit.state.current);
              return (
                [
                  (state.first / 10).toStringAsFixed(1),
                  (state.second / 10).toStringAsFixed(1),
                ],
                context.colorFromStatus(state.status),
              );
            },
            unitOfMeasurement: context.l10n.amperMeasurementUnit,
          ),
          _TwoValuesTableRow.builder(
            parameterName: context.l10n.powerTileTitle,
            builder: () {
              final state =
                  context.select((MotorDataCubit cubit) => cubit.state.power);
              return (
                ['${state.first}', '${state.second}'],
                context.colorFromStatus(state.status),
              );
            },
            unitOfMeasurement: context.l10n.wattMeasurementUnit,
          ),
          _TwoValuesTableRow.builder(
            parameterName: context.l10n.motorsTemperatureTileTitle,
            builder: () {
              final state = context.select(
                (MotorDataCubit cubit) => cubit.state.motorTemperature,
              );
              return (
                ['${state.first}', '${state.second}'],
                context.colorFromStatus(state.status),
              );
            },
            unitOfMeasurement: context.l10n.celsiusMeasurementUnit,
          ),
          _TwoValuesTableRow.builder(
            parameterName: context.l10n.controllersTemperatureTileTitle,
            builder: () {
              final state = context.select(
                (MotorDataCubit cubit) => cubit.state.controllerTemperature,
              );
              return (
                ['${state.first}', '${state.second}'],
                context.colorFromStatus(state.status),
              );
            },
            unitOfMeasurement: context.l10n.celsiusMeasurementUnit,
          ),
          _TwoValuesTableRow.builder(
            parameterName: context.l10n.motorGearTileTitle,
            builder: () {
              final state = context.select(
                (MotorDataCubit cubit) {
                  final gr = cubit.state.gearAndRoll;
                  return (
                    gr.firstMotorGear,
                    gr.secondMotorGear,
                    gr.status,
                  );
                },
              );
              return (
                [
                  state.$1.toLocalizedString(context),
                  state.$2.toLocalizedString(context),
                ],
                context.colorFromStatus(state.$3),
              );
            },
            unitOfMeasurement: '',
          ),
          _TwoValuesTableRow.builder(
            parameterName: context.l10n.motorRollDirectionTileTitle,
            isLast: true,
            builder: () {
              final state = context.select(
                (MotorDataCubit cubit) {
                  final gr = cubit.state.gearAndRoll;
                  return (
                    gr.firstMotorRollDirection,
                    gr.secondMotorRollDirection,
                    gr.status,
                  );
                },
              );
              return (
                [
                  state.$1.toLocalizedString(context),
                  state.$2.toLocalizedString(context),
                ],
                context.colorFromStatus(state.$3),
              );
            },
            unitOfMeasurement: '',
          ),
        ],
      ),
    );
  }
}

extension on MotorGear {
  String toLocalizedString(BuildContext context) {
    return when(
      reverse: () => context.l10n.reverseGear,
      neutral: () => context.l10n.neutralGear,
      drive: () => context.l10n.driveGear,
      low: () => context.l10n.lowGear,
      boost: () => context.l10n.boostGear,
      unknown: () => context.l10n.unknownGear,
    );
  }
}

extension on MotorRollDirection {
  String toLocalizedString(BuildContext context) {
    return when(
      reverse: () => context.l10n.reverseMotorRollDirection,
      unknown: () => context.l10n.unknownMotorRollDirection,
      forward: () => context.l10n.forwardMotorRollDirection,
      stop: () => context.l10n.stopMotorRollDirection,
    );
  }
}

class _ItemHorizontal extends Expanded {
  _ItemHorizontal({required String value, Color? color})
      : super(
          child: Center(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        );
}

class _TwoValuesTableRow extends StatelessWidget {
  const _TwoValuesTableRow({
    required this.parameterName,
    required this.values,
    required this.unitOfMeasurement,
    this.color,
    this.isLast,
  });

  factory _TwoValuesTableRow.builder({
    required String parameterName,
    required String unitOfMeasurement,
    bool? isLast,
    required (List<String>, Color?) Function() builder,
  }) {
    final state = builder();

    return _TwoValuesTableRow(
      parameterName: parameterName,
      values: state.$1,
      color: state.$2,
      unitOfMeasurement: unitOfMeasurement,
      isLast: isLast,
    );
  }

  final String parameterName;
  final List<String> values;
  final String unitOfMeasurement;
  final Color? color;
  final bool? isLast;

  @override
  Widget build(BuildContext context) {
    final motorsCount = context.read<MotorDataCubit>().state.motorsCount;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              parameterName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              unitOfMeasurement,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        Container(
          height: 12,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 0; i < motorsCount; ++i)
              _ItemHorizontal(value: getValue(i), color: color),
          ],
        ),
        if (!(isLast ?? false))
          const Divider(
            height: 24,
          ),
      ],
    );
  }

  String getValue(int i) {
    if (values.isEmpty || i > values.length - 1) return '';
    return values[i];
  }
}
