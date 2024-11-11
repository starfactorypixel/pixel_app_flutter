import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/led_panel/led_panel.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/mini_progress_indicator.dart';
import 'package:re_widgets/re_widgets.dart';

@RoutePage(name: 'RemoveConfigurationDialogRoute')
class RemoveLEDConfigurationDialog extends StatelessWidget {
  const RemoveLEDConfigurationDialog({super.key, required this.config});

  @protected
  final LEDPanelConfig config;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.removeLEDConfigurationDialogTitle),
      content: Text(
        context.l10n.configurationRemovingConfirmationMessage(
          config.name,
          config.fileId,
        ),
      ),
      actions: [
        TextButton(
          onPressed: context.router.maybePop,
          child: Text(context.l10n.cancelButtonCaption),
        ),
        ElevatedButton(
          onPressed: () {
            context
                .read<RemoveLEDConfigBloc>()
                .add(RemoveLEDConfigEvent.remove(config.id));
          },
          child: BlocConsumer<RemoveLEDConfigBloc, RemoveLEDConfigState>(
            listener: (context, state) {
              state.maybeWhen(
                success: () {
                  context.showSnackBar(
                    context.l10n.configurationWasRemovedMessage(config.name),
                  );
                  context.router.maybePop();
                },
                failure: (error) => context.showSnackBar(
                  context.l10n.errorRemovingConfiguration(config.name),
                ),
                orElse: () {},
              );
            },
            builder: (context, state) {
              return state.maybeWhen(
                loading: () => const MiniProgreesIndicator(),
                orElse: () => Text(context.l10n.removeButtonCaption),
              );
            },
          ),
        ),
      ],
    );
  }
}
