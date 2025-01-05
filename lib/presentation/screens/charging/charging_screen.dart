import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/screens/charging/widgets/atoms/charging_screen_section_title.dart';
import 'package:pixel_app_flutter/presentation/screens/charging/widgets/molecules/general_cells_voltage.dart';
import 'package:pixel_app_flutter/presentation/screens/charging/widgets/molecules/general_info_section.dart';
import 'package:pixel_app_flutter/presentation/screens/charging/widgets/molecules/mos_and_balancer_temperature.dart';
import 'package:pixel_app_flutter/presentation/screens/charging/widgets/molecules/temperature_sensors_section.dart';
import 'package:pixel_app_flutter/presentation/screens/charging/widgets/molecules/voltage_cells_section.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/responsive_padding.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/sliver_section_subtitle.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/organisms/title_wrapper.dart';
import 'package:re_widgets/re_widgets.dart';

@RoutePage()
class ChargingScreen extends StatelessWidget {
  const ChargingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final batteriesCount =
        context.read<BatteryDataCubit>().state.batteriesCount;
    final isOneBattery = batteriesCount == 1;

    return ResponsivePadding(
      child: TitleWrapper(
        title: context.l10n.batteryTabTitle,
        body: FadeCustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ChargingScreenSectionTitle(
              title: context.l10n.chargingGeneralTabTitle,
            ),
            const GeneralInfoSection(),
            //
            for (var i = 0; i < batteriesCount; i++) ...[
              //
              ChargingScreenSectionTitle(
                title: isOneBattery
                    ? context.l10n.chargingTemperatureTabTitle
                    : context.l10n.chargingTemperatureNTabTitle(i + 1),
              ),
              MOSAndBalancerTemperature(batteryIndex: i),
              SliverSectionSubtitle(
                subtitle: isOneBattery
                    ? context.l10n.sensorsSectionSubtitle
                    : context.l10n.sensorsSectionNSubtitle(i + 1),
              ),
              TemperatureSensorsSection(batteryIndex: i),
              ChargingScreenSectionTitle(
                title: isOneBattery
                    ? context.l10n.chargingVoltageTabTitle
                    : context.l10n.chargingVoltageNTabTitle(i + 1),
              ),
              GeneralCellsVoltage(batteryIndex: i),
              SliverSectionSubtitle(
                subtitle: isOneBattery
                    ? context.l10n.cellsSectionSubtitle
                    : context.l10n.cellsSectionNSubtitle(i + 1),
              ),
              VoltageCellsSection(batteryIndex: i),
            ],
            //
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}
