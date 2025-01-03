import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/app/icons.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/interface_button.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/relay_widget.dart';

class MainInterfacesWidget extends StatelessWidget {
  const MainInterfacesWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RelayWidget(
            initiallyEnabled:
                context.read<LightsCubit>().state.leftTurnSignal.payload.isOn,
            switchStream: context
                .read<LightsCubit>()
                .stream
                .map((event) => event.leftTurnSignal.payload.isOn),
            builder: (isOn) {
              return InterfaceButton.withTitle(
                icon: Icons.arrow_circle_left_outlined,
                onPressed: context.read<LightsCubit>().toggleLeftTurnSignal,
                title: context.l10n.leftBlinkerButtonCaption,
                backgroundColor: context.getTurnLightColor(isOn: isOn),
              );
            },
          ),
          BlocSelector<LightsCubit, LightsState, bool>(
            selector: (state) => state.sideBeam.payload.isOn,
            builder: (context, isOn) {
              return InterfaceButton.withTitle(
                icon: PixelIcons.parkingLights,
                onPressed: context.read<LightsCubit>().toggleSideBeam,
                title: context.l10n.parkingLightsButtonCaption,
                backgroundColor: context.getBeamColor(isOn: isOn),
              );
            },
          ),
          BlocSelector<LightsCubit, LightsState, bool>(
            selector: (state) => state.lowBeam.payload,
            builder: (context, isOn) {
              return InterfaceButton.withTitle(
                icon: PixelIcons.lowBeam,
                onPressed: context.read<LightsCubit>().toggleLowBeam,
                title: context.l10n.lowBeamButtonCaption,
                backgroundColor: context.getBeamColor(isOn: isOn),
              );
            },
          ),
          BlocSelector<LightsCubit, LightsState, bool>(
            selector: (state) => state.highBeam.payload,
            builder: (context, isOn) {
              return InterfaceButton.withTitle(
                icon: PixelIcons.highBeam,
                onPressed: context.read<LightsCubit>().toggleHighBeam,
                title: context.l10n.highBeamButtonCaption,
                backgroundColor: context.getBeamColor(isOn: isOn),
              );
            },
          ),
          RelayWidget(
            initiallyEnabled:
                context.read<LightsCubit>().state.rightTurnSignal.payload.isOn,
            switchStream: context
                .read<LightsCubit>()
                .stream
                .map((event) => event.rightTurnSignal.payload.isOn),
            builder: (isOn) {
              return InterfaceButton.withTitle(
                icon: Icons.arrow_circle_right_outlined,
                onPressed: context.read<LightsCubit>().toggleRightTurnSignal,
                title: context.l10n.rightBlinkerButtonCaption,
                backgroundColor: context.getTurnLightColor(isOn: isOn),
              );
            },
          ),

          // InterfaceButton.withTitle(
          //   icon: PixelIcons.belt,
          //   onPressed: () {},
          //   title: context.l10n.leftBeltButtonCaption,
          // ),
          // InterfaceButton.withTitle(
          //   icon: PixelIcons.windshieldBlower,
          //   disabled: true,
          //   onPressed: () {},
          //   title: context.l10n.frontButtonCaption,
          // ),
          // InterfaceButton.withTitle(
          //   icon: PixelIcons.airflow,
          //   onPressed: () {},
          //   title: context.l10n.airflowButtonCaption,
          // ),
          // InterfaceButton(
          //   icon: PixelIcons.fan,
          //   onPressed: () {},
          //   bottom: const FanIndicator(power: 3),
          // ),
          // InterfaceButton.withTitle(
          //   icon: PixelIcons.belt,
          //   title: context.l10n.rightBeltButtonCaption,
          //   onPressed: () {},
          //   disabled: true,
          // ),
        ].map((e) => Expanded(child: e)).toList(),
      ),
    );
  }
}

extension on BuildContext {
  Color? getBeamColor({required bool isOn}) =>
      isOn ? AppColors.of(this).primary.withValues(alpha: .3) : null;

  Color? getTurnLightColor({required bool isOn}) =>
      isOn ? AppColors.of(this).warning.withValues(alpha: .2) : null;
}
