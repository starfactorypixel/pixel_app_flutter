import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';

@RoutePage(name: 'SteeringRackControlDialogRoute')
class SteeringRackControlDialog extends StatefulWidget {
  const SteeringRackControlDialog({super.key});

  @override
  State<SteeringRackControlDialog> createState() =>
      _SuspensionControlDialogState();
}

class _SuspensionControlDialogState extends State<SteeringRackControlDialog> {
  late final StreamSubscription<dynamic> streamSubscription;

  @override
  void initState() {
    super.initState();
    streamSubscription = context.read<SteeringRackControlBloc>().stream.listen(
      (state) {
        if (state.isSuccess && mounted) {
          context.router.maybePop();
        }
      },
    );
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.steeringRackModeDialogTitle),
      content: BlocBuilder<SteeringRackControlBloc, SteeringRackControlState>(
        builder: (context, state) {
          return AnimatedSize(
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: state.isLoading,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final mode in SteeringRack.values)
                        RadioListTile<int>(
                          value: mode.id,
                          groupValue: state.payload.id,
                          onChanged: (newMode) {
                            if (newMode == null) return;
                            context
                                .read<SteeringRackControlBloc>()
                                .add(SteeringRackControlEvent.set(mode));
                          },
                          title: Text(
                            mode.when(
                              alignment: () =>
                                  context.l10n.alignmentSteeringRack,
                              blocked: () => context.l10n.blockedSteeringRack,
                              crabWalk: () => context.l10n.crabWalkSteeringRack,
                              free: () => context.l10n.freeSteeringRack,
                              tankTurn: () => context.l10n.tankTurnSteeringRack,
                            ),
                          ),
                        ),
                      state.maybeWhen(
                        orElse: (payload) => const SizedBox.shrink(),
                        failure: (payload, error) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              error?.when(
                                    set: (_) => context.l10n
                                        .errorSettingSteeringRackModeMessage,
                                    get: () => context.l10n
                                        .errorGettingSteeringRackModeMessage,
                                  ) ??
                                  context
                                      .l10n.errorSettingSteeringRackModeMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: context.colors.errorPastel,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (error == null) return;
                                context
                                    .read<SteeringRackControlBloc>()
                                    .add(error);
                              },
                              child: Text(context.l10n.retryButtonCaption),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
