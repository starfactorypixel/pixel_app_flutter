import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/led_panel/led_panel.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/screens/developer_tools/widgets/integer_list_dialog.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/mini_progress_indicator.dart';
import 'package:re_widgets/re_widgets.dart';

@RoutePage(name: 'AddConfigurationDialogRoute')
class AddLEDConfigurationDialog extends StatefulWidget {
  const AddLEDConfigurationDialog({
    super.key,
    this.defaultMillisValue = 3000,
  });

  @protected
  final int defaultMillisValue;

  @override
  State<AddLEDConfigurationDialog> createState() =>
      _AddLEDConfigurationDialogState();
}

class _AddLEDConfigurationDialogState extends State<AddLEDConfigurationDialog> {
  final shutdownTypeNotifier =
      ValueNotifier<_LEDShutdownType>(_LEDShutdownType.auto);
  late final TextEditingController nameController;
  late final TextEditingController fileIdController;
  late final TextEditingController msController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    fileIdController = TextEditingController();
    msController = TextEditingController.fromValue(
      TextEditingValue(text: widget.defaultMillisValue.toString()),
    );
  }

  @override
  void dispose() {
    shutdownTypeNotifier.dispose();
    nameController.dispose();
    fileIdController.dispose();
    msController.dispose();

    super.dispose();
  }

  void onNewShitdownValue(_LEDShutdownType? type) {
    if (type == null) return;
    shutdownTypeNotifier.value = type;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.addLedConfigurationDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    label: Text(context.l10n.configurationNameInputLabel),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    label: Text(context.l10n.configurationFileIdInputLabel),
                  ),
                  controller: fileIdController,
                  inputFormatters: [OnlyNumbersInputFormatter()],
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(context.l10n.configurationShutdownTypeLabel),
          const SizedBox(height: 16),
          ValueListenableBuilder<_LEDShutdownType>(
            valueListenable: shutdownTypeNotifier,
            builder: (context, value, child) {
              return Row(
                children: [
                  Expanded(
                    child: RadioMenuButton<_LEDShutdownType>(
                      value: _LEDShutdownType.auto,
                      groupValue: value,
                      onChanged: onNewShitdownValue,
                      child: Text(context.l10n.byTimerShutdownType),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: RadioMenuButton<_LEDShutdownType>(
                      value: _LEDShutdownType.manual,
                      groupValue: value,
                      onChanged: onNewShitdownValue,
                      child: Text(context.l10n.manualShutdownType),
                    ),
                  ),
                ],
              );
            },
          ),
          ValueListenableBuilder<_LEDShutdownType>(
            valueListenable: shutdownTypeNotifier,
            builder: (context, value, child) {
              return TextField(
                enabled: value.isAuto,
                controller: msController,
                keyboardType: TextInputType.number,
                inputFormatters: [OnlyNumbersInputFormatter()],
                decoration: InputDecoration(
                  label: Text(context.l10n.shutdownAfterInputLabel),
                  suffix: Text(context.l10n.millisecondsShortMeasurementUnit),
                ),
              );
            },
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: context.router.maybePop,
          child: Text(context.l10n.cancelButtonCaption),
        ),
        BlocConsumer<AddLEDConfigBloc, AddLEDConfigState>(
          listener: (context, state) {
            state.maybeWhen(
              success: () {
                context.showSnackBar(
                  context.l10n.configurationAddedSuccessfullyMessage,
                );
                context.router.maybePop();
              },
              failure: (error) => context
                  .showSnackBar(context.l10n.errorAddingConfigurationMessage),
              orElse: () {},
            );
          },
          builder: (context, state) {
            return ElevatedButton(
              onPressed: () {
                if (state.isLoading) return;
                if (nameController.text.isEmpty) {
                  context.showSnackBar(
                    context.l10n.emptyConfigurationNameErrorMessage,
                  );
                  return;
                }
                final fileId = int.tryParse(fileIdController.text);
                if (fileId == null) {
                  context.showSnackBar(context.l10n.enterFileIDErrorMessage);
                  return;
                }
                if (fileId < 1 || fileId > 255) {
                  context.showSnackBar(
                    context.l10n.incorrectFileIDErrorMessage,
                  );
                  return;
                }

                shutdownTypeNotifier.value.when(
                  auto: () {
                    final ms = int.tryParse(msController.text);

                    if (ms == null) {
                      context.showSnackBar(
                        context.l10n.enterMillisecondsErrorMessage,
                      );
                      return;
                    }

                    context.read<AddLEDConfigBloc>().add(
                          AddLEDConfigEvent.add(
                            LEDPanelConfig.autoShutdown(
                              id: DateTime.now().millisecondsSinceEpoch,
                              fileId: fileId,
                              shutdownTimeMillis: ms,
                              name: nameController.text,
                            ),
                          ),
                        );
                  },
                  manual: () {
                    context.read<AddLEDConfigBloc>().add(
                          AddLEDConfigEvent.add(
                            LEDPanelConfig.manualShutdown(
                              id: DateTime.now().millisecondsSinceEpoch,
                              fileId: fileId,
                              name: nameController.text,
                            ),
                          ),
                        );
                  },
                );
              },
              child: state.maybeWhen(
                loading: () => const MiniProgreesIndicator(),
                orElse: () {
                  return Text(context.l10n.addButtonCaption);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

enum _LEDShutdownType {
  auto,
  manual;

  bool get isAuto => this == _LEDShutdownType.auto;

  T when<T>({
    required T Function() auto,
    required T Function() manual,
  }) {
    switch (this) {
      case _LEDShutdownType.auto:
        return auto();
      case _LEDShutdownType.manual:
        return manual();
    }
  }
}
