import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:pixel_app_flutter/presentation/app/extensions.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/car_widget.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/gear_widget.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/general_interfaces_state_error_listener.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/led_switcher_button.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/light_state_error_listener.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/overlay_data_sender.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/user_defined_buttons_end_drawer.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/wipers_switcher_button.dart';
import 'package:pixel_app_flutter/presentation/widgets/app/organisms/screen_data.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/responsive_padding.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/molecules/speed_widget.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/molecules/statistic_widget.dart';
import 'package:pixel_app_flutter/presentation/widgets/tablet/molecules/blinker_button.dart';
import 'package:pixel_app_flutter/presentation/widgets/tablet/organisms/tablet_upper_info_panel.dart';

@RoutePage()
class GeneralScreen extends StatelessWidget {
  const GeneralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenData = Screen.of(context);

    return Nested(
      children: const [
        LightStateErrorListener(),
        GeneralInterfacesStateErrorListener(),
        OverlayDataSender(),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawerScrimColor: Colors.transparent,
        endDrawer: const UserDefinedButtonsEndDrawer(),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: Scaffold.of(context).openEndDrawer,
              child: const Icon(Icons.gamepad_rounded),
            );
          },
        ),
        body: ResponsivePadding(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: screenData.whenType(
              orElse: () => const TabletGeneralScreenBody(),
              handset: () => const HandsetGeneralScreenBody(),
            ),
          ),
        ),
      ),
    );
  }
}

class TabletGeneralScreenBody extends StatelessWidget {
  const TabletGeneralScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final height = size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 37),
      child: Stack(
        children: [
          SizedBox(
            width: size.width,
            height: height,
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TabletUpperInfoPanel(),
          ),
          Positioned(
            right: 0,
            left: 0,
            bottom: height * .3,
            child: const CarWidget(),
          ),
          Positioned(
            left: 10,
            bottom: height.flexSize(
              screenFlexRange: (600, 700),
              valueClampRange: (420, 460),
            ),
            child: GearWidget(screenSize: size),
          ),
          const Positioned(
            right: 0,
            top: 0,
            child: BlinkerButton(),
          ),
        ],
      ),
    );
  }
}

class HandsetGeneralScreenBody extends StatelessWidget {
  const HandsetGeneralScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = Screen.of(context);
    final size = screen.size;
    final landscape = screen.isLandscape;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SpeedWidget(),
              if (landscape)
                const StatisticWidget()
              else
                GearWidget(screenSize: size),
            ],
          ),
        ),
        if (!landscape) ...[
          const SizedBox(height: 32),
          const StatisticWidget(useWrap: true),
          const SizedBox(height: 32),
          const LEDSwitcherButton(),
          const SizedBox(height: 16),
          const WipersSwitcherButton(),
        ] else ...[
          GearWidget(screenSize: size),
          const SizedBox(height: 16),
          const LEDSwitcherButton(),
          const SizedBox(height: 16),
          const WipersSwitcherButton(),
        ],
      ],
    );
  }
}
