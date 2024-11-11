import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/led_panel/led_panel.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/routes/main_router.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/countdown_widget.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/mini_progress_indicator.dart';
import 'package:re_widgets/re_widgets.dart';

class LEDSwitcherButton extends StatelessWidget {
  const LEDSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LEDPanelSwitcherCubit, LEDPanelSwitcherState>(
      listener: (context, state) {
        state.whenOrNull(
          errorTurningOff: (config) {
            context.showSnackBar(
              context.l10n.errorTurningOffConfigurationMessage(config.name),
            );
          },
          errorTurningOn: (config) {
            context.showSnackBar(
              context.l10n.errorTurningOnConfigurationMessage(config.name),
            );
          },
        );
      },
      builder: (context, state) {
        final config = state.config;

        return SizedBox(
          width: 120,
          child: FilterChip(
            avatar: state.maybeWhen(
              orElse: () => const Icon(
                Icons.lens_blur_rounded,
                size: 17,
              ),
              turningOff: (_) => const MiniProgreesIndicator.onPrimary(),
              turningOn: (_, __) => const MiniProgreesIndicator(),
            ),
            showCheckmark: false,
            labelStyle:
                const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
            label: Row(
              children: [
                Expanded(
                  child: Text(
                    config?.name ?? context.l10n.switchLEDButtonCaption,
                    textAlign: TextAlign.center,
                  ),
                ),
                state.maybeWhen(
                  orElse: () => const SizedBox.shrink(),
                  on: (config, shutdownTime) {
                    if (shutdownTime == null) return const SizedBox.shrink();
                    return CountdownWidget(
                      target: shutdownTime,
                    );
                  },
                ),
              ],
            ),
            onSelected: (value) {
              if (!value) {
                context.read<LEDPanelSwitcherCubit>().turnOff();
                return;
              }
              context.router.push(const LEDSwitcherDialogRoute());
            },
            selected: state.maybeWhen(
              on: (id, shutdownTime) => true,
              errorTurningOff: (config) => true,
              turningOff: (config) => true,
              orElse: () => false,
            ),
          ),
        );
      },
    );
  }
}
