import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixel_app_flutter/domain/app/app.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/developer_tools/developer_tools.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/routes/main_router.dart';
import 'package:share_plus/share_plus.dart';

@RoutePage()
class DeveloperToolsScreen extends StatelessWidget {
  const DeveloperToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: context.router.maybePop),
        title: Text(context.l10n.developerToolsScreenTitle),
      ),
      body:
          BlocBuilder<DeveloperToolsParametersCubit, DeveloperToolsParameters>(
        builder: (context, state) {
          return ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: [
                ListTile(
                  title: Text(context.l10n.protocolVersionLabel),
                  trailing: DropdownButton<DataSourceProtocolVersion>(
                    value: state.protocolVersion,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(
                        value: DataSourceProtocolVersion.subscription,
                        child: Text(
                          context.l10n.subscriptionProtocolVersionLabel,
                        ),
                      ),
                      DropdownMenuItem(
                        value: DataSourceProtocolVersion.periodicRequests,
                        child: Text(
                          context.l10n.periodicRequestsProtocolVersionLabel,
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      context
                          .read<DeveloperToolsParametersCubit>()
                          .update(protocolVersion: value);
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    context.l10n.requestPeriodInMillisListTileLabel,
                  ),
                  subtitle: Text(
                    context.l10n.requestPeriodInMillisListTileSubtitle,
                  ),
                  trailing: Text('${state.requestsPeriodInMillis}'),
                  onTap: () {
                    context.router
                        .push<int>(
                      ChangeRequestPeriodDialogRoute(
                        initialValue: state.requestsPeriodInMillis,
                        title: context.l10n.requestPeriodInMillisListTileLabel,
                      ),
                    )
                        .then((value) {
                      if (value != null && context.mounted) {
                        context
                            .read<DeveloperToolsParametersCubit>()
                            .update(requestsPeriodInMillis: value);
                      }
                    });
                  },
                ),
                if (context.hasProvider<BlocProvider<OutgoingPackagesCubit>>())
                  ListTile(
                    title: Text(
                      context.l10n.whichParametersToSubscribeToListTileLabel,
                    ),
                    onTap: () {
                      context.router
                          .push<List<int>>(
                        ChangeParametersSubscriptionDialogRoute(
                          initialChoosedOptions: [
                            ...context
                                .read<OutgoingPackagesCubit>()
                                .state
                                .subscriptionParameterIds,
                          ],
                          title: context
                              .l10n.whichParametersToSubscribeToListTileLabel,
                          alwasysVisibleOptions: DataSourceParameterId.all
                              .map((e) => e.value)
                              .toList(),
                          validator: (integer) {
                            if (integer < 0 || integer > 0xFFFF) {
                              return context.l10n.parameterIdLimitsMessage;
                            }
                            return null;
                          },
                        ),
                      )
                          .then((value) {
                        if (value != null && context.mounted) {
                          context
                              .read<DeveloperToolsParametersCubit>()
                              .update(subscriptionParameterIds: value.toSet());
                        }
                      });
                    },
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 70),
                      child: BlocSelector<OutgoingPackagesCubit,
                          DeveloperToolsParameters, Set<int>>(
                        selector: (state) => state.subscriptionParameterIds,
                        builder: (context, state) => Text(
                          state.join(', '),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                  ),
                SwitchListTile(
                  value: state.enableHandshakeResponse,
                  title:
                      Text(context.l10n.enableHandshakeResponseListTileLabel),
                  onChanged: (value) {
                    context.read<DeveloperToolsParametersCubit>().update(
                          enableHandshakeResponse: value,
                        );
                  },
                ),
                if (state.enableHandshakeResponse)
                  ListTile(
                    title: Text(
                      context.l10n.sendHandshakeResponseTimeoutListTileLabel,
                    ),
                    onTap: () {
                      context.router
                          .push<int>(
                        ChangeHandshakeResponseTimeoutDialogRoute(
                          initialValue: state.handshakeResponseTimeoutInMillis,
                          title: context
                              .l10n.sendHandshakeResponseTimeoutListTileLabel,
                        ),
                      )
                          .then((value) {
                        if (value != null && context.mounted) {
                          context.read<DeveloperToolsParametersCubit>().update(
                                handshakeResponseTimeoutInMillis: value,
                              );
                        }
                      });
                    },
                    trailing: Text('${state.handshakeResponseTimeoutInMillis}'),
                  ),
                SwitchListTile(
                  value: state.enableRandomErrorGenerationForDemoDataSource,
                  title: Text(
                    context.l10n
                        .enableDemoDataSourceRandomErrorGenerationListTileLabel,
                  ),
                  onChanged: (value) {
                    context.read<DeveloperToolsParametersCubit>().update(
                          enableRandomErrorGenerationForDemoDataSource: value,
                        );
                  },
                ),
                ListTile(
                  title: Text(context.l10n.requestsExchangeLogsListTileLabel),
                  onTap: () {
                    context.router.push(const RequestsExchangeLogsFlow());
                  },
                ),
                if (context.read<DataSourceCubit>().state.ds.isPresent)
                  ListTile(
                    title:
                        Text(context.l10n.packagesExchangeConsoleScreenTitle),
                    onTap: () {
                      context.router.push(const PackagesExchangeConsoleRoute());
                    },
                  ),
                ListTile(
                  title: Text(context.l10n.exportLogsListTileLabel),
                  onTap: () async {
                    final tempDir = await getTemporaryDirectory();
                    final items = GetIt.I<LoggerStorage>().data;
                    final string = items.map((e) => e.toString()).join('\n');
                    final path = '${tempDir.path}/log_${DateTime.now()}.txt';
                    final f = File(path)..writeAsStringSync(string);
                    final file = XFile(f.path);
                    await Share.shareXFiles([file]);
                    f.deleteSync();
                  },
                ),
              ],
            ).toList(),
          );
        },
      ),
    );
  }
}

extension on BuildContext {
  bool hasProvider<T extends Widget>() {
    return findAncestorWidgetOfExactType<T>() != null;
  }
}
