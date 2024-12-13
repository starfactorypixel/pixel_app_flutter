import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/responsive_padding.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/sliver_section_subtitle.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/molecules/cell_sliver_grid_builder.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/organisms/title_wrapper.dart';
import 'package:re_widgets/re_widgets.dart';

@RoutePage()
class MotorScreen extends StatelessWidget {
  const MotorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final motorsCount = context.read<MotorDataCubit>().state.motorsCount;

    return ResponsivePadding(
      child: TitleWrapper(
        title: context.l10n.motorTabTitle,
        body: FadeCustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverSectionSubtitle(subtitle: context.l10n.speedTileTitle),
            //
            CellSliverGridBuilder<MotorDataCubit, MotorDataState,
                Uint16WithStatusBody?>(
              itemCount: motorsCount,
              selector: (state, index) => state.speed.getAt(index),
              contentBuilder: (context, data) {
                return (
                  context.l10n.kmPerHourValue((data?.value ?? 0) ~/ 10),
                  data?.status,
                );
              },
            ),
            //
            SliverSectionSubtitle(subtitle: context.l10n.rpmTileTitle),
            //
            CellSliverGridBuilder<MotorDataCubit, MotorDataState,
                Uint16WithStatusBody?>(
              itemCount: motorsCount,
              selector: (state, index) => state.rpm.getAt(index),
              contentBuilder: (context, data) {
                return (
                  context.l10n.rpmValue(data?.value ?? 0),
                  data?.status,
                );
              },
            ),
            //
            SliverSectionSubtitle(subtitle: context.l10n.voltageTileTitle),
            //
            CellSliverGridBuilder<MotorDataCubit, MotorDataState,
                Uint16WithStatusBody?>(
              itemCount: motorsCount,
              selector: (state, index) => state.voltage.getAt(index),
              contentBuilder: (context, data) {
                return (
                  context.l10n.voltageValue(
                    ((data?.value ?? 0) / 10).toStringAsFixed(1),
                  ),
                  data?.status,
                );
              },
            ),
            //
            SliverSectionSubtitle(subtitle: context.l10n.currentTileTitle),
            //
            CellSliverGridBuilder<MotorDataCubit, MotorDataState,
                Uint16WithStatusBody?>(
              itemCount: motorsCount,
              selector: (state, index) => state.current.getAt(index),
              contentBuilder: (context, data) {
                return (
                  context.l10n.currentValue(
                    ((data?.value ?? 0) / 10).toStringAsFixed(1),
                  ),
                  data?.status,
                );
              },
            ),
            //
            SliverSectionSubtitle(subtitle: context.l10n.powerTileTitle),
            //
            CellSliverGridBuilder<MotorDataCubit, MotorDataState,
                Uint16WithStatusBody?>(
              itemCount: motorsCount,
              selector: (state, index) => state.power.getAt(index),
              contentBuilder: (context, data) {
                return (
                  context.l10n.wattValue(data?.value ?? 0),
                  data?.status,
                );
              },
            ),
            //
            SliverSectionSubtitle(
              subtitle: context.l10n.motorsTemperatureTileTitle,
            ),
            //
            CellSliverGridBuilder<MotorDataCubit, MotorDataState,
                Uint16WithStatusBody?>(
              itemCount: motorsCount,
              selector: (state, index) => state.motorTemperature.getAt(index),
              contentBuilder: (context, data) {
                return (
                  context.l10n.celsiusValue(data?.value ?? 0),
                  data?.status,
                );
              },
            ),
            //
            SliverSectionSubtitle(
              subtitle: context.l10n.controllersTemperatureTileTitle,
            ),
            //
            CellSliverGridBuilder<MotorDataCubit, MotorDataState,
                Uint16WithStatusBody?>(
              itemCount: motorsCount,
              selector: (state, index) {
                return state.controllerTemperature.getAt(index);
              },
              contentBuilder: (context, data) {
                return (
                  context.l10n.celsiusValue(data?.value ?? 0),
                  data?.status,
                );
              },
            ),
            //
            SliverSectionSubtitle(
              subtitle: context.l10n.motorGearTileTitle,
              onInfoPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(context.l10n.motorGearTileTitle),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final gear in MotorGear.values)
                            ListTile(
                              title: Text(context.gearToShortString(gear)),
                              trailing: Text(context.gearToFullString(gear)),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            //
            CellSliverGridBuilder<MotorDataCubit, MotorDataState, MotorGear?>(
              itemCount: motorsCount,
              selector: (state, index) => state.gearAndRoll.getAt(index)?.gear,
              contentBuilder: (context, data) {
                return (context.gearToShortString(data), null);
              },
            ),
            //
            SliverSectionSubtitle(
              subtitle: context.l10n.motorRollDirectionTileTitle,
              onInfoPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(context.l10n.motorRollDirectionTileTitle),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final direction in MotorRollDirection.values)
                            ListTile(
                              title: Text(context.rollToShortString(direction)),
                              trailing:
                                  Text(context.rollToFullString(direction)),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            //
            CellSliverGridBuilder<MotorDataCubit, MotorDataState,
                MotorRollDirection?>(
              itemCount: motorsCount,
              selector: (state, index) =>
                  state.gearAndRoll.getAt(index)?.rollDirection,
              contentBuilder: (context, data) {
                return (context.rollToShortString(data), null);
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

extension on BuildContext {
  String gearToShortString(MotorGear? gear) {
    if (gear == null) return l10n.unknownGearShort;
    return gear.when(
      reverse: () => l10n.reverseGearShort,
      neutral: () => l10n.neutralGearShort,
      drive: () => l10n.driveGearShort,
      low: () => l10n.lowGearShort,
      boost: () => l10n.boostGearShort,
      unknown: () => l10n.unknownGearShort,
    );
  }

  String gearToFullString(MotorGear? gear) {
    if (gear == null) return l10n.unknownGear;
    return gear.when(
      reverse: () => l10n.reverseGear,
      neutral: () => l10n.neutralGear,
      drive: () => l10n.driveGear,
      low: () => l10n.lowGear,
      boost: () => l10n.boostGear,
      unknown: () => l10n.unknownGear,
    );
  }

  String rollToShortString(MotorRollDirection? direction) {
    if (direction == null) return l10n.unknownMotorRollDirectionShort;
    return direction.when(
      reverse: () => l10n.reverseMotorRollDirectionShort,
      unknown: () => l10n.unknownMotorRollDirectionShort,
      forward: () => l10n.forwardMotorRollDirectionShort,
      stop: () => l10n.stopMotorRollDirectionShort,
    );
  }

  String rollToFullString(MotorRollDirection? direction) {
    if (direction == null) return l10n.unknownMotorRollDirection;
    return direction.when(
      reverse: () => l10n.reverseMotorRollDirection,
      unknown: () => l10n.unknownMotorRollDirection,
      forward: () => l10n.forwardMotorRollDirection,
      stop: () => l10n.stopMotorRollDirection,
    );
  }
}
