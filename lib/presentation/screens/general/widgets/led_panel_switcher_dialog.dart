import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/led_panel/led_panel.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/routes/main_router.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/countdown_widget.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/error_loading_led_configs.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/mini_progress_indicator.dart';

@RoutePage(name: 'LEDSwitcherDialogRoute')
class LEDPanelSwitcherDialog extends StatelessWidget {
  const LEDPanelSwitcherDialog({super.key});

  @protected
  static const kNoConfigsTextStyle = TextStyle(
    height: 1.2,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  @override
  Widget build(BuildContext context) {
    return Align(
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(const Size(430, double.infinity)),
        child: AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: Text(context.l10n.ledPanelSwitcherDialogTitle),
          content: BlocBuilder<LoadLEDConfigsBloc, LoadLEDConfigsState>(
            builder: (context, state) {
              return state.maybeWhen(
                failure: (error) => const ErrorLoadingLEDConfigsWidget(),
                loading: () => const SizedBox(
                  height: 35,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                orElse: () {
                  final payload = context.watch<LEDConfigsCubit>().state;

                  if (payload.isEmpty) {
                    return Text(
                      context.l10n.noLEDConfigurationsMessage,
                      textAlign: TextAlign.center,
                      style: kNoConfigsTextStyle.copyWith(
                        color: context.colors.text,
                      ),
                    );
                  }

                  final switcherState =
                      context.watch<LEDPanelSwitcherCubit>().state;

                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        payload.length,
                        (index) {
                          final item = payload[index];

                          final current =
                              switcherState.currentOrInitial(item.id);

                          return ListTile(
                            onTap: () {
                              current.whenOrNull(
                                initial: () => context.turnOn(item),
                                on: (_, __) => context.turnOff(),
                                off: () => context.turnOn(item),
                                errorTurningOff: (_) => context.turnOff(),
                                errorTurningOn: (_) => context.turnOn(item),
                              );
                            },
                            tileColor: current.maybeWhen(
                              on: (_, __) => true,
                              turningOff: (_) => true,
                              errorTurningOff: (_) => true,
                              orElse: () => false,
                            )
                                ? context.colors.primary.withValues(alpha: .5)
                                : null,
                            title: Text(item.name),
                            trailing: current.whenOrNull(
                              turningOn: (config, shutdownTime) =>
                                  const MiniProgreesIndicator(),
                              turningOff: (config) {
                                return const MiniProgreesIndicator.onPrimary();
                              },
                              on: (config, shutdownTime) {
                                if (shutdownTime == null) return null;
                                return CountdownWidget(target: shutdownTime);
                              },
                            ),
                            subtitle: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.when(
                                      autoShutdown: (
                                        id,
                                        fileId,
                                        name,
                                        shutdownTimeMillis,
                                      ) =>
                                          context.l10n
                                              .shutdownConfigByTimerMessage(
                                        shutdownTimeMillis,
                                      ),
                                      manualShutdown: (_, __, ___) =>
                                          context.l10n.manualShutdownMessage,
                                    ),
                                  ),
                                ),
                                Text(context.l10n.fileIdMessage(item.fileId)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.router
                    .push(const SettingsFlow(children: [LEDPanelFlow()]));
              },
              child: Text(context.l10n.toTheSettingsButtonCaption),
            ),
            TextButton(
              onPressed: context.router.maybePop,
              child: Text(context.l10n.closeButtonCaption),
            ),
          ],
        ),
      ),
    );
  }
}

extension on BuildContext {
  void turnOn(LEDPanelConfig config) {
    read<LEDPanelSwitcherCubit>().turnOn(config);
    if (mounted) router.maybePop();
  }

  void turnOff() {
    read<LEDPanelSwitcherCubit>().turnOff();
  }
}
