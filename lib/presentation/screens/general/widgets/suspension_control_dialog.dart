import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';

@RoutePage(name: 'SuspensionControlDialogRoute')
class SuspensionControlDialog extends StatefulWidget {
  const SuspensionControlDialog({super.key});

  @override
  State<SuspensionControlDialog> createState() =>
      _SuspensionControlDialogState();
}

class _SuspensionControlDialogState extends State<SuspensionControlDialog> {
  late final ManualValueSelectorNotifier manualValueNotifier;
  late final StreamSubscription<dynamic> streamSubscription;

  @override
  void initState() {
    super.initState();
    manualValueNotifier = ManualValueSelectorNotifier(
      context.read<SuspensionControlBloc>().state.payload.maybeWhen(
            orElse: () => (SuspensionMode.kMaxManualValue / 2).roundToDouble(),
            manual: (value) => value.toDouble(),
          ),
    );

    streamSubscription = context.read<SuspensionControlBloc>().stream.listen(
      (state) {
        if (state.isSuccess &&
            (!state.payload.isManual || manualValueNotifier.valueChanged) &&
            mounted) {
          context.router.maybePop();
        }
      },
    );
  }

  @override
  void dispose() {
    manualValueNotifier.dispose();
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.suspensionModeDialogTitle),
      content: BlocBuilder<SuspensionControlBloc, SuspensionControlState>(
        builder: (context, state) {
          return AnimatedSize(
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              key: ValueKey(state.payload.isManual),
              ignoring: state.isLoading,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final mode in SuspensionMode.values)
                        RadioListTile<int>(
                          value: mode.id,
                          groupValue: state.payload.id,
                          onChanged: (newMode) {
                            if (newMode == null) return;
                            context
                                .read<SuspensionControlBloc>()
                                .add(SuspensionControlEvent.switchMode(mode));
                          },
                          title: Text(
                            mode.when(
                              low: () => context.l10n.lowSuspensionMode,
                              highway: () => context.l10n.highwaySuspensionMode,
                              offRoad: () => context.l10n.offRoadSuspensionMode,
                              manual: (_) => context.l10n.manualSuspensionMode,
                            ),
                          ),
                        ),
                      state.payload.maybeWhen(
                        orElse: () => const SizedBox.shrink(),
                        manual: (blocValue) {
                          return ValueListenableBuilder<double>(
                            valueListenable: manualValueNotifier,
                            builder: (context, sliderValue, child) {
                              final value =
                                  manualValueNotifier.changingManualValue
                                      ? sliderValue
                                      : blocValue.toDouble();
                              return Row(
                                children: [
                                  Text(
                                    '${value.toInt()}'.padLeft(3, ' '),
                                    style: const TextStyle(
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: value,
                                      max: SuspensionMode.kMaxManualValue
                                          .toDouble(),
                                      divisions: SuspensionMode.kMaxManualValue,
                                      onChanged: (value) {
                                        manualValueNotifier.value = value;
                                      },
                                      onChangeEnd: (value) {
                                        context
                                            .read<SuspensionControlBloc>()
                                            .add(
                                              SuspensionControlEvent.setManual(
                                                value.toInt(),
                                              ),
                                            );
                                        manualValueNotifier.onChangeEnd();
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      state.maybeWhen(
                        orElse: (payload) => const SizedBox.shrink(),
                        failure: (payload, error) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              error?.when(
                                    getMode: () => context
                                        .l10n.errorGettingSuspensionModeMessage,
                                    switchMode: (_) => context.l10n
                                        .errorSwitchingSuspensionModeMessage,
                                    getManual: () => context
                                        .l10n.errorGettingManualValueMessage,
                                    setManual: (_) => context
                                        .l10n.errorSettingManualValueMessage,
                                  ) ??
                                  context
                                      .l10n.errorSwitchingSuspensionModeMessage,
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
                                    .read<SuspensionControlBloc>()
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

class ManualValueSelectorNotifier extends ValueNotifier<double> {
  ManualValueSelectorNotifier(super.value)
      : changingManualValue = false,
        valueChanged = false;

  bool changingManualValue;
  bool valueChanged;

  @override
  set value(double v) {
    changingManualValue = true;
    super.value = v;
  }

  void onChangeEnd() {
    changingManualValue = false;
    valueChanged = true;
  }
}
