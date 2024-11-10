import 'dart:async';

import 'package:bg_launcher/bg_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:pixel_app_flutter/domain/apps/apps.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/app/theme.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/molecules/statistic_widget.dart';
import 'package:provider/provider.dart';

class OverlayGeneralStatistics extends StatefulWidget {
  const OverlayGeneralStatistics({super.key});

  @override
  State<OverlayGeneralStatistics> createState() =>
      _OverlayGeneralStatisticsState();
}

class _OverlayGeneralStatisticsState extends State<OverlayGeneralStatistics> {
  late final StreamSubscription<void> sub;

  final notifier = ValueNotifier<GeneralDataState>(
    const GeneralDataState.initial(),
  );

  @override
  void initState() {
    super.initState();
    sub = FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is! Map<String, dynamic>) return;

      notifier.value = GeneralDataState.fromMap(event);
    });
  }

  @override
  void dispose() {
    notifier.dispose();
    sub.cancel();
    super.dispose();
  }

  @protected
  static const kSpeedTextStyle = TextStyle(
    height: 1.2,
    fontSize: 45,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  @protected
  static const kKmhTextStyle = TextStyle(
    height: 1.2,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
  );

  @protected
  static const kGearTextStyle = TextStyle(
    height: 1.2,
    fontSize: 40,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  @override
  Widget build(BuildContext context) {
    return AppColors(
      data: const AppColorsData.dark(),
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: MaterialTheme.from(AppColors.of(context)),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Material(
              color: Colors.transparent,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  color: context.colors.background.withOpacity(.5),
                ),
                child: InkWell(
                  onTap: BgLauncher.bringAppToForeground,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ValueListenableBuilder<GeneralDataState>(
                      valueListenable: notifier,
                      builder: (context, value, child) {
                        final power = value.power;
                        final batteryLevel = value.batteryLevel;
                        final odometer = value.odometer;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${value.speed.value}',
                                              style: kSpeedTextStyle.copyWith(
                                                color:
                                                    context.colors.textAccent,
                                              ),
                                            ),
                                            TextSpan(
                                              text: context.l10n
                                                  .kmPerHourMeasurenentUnit,
                                              style: kKmhTextStyle.copyWith(
                                                color:
                                                    context.colors.textAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Column(
                                  children: [
                                    Text(
                                      value.gear.when(
                                        reverse: () =>
                                            context.l10n.reverseGearShort,
                                        neutral: () =>
                                            context.l10n.neutralGearShort,
                                        drive: () =>
                                            context.l10n.driveGearShort,
                                        low: () => context.l10n.lowGearShort,
                                        boost: () =>
                                            context.l10n.boostGearShort,
                                        unknown: () =>
                                            context.l10n.unknownGearShort,
                                      ),
                                      style: kGearTextStyle.copyWith(
                                        color: context.colors.textAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  BatteryLevelStatisticItem(item: batteryLevel),
                                  OdometerStatisticItem(item: odometer),
                                  PowerStatisticItem(item: power),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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

class OverlayManager extends StatefulWidget {
  const OverlayManager({super.key, required this.child});

  @protected
  final Widget child;
  @override
  State<OverlayManager> createState() => _OverlayManagerState();
}

class _OverlayManagerState extends State<OverlayManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final enabled = context.read<OverlayBloc>().state.payload;
    if (!enabled) return;

    final overlayTitle = context.l10n.statisticInfoPanelTitle;
    if (state == AppLifecycleState.paused) {
      if (await FlutterOverlayWindow.isActive()) return;

      final hasPermission = await FlutterOverlayWindow.isPermissionGranted();

      if (!hasPermission) return;

      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: overlayTitle,
        alignment: OverlayAlignment.centerRight,
        visibility: NotificationVisibility.visibilityPublic,
        height: 500,
        width: 500,
      );
      return;
    }

    if (state == AppLifecycleState.resumed) {
      await FlutterOverlayWindow.closeOverlay();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
