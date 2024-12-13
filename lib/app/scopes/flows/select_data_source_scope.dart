import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:pixel_app_flutter/bootstrap.dart';
import 'package:pixel_app_flutter/data/services/data_source/bluetooth_data_source.dart';
import 'package:pixel_app_flutter/data/services/data_source/demo_data_source.dart';
import 'package:pixel_app_flutter/data/services/data_source/usb_data_source.dart'
    if (dart.library.js) 'package:pixel_app_flutter/data/services/data_source/stubs/usb_data_source.dart';
import 'package:pixel_app_flutter/data/services/data_source/usb_data_source_android.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/icons.dart';
import 'package:pixel_app_flutter/presentation/routes/main_router.dart';
import 'package:provider/provider.dart';
import 'package:re_seedwork/re_seedwork.dart';
import 'package:re_widgets/re_widgets.dart';

@RoutePage(name: 'SelectDataSourceFlow')
class SelectDataSourceScope extends StatelessWidget
    implements AutoRouteWrapper {
  const SelectDataSourceScope({super.key});

  @override
  Widget build(BuildContext context) {
    final isInitial =
        context.select<DataSourceCubit, bool>((bloc) => bloc.state.isInitial);
    final authorizationState =
        context.watch<DataSourceAuthorizationCubit>().state;
    final connectState = context.watch<DataSourceConnectBloc>().state;
    final hardwareCountState = context.watch<GetHardwareCountBloc>().state;

    return AutoRouter.declarative(
      routes: (handler) {
        return [
          const SelectDataSourceGeneralFlow(),
          if (authorizationState.isFailure ||
              connectState.isFailure ||
              hardwareCountState.isFailure)
            ...[]
          else if (isInitial ||
              authorizationState.isLoading ||
              connectState.isLoading ||
              hardwareCountState.isLoading)
            const NonPopableLoadingRoute()
          else
            ...authorizationState.maybeWhen(
              orElse: () => [],
              noSerialNumber: (dswa, deviceId) {
                return [
                  EnterSerialNumberRoute(
                    dswa: dswa,
                    deviceId: deviceId,
                  ),
                ];
              },
            ),
        ];
      },
    );
  }

  @override
  Widget wrappedRoute(BuildContext context) {
    final l10n = context.l10n;
    final platform = context.platform;

    return MultiProvider(
      providers: [
        Provider<List<DataSourceEntity>>(
          create: (context) {
            final devToolsParamsStorage =
                context.read<DeveloperToolsParametersStorage>();
            final getHardwareCountBloc = context.read<GetHardwareCountBloc>();
            final env = context.read<Environment>();

            return [
              if (platform.isAndroid) ...[
                DataSourceEntity(
                  key: USBAndroidDataSource.kKey,
                  title: l10n.usbDataSourceTitle,
                  icon: PixelIcons.usb,
                  initializer: () => USBAndroidDataSource(
                    listDevices: GetIt.I(),
                  ),
                ),
                DataSourceEntity(
                  key: BluetoothDataSource.kKey,
                  title: l10n.bluetoothDataSourceTitle,
                  icon: PixelIcons.bluetooth,
                  initializer: () => BluetoothDataSource(
                    bluetoothSerial: GetIt.I(),
                    connectToAddress: GetIt.I(),
                    permissionRequestCallback: GetIt.I(),
                  ),
                ),
              ] else if (!platform.isIos && !kIsWeb)
                DataSourceEntity(
                  key: USBDataSource.kKey,
                  title: platform.isMacOS
                      ? l10n.usbOrBluetoothDataSourceTitle
                      : l10n.usbDataSourceTitle,
                  icon: PixelIcons.usb,
                  initializer: () => USBDataSource(
                    getAvailablePorts: GetIt.I(),
                  ),
                ),

              //
              DataSourceEntity(
                key: DemoDataSource.kKey,
                title: l10n.demoDataSourceTitle,
                icon: Icons.bug_report,
                initializer: () {
                  return DemoDataSource(
                    generateRandomErrors: () {
                      return env.isDev &&
                          devToolsParamsStorage.data
                              .enableRandomErrorGenerationForDemoDataSource;
                    },
                    updatePeriodMillis: () {
                      return devToolsParamsStorage.data.requestsPeriodInMillis;
                    },
                    hardwareCount: () {
                      return getHardwareCountBloc.state.value.toNullable
                          // When this callback is called,
                          // the hardware count should be already fetched
                          .checkNotNull('hardwareCount');
                    },
                  );
                },
              ),
            ];
          },
        ),
        BlocProvider(create: (context) => SelectDataSourceBloc()),
        BlocProvider(
          create: (context) {
            final bloc = DataSourceConnectBloc(
              dataSourceStorage: context.read<DataSourceStorage>(),
              availableDataSources: {
                for (final entry in context.read<List<DataSourceEntity>>())
                  entry.key: entry.initializer,
              },
            );
            final isInitial = context.read<DataSourceCubit>().state.isInitial;
            if (isInitial) {
              bloc.add(
                const DataSourceConnectEvent.tryConnectWithStorageData(),
              );
            }

            return bloc;
          },
          lazy: false,
        ),
        BlocProvider(
          create: (context) => DataSourceAuthorizationCubit(
            dataSourceStorage: context.read(),
            serialNumberStorage: context.read(),
            shouldWriteDataSourceCallback: () {
              context.read<GetHardwareCountBloc>().add(
                    const GetHardwareCountEvent.get(),
                  );
              return context
                  .read<GetHardwareCountBloc>()
                  .stream
                  .where((state) => state.isExecuted)
                  .map<bool>((state) => state.isSuccess)
                  .first;
            },
          ),
        ),

        // Listeners
        BlocListener<DataSourceAuthorizationCubit,
            DataSourceAuthorizationState>(
          listener: (context, state) {
            final error = state.whenOrNull(
              failure: () => l10n.authorizationErrorMessage,
              authorizationTimeout: () => l10n.authorizationTimeoutErrorMessage,
              initializationTimeout: () =>
                  l10n.auhtorizationInitializationTimeoutErrorMessage,
              errorSavingSerialNumber: () =>
                  l10n.errorSavingSerialNumberMessage,
            );

            if (error != null) context.showSnackBar(error);
          },
        ),
        BlocListener<DataSourceConnectBloc, DataSourceConnectState>(
          listener: (context, state) {
            state.maybeWhen(
              orElse: (payload) {},
              failure: (payload, error) {
                context.showSnackBar(l10n.errorConnectingToDataSourceMessage);
              },
              success: (payload) {
                payload.when(
                  undefined: () {},
                  presented: context
                      .read<DataSourceAuthorizationCubit>()
                      .requestAuthorization,
                );
              },
            );
          },
        ),
        BlocListener<GetHardwareCountBloc, GetHardwareCountState>(
          listenWhen: (previous, current) => current.isFailure,
          listener: (context, state) {
            context.showSnackBar(l10n.errorGettingHardwareCountMessage);
          },
        ),
      ],
      child: this,
    );
  }
}

@immutable
class DataSourceEntity {
  const DataSourceEntity({
    required this.key,
    required this.icon,
    required this.title,
    required this.initializer,
  });

  final String key;
  final String title;
  final IconData icon;
  final DataSource Function() initializer;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DataSourceEntity &&
        other.key == key &&
        other.title == title &&
        other.icon == icon &&
        other.initializer == initializer;
  }

  @override
  int get hashCode =>
      key.hashCode ^ title.hashCode ^ icon.hashCode ^ initializer.hashCode;
}
