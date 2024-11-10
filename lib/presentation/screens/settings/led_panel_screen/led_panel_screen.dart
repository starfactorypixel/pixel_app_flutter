import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/led_panel/led_panel.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/routes/main_router.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/error_loading_led_configs.dart';

@RoutePage()
class LEDPanelScreen extends StatelessWidget {
  const LEDPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: context.router.maybePop),
        title: Text(context.l10n.ledPanelScreenTitle),
        bottom: _PreferredSizeTableTitle(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          context.router.push(AddConfigurationDialogRoute());
        },
      ),
      body: BlocBuilder<LoadLEDConfigsBloc, LoadLEDConfigsState>(
        builder: (context, state) {
          return state.maybeWhen(
            orElse: () => const Center(child: CircularProgressIndicator()),
            failure: (error) {
              return const Center(child: ErrorLoadingLEDConfigsWidget());
            },
            success: () {
              final payload = context.watch<LEDConfigsCubit>().state;

              if (payload.isEmpty) {
                return Center(
                  child: Text(context.l10n.noLEDConfigurationsMessage),
                );
              }

              return ListView.builder(
                itemCount: payload.length,
                itemBuilder: (context, index) {
                  final item = payload[index];
                  return ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(item.name),
                        ),
                        Expanded(
                          child: Text(item.fileId.toString()),
                        ),
                        Expanded(
                          child: Text(
                            item.when(
                              manualShutdown: (_, __, ___) =>
                                  context.l10n.manualShutdownType,
                              autoShutdown: (_, __, ___, ____) =>
                                  context.l10n.byTimerShutdownType,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    subtitle: item.when(
                      autoShutdown: (_, __, ___, millis) {
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '$millis '
                            '${context.l10n.millisecondsShortMeasurementUnit}',
                          ),
                        );
                      },
                      manualShutdown: (_, __, ___) => const SizedBox.shrink(),
                    ),
                    trailing: SizedBox(
                      width: 50,
                      child: IconButton(
                        onPressed: () {
                          context.router.push(
                            RemoveConfigurationDialogRoute(config: item),
                          );
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _PreferredSizeTableTitle extends StatefulWidget
    implements PreferredSizeWidget {
  @override
  State<_PreferredSizeTableTitle> createState() =>
      _PreferredSizeTableTitleState();

  @override
  Size get preferredSize => const Size(double.infinity, 50);
}

class _PreferredSizeTableTitleState extends State<_PreferredSizeTableTitle> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(context.l10n.configurationNameTileTitle),
          ),
          Expanded(
            child: Text(
              context.l10n.fileIdTileTitle,
            ),
          ),
          Expanded(
            child: Text(
              context.l10n.shutdownTileTitle,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
      trailing: const SizedBox(width: 50),
    );
  }
}
