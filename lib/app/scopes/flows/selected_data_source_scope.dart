import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pixel_app_flutter/bootstrap.dart';
import 'package:pixel_app_flutter/domain/app/storages/logger_storage.dart';
import 'package:pixel_app_flutter/domain/apps/apps.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/extensions/int.dart';
import 'package:pixel_app_flutter/domain/developer_tools/developer_tools.dart';
import 'package:pixel_app_flutter/domain/user_defined_buttons/storages/user_defined_buttons_storage.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/screens/common/loading_screen.dart';
import 'package:pixel_app_flutter/presentation/widgets/app/atoms/gradient_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:re_seedwork/re_seedwork.dart';
import 'package:re_widgets/re_widgets.dart';

@RoutePage(name: 'SelectedDataSourceFlow')
class SelectedDataSourceScope extends AutoRouter {
  const SelectedDataSourceScope({super.key});

  @override
  Widget Function(BuildContext context, Widget content)? get builder {
    return (context, content) {
      String? inValidatedKey;
      String? inRawKey;
      String? inComposedKey;
      String? outKey;
      int? maxKeyLength;

      int getKeysMaxLength() {
        return [inValidatedKey, inRawKey, inComposedKey, outKey]
            .fold<int>(0, (pr, curr) => math.max(curr?.length ?? 0, pr));
      }

      return BlocBuilder<DataSourceCubit, DataSourceState>(
        builder: (context, state) {
          final dswa = state.ds.toNullable;

          if (dswa == null) {
            return GradientScaffold(body: const SizedBox.shrink());
          }

          return MultiProvider(
            key: ValueKey('${dswa.dataSource.key}_${dswa.address}'),
            providers: [
              Provider<DataSource>.value(value: dswa.dataSource),
              Provider<HardwareCount>.value(
                value: context
                    .read<GetHardwareCountBloc>()
                    .state
                    .value
                    .toNullable
                    // should not be null at this point
                    // higher level should handle this case
                    .checkNotNull('Hardware count'),
              ),
              Provider<AppsService>(create: (context) => GetIt.I()),

              // storages
              Provider<NavigatorAppStorage>(create: (context) => GetIt.I()),
              InheritedProvider<UserDefinedButtonsStorage>(
                create: (context) => GetIt.I(),
              ),

              // blocs
              BlocProvider<DataSourceConnectionStatusCubit>(
                create: (context) {
                  if (context.read<Environment>().isDev) {
                    final dataSourceKey = context.read<DataSource>().key;
                    inValidatedKey ??= 'InValidatedPackage($dataSourceKey)';
                    inRawKey ??= 'InRaw($dataSourceKey)';
                    inComposedKey ??= 'InComposedPackage($dataSourceKey)';
                    outKey ??= 'OutPackage($dataSourceKey)';
                    maxKeyLength ??= getKeysMaxLength();
                    context.read<DataSource>().addObserver(
                      (observable) {
                        observable.whenOrNull(
                          incomingPackage: (package) {
                            context
                                .read<ProcessedRequestsExchangeLogsCubit>()
                                .add(
                                  package,
                                  DataSourceRequestDirection.incoming,
                                );
                            context.read<LoggerStorage>().logInfo(
                                  package.toString(withDirection: false),
                                  inValidatedKey.padLeftSpace(maxKeyLength),
                                );
                          },
                          outgoingPackage: (package) {
                            context
                                .read<ProcessedRequestsExchangeLogsCubit>()
                                .add(
                                  package,
                                  DataSourceRequestDirection.outgoing,
                                );
                            context.read<ExchangeConsoleLogsCubit>().addParsed(
                                  package,
                                  DataSourceRequestDirection.outgoing,
                                );
                            context.read<LoggerStorage>().logInfo(
                                  package.toString(withDirection: false),
                                  outKey.padLeftSpace(maxKeyLength),
                                );
                          },
                          rawIncomingBytes: (bytes) {
                            context.read<RawRequestsExchangeLogsCubit>().add(
                                  bytes,
                                  DataSourceRequestDirection.incoming,
                                );
                            context.read<LoggerStorage>().logInfo(
                                  bytes.toFormattedHexString,
                                  inRawKey.padLeftSpace(maxKeyLength),
                                );
                          },
                          rawIncomingPackage: (bytes) {
                            context.read<ExchangeConsoleLogsCubit>().addRaw(
                                  bytes,
                                  DataSourceRequestDirection.incoming,
                                );
                            context.read<LoggerStorage>().logInfo(
                                  bytes.toFormattedHexString,
                                  inComposedKey.padLeftSpace(maxKeyLength),
                                );
                          },
                        );
                      },
                    );
                  }

                  return DataSourceConnectionStatusCubit(
                    dataSource: dswa.dataSource,
                    dataSourceStorage: context.read(),
                    developerToolsParametersStorage: context.read(),
                  )..initHandshake();
                },
                lazy: false,
              ),
              BlocProvider(
                create: (context) => OutgoingPackagesCubit(
                  dataSource: context.read(),
                  developerToolsParametersStorage: context.read(),
                )..subscribeTo(
                    context
                        .read<DeveloperToolsParametersStorage>()
                        .data
                        .subscriptionParameterIds
                        .map(DataSourceParameterId.fromInt)
                        .toSet(),
                  ),
              ),

              BlocProvider(
                create: (context) => LightsCubit(
                  dataSource: context.read(),
                )
                  ..subscribeToSideBeam()
                  ..subscribeToHazardBeam()
                  ..subscribeToHighBeam()
                  ..subscribeToLowBeam()
                  ..subscribeToTurnSignals()
                  ..subscribeToReverseLight()
                  ..subscribeToBrakeLight()
                  ..subscribeToCabinLight(),
                lazy: false,
              ),
              BlocProvider(
                create: (context) => GeneralInterfacesCubit(
                  dataSource: context.read(),
                )
                  ..subscribeToLeftDoor()
                  ..subscribeToRightDoor()
                  ..subscribeToWindscreenWipers(),
              ),
              BlocProvider(
                create: (context) => SuspensionControlBloc(
                  dataSource: context.read(),
                )..add(const SuspensionControlEvent.getMode()),
              ),
              BlocProvider(
                create: (context) {
                  context.read<OutgoingPackagesCubit>().subscribeTo(
                        GeneralDataCubit.kDefaultSubscribeParameters,
                      );
                  return GeneralDataCubit(
                    hardwareCount: context.read<HardwareCount>(),
                    dataSource: context.read(),
                  );
                },
              ),
              BlocProvider(
                create: (context) => ChangeGearBloc(
                  dataSource: context.read(),
                  generalDataCubit: context.read(),
                ),
              ),
              BlocProvider(
                create: (context) =>
                    LaunchAppCubit(appsService: context.read()),
              ),
              BlocProvider(
                create: (context) => NavigatorAppBloc(storage: context.read())
                  ..add(const NavigatorAppEvent.load()),
                lazy: false,
              ),
              BlocProvider(
                create: (context) => NavigatorFastAccessBloc(
                  storage: context.read(),
                )..add(const NavigatorFastAccessEvent.load()),
                lazy: false,
              ),
              BlocProvider(
                create: (context) => IncomingPackagesCubit(
                  context.read(),
                ),
              ),
            ],
            child: BlocConsumer<DataSourceConnectionStatusCubit,
                DataSourceConnectionStatus>(
              listener: (context, state) {
                final error = state.maybeWhen(
                  orElse: () => null,
                  lost: () => context.l10n.dataSourceConnectionLostMessage,
                  notEstablished: () =>
                      context.l10n.failedToConnectToDataSourceMessage,
                  handshakeTimeout: () =>
                      context.l10n.failedToConnectToDataSourceMessage,
                );
                if (error != null) context.showSnackBar(error);
              },
              builder: (context, state) {
                return state.maybeWhen(
                  orElse: () => const LoadingScreen(),
                  connected: () => content,
                );
              },
            ),
          );
        },
      );
    };
  }
}

extension on String? {
  String padLeftSpace(int? width) => this?.padLeft(width ?? 0) ?? '';
}
