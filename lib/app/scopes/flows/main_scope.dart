import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pixel_app_flutter/bootstrap.dart';
import 'package:pixel_app_flutter/domain/app/storages/logger_storage.dart';
import 'package:pixel_app_flutter/domain/apps/apps.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/developer_tools/developer_tools.dart';
import 'package:pixel_app_flutter/domain/led_panel/led_panel.dart';
import 'package:pixel_app_flutter/domain/settings/settings.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class MainScope extends SingleChildStatelessWidget {
  const MainScope({super.key, required Widget child}) : super(child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        Provider<Environment>(create: (context) => GetIt.I()),
        Provider<PackageInfo>(create: (context) => GetIt.I()),
        // storages
        InheritedProvider<SerialNumberStorage>(create: (context) => GetIt.I()),
        InheritedProvider<DataSourceStorage>(create: (context) => GetIt.I()),
        InheritedProvider<LEDConfigsStorage>(create: (context) => GetIt.I()),
        InheritedProvider<DeveloperToolsParametersStorage>(
          create: (context) => GetIt.I(),
        ),
        InheritedProvider<LoggerStorage>(create: (context) => GetIt.I()),

        // blocs
        BlocProvider(
          create: (context) => DataSourceCubit(
            dataSourceStorage: context.read(),
          ),
        ),

        BlocProvider(
          create: (context) => AlwaysOnDisplayToggleBloc(
            service: GetIt.I(),
            storage: GetIt.I(),
          )..add(const AlwaysOnDisplayToggleEvent.init()),
          lazy: false,
        ),

        BlocProvider(
          create: (context) {
            return OverlayBloc(storage: GetIt.I())
              ..add(const OverlayEvent.load());
          },
          lazy: false,
        ),

        BlocProvider(
          create: (context) => LoadLEDConfigsBloc(storage: context.read())
            ..add(const LoadLEDConfigsEvent.load()),
        ),
        BlocProvider(
          create: (context) => LEDConfigsCubit(storage: context.read()),
        ),
        BlocProvider(create: (context) => GetHardwareCountBloc()),

        if (GetIt.I.get<Environment>().isDev) ...[
          BlocProvider(
            create: (context) => ProcessedRequestsExchangeLogsCubit(),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => RawRequestsExchangeLogsCubit(),
            lazy: false,
          ),
          BlocProvider(
            create: (context) => RequestsExchangeLogsFilterCubit(),
          ),
          BlocProvider(
            create: (context) =>
                ExchangeConsoleLogsCubit(filterCubit: context.read()),
          ),
        ],
      ],
      child: child,
    );
  }
}
