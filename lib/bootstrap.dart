// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pixel_app_flutter/app/helpers/app_bloc_observer.dart';
import 'package:pixel_app_flutter/app/helpers/crashlytics_helper.dart';
import 'package:pixel_app_flutter/app/helpers/logger_route_observer.dart';
import 'package:pixel_app_flutter/app/overlay.dart';
import 'package:pixel_app_flutter/app/scopes/flows/main_scope.dart';
import 'package:pixel_app_flutter/bootstrap.config.dart';
import 'package:pixel_app_flutter/data/services/apps_service.dart';
import 'package:pixel_app_flutter/data/services/data_source/bluetooth_data_source.dart';
import 'package:pixel_app_flutter/data/services/data_source/usb_data_source.dart';
import 'package:pixel_app_flutter/data/services/data_source/usb_data_source_android.dart';
import 'package:pixel_app_flutter/data/services/installed_apps_mock.dart';
import 'package:pixel_app_flutter/data/storages/logger_storage.dart';
import 'package:pixel_app_flutter/domain/app/app.dart';
import 'package:pixel_app_flutter/domain/user_defined_buttons/user_defined_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_serial/usb_serial.dart';

enum Environment {
  prod(prodKey),
  stg(stgKey),
  dev(devKey);

  const Environment(this.value);

  static const prodKey = 'prod';
  static const stgKey = 'stg';
  static const devKey = 'dev';

  final String value;

  bool get isDev => this == Environment.dev;
  bool get isStg => this == Environment.stg;
  bool get isProd => this == Environment.prod;

  R when<R>({
    required R Function() prod,
    required R Function() stg,
    required R Function() dev,
  }) {
    switch (this) {
      case Environment.prod:
        return prod();
      case Environment.stg:
        return stg();
      case Environment.dev:
        return dev();
    }
  }
}

void runOverlay() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const OverlayGeneralStatistics());
}

Future<void> bootstrap(
  FutureOr<Widget> Function(List<NavigatorObserver> Function() observersBuilder)
      builder,
  Environment env,
) async {
  late final LoggerStorage loggerStorage;

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await configureDependencies(env);

      loggerStorage = GetIt.I<LoggerStorage>();

      // SizeProvider.initialize(sizeConverter:
      // const SizeConverter(fo: fo, si: si));

      final initFirebase =
          Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

      if (initFirebase) {
        await Firebase.initializeApp();

        await CrashlyticsHelper.initialize();

        await FirebaseAnalytics.instance
            .setAnalyticsCollectionEnabled(kReleaseMode);
      }

      FlutterError.onError = CrashlyticsHelper.recordFlutterError;

      Bloc.observer = AppBlocObserver(
        onStateChange: (change) {
          // loggerStorage.logInfo(
          //   '${change.currentState} -> ${change.nextState}',
          //   'BlocChangeState',
          // );
        },
        onErrorOcurred: (error, stackTrace) {
          loggerStorage.logSevere(
            '$error\nStackTrace:\n$stackTrace',
            'BlocError',
          );
        },
      );

      runApp(
        MainScope(
          child: await builder(
            () => [
              LoggerRouteObserver(
                onNewScreen: (screenName) {
                  loggerStorage.logInfo(
                    'Navigation to: $screenName',
                    'RouteObserver',
                  );
                },
              ),
              //
              if (initFirebase)
                FirebaseAnalyticsObserver(
                  analytics: FirebaseAnalytics.instance,
                  routeFilter: (route) {
                    return route is PageRoute || route is DialogRoute;
                  },
                ),
            ],
          ),
        ),
      );
    },
    (error, stack) {
      CrashlyticsHelper.recordError(error, stack);
      loggerStorage.logSevere(
        '$error\nTrace: $stack',
        'RunZonedError',
      );
    },
  );
}

@InjectableInit()
Future<void> configureDependencies(Environment env) async {
  final getIt = GetIt.instance;

  await _configureManualDeps(getIt, env);
  getIt.init(environment: env.value);
}

Future<void> _configureManualDeps(GetIt getIt, Environment env) async {
  final gh = GetItHelper(getIt);

  await gh.factoryAsync<SharedPreferences>(
    SharedPreferences.getInstance,
    preResolve: true,
  );

  gh
    ..factory<Environment>(() => env)
    ..factory<FlutterBluetoothSerial>(() => FlutterBluetoothSerial.instance)
    ..factory<GetInstalledAppsCallback>(() {
      if (Platform.isAndroid) return InstalledApps.getInstalledApps;
      return InstalledAppsMock.getInstalledApps;
    })
    ..factory<StartAppCallback>(() {
      if (Platform.isAndroid) return InstalledApps.startApp;
      return InstalledAppsMock.startApp;
    })
    ..factory<GetBluetoothConnectionCallback>(
      () => BluetoothConnection.toAddress,
    )
    ..factory<BluetoothPermissionRequestCallback>(
      () => _bluetoothPermissionRequest,
    )
    ..factory<FlutterSecureStorage>(() => const FlutterSecureStorage())
    // Android
    ..factory<ListUsbDevicesCallback>(() => UsbSerial.listDevices)
    // MacOS, Linux, Windows
    ..factory<ListUsbPortsCallback>(() => () => SerialPort.availablePorts)
    ..singleton<LoggerStorage>(() => LoggerStorageImpl(prefs: gh.getIt()))
    ..factory<List<UserDefinedButtonSerializer>>(
      () => const [
        IndicatorUserDefinedButtonSerializer(),
        YAxisJoystickUserDefinedButtonSerializer(),
        XAxisJoystickUserDefinedButtonSerializer(),
        SendPackagesUserDefinedButtonSerializer(),
      ],
    );

  await gh.factoryAsync(
    PackageInfo.fromPlatform,
    preResolve: true,
  );
}

Future<bool> _bluetoothPermissionRequest() async {
  final permission = await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
  ].request();
  return permission.values.every((element) => element.isGranted);
}
