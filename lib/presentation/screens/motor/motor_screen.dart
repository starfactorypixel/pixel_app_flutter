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
          _ValuesTableRow.builder(
            parameterName: context.l10n.speedTileTitle,
            builder: () {
              final state =
                  context.select((MotorDataCubit cubit) => cubit.state.speed);

              return (
                state
                    .map(
                      (element) => _Value(
                        '${element.value ~/ 10}',
                        context.colorFromStatus(element.status),
                      ),
                    )
                    .toList(),
              );
            },
            unitOfMeasurement: context.l10n.kmPerHourMeasurenentUnit,
          ),
          _ValuesTableRow.builder(
            parameterName: context.l10n.rpmTileTitle,
            builder: () {
              final state =
                  context.select((MotorDataCubit cubit) => cubit.state.rpm);
              return (
                state
                    .map(
                      (element) => _Value(
                        '${element.value}',
                        context.colorFromStatus(element.status),
                      ),
                    )
                    .toList(),
              );
            },
            unitOfMeasurement: context.l10n.rpmMeasurementUnit,
          ),
          _ValuesTableRow.builder(
            parameterName: context.l10n.voltageTileTitle,
            builder: () {
              final state =
                  context.select((MotorDataCubit cubit) => cubit.state.voltage);
              return (
                state
                    .map(
                      (element) => _Value(
                        (element.value / 10).toStringAsFixed(1),
                        context.colorFromStatus(element.status),
                      ),
                    )
                    .toList(),
              );
            },
            unitOfMeasurement: context.l10n.voltMeasurementUnit,
          ),
          _ValuesTableRow.builder(
            parameterName: context.l10n.currentTileTitle,
            builder: () {
              final state =
                  context.select((MotorDataCubit cubit) => cubit.state.current);
              return (
                state
                    .map(
                      (element) => _Value(
                        (element.value / 10).toStringAsFixed(1),
                        context.colorFromStatus(element.status),
                      ),
                    )
                    .toList(),
              );
            },
            unitOfMeasurement: context.l10n.amperMeasurementUnit,
          ),
          _ValuesTableRow.builder(
            parameterName: context.l10n.powerTileTitle,
            builder: () {
              final state =
                  context.select((MotorDataCubit cubit) => cubit.state.power);
              return (
                state
                    .map(
                      (element) => _Value(
                        '${element.value}',
                        context.colorFromStatus(element.status),
                      ),
                    )
                    .toList(),
              );
            },
            unitOfMeasurement: context.l10n.wattMeasurementUnit,
          ),
          _ValuesTableRow.builder(
            parameterName: context.l10n.motorsTemperatureTileTitle,
            builder: () {
              final state = context.select(
                (MotorDataCubit cubit) => cubit.state.motorTemperature,
              );
              return (
                state
                    .map(
                      (element) => _Value(
                        '${element.value}',
                        context.colorFromStatus(element.status),
                      ),
                    )
                    .toList(),
              );
            },
            unitOfMeasurement: context.l10n.celsiusMeasurementUnit,
          ),
          _ValuesTableRow.builder(
            parameterName: context.l10n.controllersTemperatureTileTitle,
            builder: () {
              final state = context.select(
                (MotorDataCubit cubit) => cubit.state.controllerTemperature,
              );
              return (
                state
                    .map(
                      (element) => _Value(
                        '${element.value}',
                        context.colorFromStatus(element.status),
                      ),
                    )
                    .toList(),
              );
            },
            unitOfMeasurement: context.l10n.celsiusMeasurementUnit,
          ),
          _ValuesTableRow.builder(
            parameterName: context.l10n.motorGearTileTitle,
            builder: () {
              final state = context
                  .select((MotorDataCubit cubit) => cubit.state.gearAndRoll);
              return (
                state
                    .map(
                      (element) => _Value(
                        element.motorGear.toLocalizedString(context),
                        context.colorFromStatus(element.status),
                      ),
                    )
                    .toList(),
              );
            },
            unitOfMeasurement: '',
          ),
          _ValuesTableRow.builder(
            parameterName: context.l10n.motorRollDirectionTileTitle,
            isLast: true,
            builder: () {
              final state = context
                  .select((MotorDataCubit cubit) => cubit.state.gearAndRoll);
              return (
                state
                    .map(
                      (element) => _Value(
                        element.motorRollDirection.toLocalizedString(context),
                        context.colorFromStatus(element.status),
                      ),
                    )
                    .toList(),
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

class _Value {
  _Value(this.message, this.color);

  String message;
  Color? color;
}

class _ValuesTableRow extends StatelessWidget {
  const _ValuesTableRow({
    required this.parameterName,
    required this.values,
    required this.unitOfMeasurement,
    this.isLast,
  });

  factory _ValuesTableRow.builder({
    required String parameterName,
    required String unitOfMeasurement,
    bool? isLast,
    required (List<_Value>,) Function() builder,
  }) {
    final state = builder();

    return _ValuesTableRow(
      parameterName: parameterName,
      values: state.$1,
      unitOfMeasurement: unitOfMeasurement,
      isLast: isLast,
    );
  }

  final String parameterName;
  final List<_Value> values;
  final String unitOfMeasurement;
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
              _ItemHorizontal(
                value: getValue(i)?.message ?? '',
                color: getValue(i)?.color,
              ),
          ],
        ),
        if (!(isLast ?? false))
          const Divider(
            height: 24,
          ),
      ],
    );
  }

  _Value? getValue(int i) {
    if (values.isEmpty || i > values.length - 1) return null;
    return values[i];
  }
}
