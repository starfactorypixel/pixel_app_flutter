import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pixel_app_flutter/app/overlay.dart';
import 'package:pixel_app_flutter/domain/data_source/storages/data_source_storage.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/app/theme.dart';
import 'package:pixel_app_flutter/presentation/app/typography.dart';
import 'package:pixel_app_flutter/presentation/routes/main_router.dart';
import 'package:pixel_app_flutter/presentation/widgets/app/organisms/screen_data.dart';

class App extends StatefulWidget {
  const App({super.key, this.observersBuilder});

  @protected
  final List<NavigatorObserver> Function()? observersBuilder;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final MainRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = MainRouter(
      selectedDataSourceGuard: SelectedDataSourceGuard(
        dataSourceStorage: context.read(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppColors(
      data: const AppColorsData.dark(),
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            theme: MaterialTheme.from(AppColors.of(context)),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            routeInformationParser: _appRouter.defaultRouteParser(),
            routerDelegate: _appRouter.delegate(
              navigatorObservers: widget.observersBuilder ??
                  AutoRouterDelegate.defaultNavigatorObserversBuilder,
              reevaluateListenable: ReevaluateListenable.stream(
                context.read<DataSourceStorage>(),
              ),
            ),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.noScaling),
                child: AppTypography(
                  child: Screen(
                    child: AnnotatedRegion<SystemUiOverlayStyle>(
                      value: SystemUiOverlayStyle(
                        statusBarBrightness: Theme.of(context).brightness,
                      ),
                      child: OverlayManager(
                        child: child ?? const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
