import 'package:auto_route/annotations.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:pixel_app_flutter/app/helpers/platform.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/assets.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/screens/navigator/widgets/default_nav_app_tile.dart';
import 'package:pixel_app_flutter/presentation/screens/navigator/widgets/nav_apps_list_tile.dart';
import 'package:pixel_app_flutter/presentation/screens/navigator/widgets/switch_fast_access_tile.dart';
import 'package:pixel_app_flutter/presentation/screens/navigator/widgets/switch_overlay_tile.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/responsive_padding.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/organisms/title_wrapper.dart';
import 'package:re_seedwork/re_seedwork.dart';
import 'package:re_widgets/re_widgets.dart';

@RoutePage()
class NavigatorScreen extends StatefulWidget {
  const NavigatorScreen({super.key});

  @override
  State<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  final mapsNotifier = _InstalledMapsNotifier();

  @override
  void initState() {
    super.initState();
    mapsNotifier.load();
  }

  @override
  void dispose() {
    mapsNotifier.dispose();
    super.dispose();
  }

  @protected
  static const kNoNavAppsErrorTextStyle = TextStyle(
    height: 1.2,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  @override
  Widget build(BuildContext context) {
    return ResponsivePadding(
      child: TitleWrapper(
        title: context.l10n.navigatorTabTitle,
        body: ListView(
          children: [
            ValueListenableBuilder<_InstalledMapsState>(
              valueListenable: mapsNotifier,
              builder: (context, state, child) {
                return state.maybeWhen(
                  loading: (payload) {
                    return const Center(child: CircularProgressIndicator());
                  },
                  orElse: (payload) {
                    if (payload.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            context.l10n.noNavAppsOnDeviceErrorMessage,
                            style: kNoNavAppsErrorTextStyle.copyWith(
                              color: context.colors.hintText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        NavAppsListTile(apps: payload),
                        DefaultNavAppTile(apps: payload),
                      ],
                    );
                  },
                );
              },
            ),
            //
            const Divider(endIndent: 16, indent: 16, height: 32),
            //
            const SwitchFastAccessTile(),
            //
            if (context.platform.isAndroid) const SwitchOverlayTile(),
          ],
        ),
      ),
    );
  }
}

typedef _InstalledMapsState = AsyncData<List<NavApp>, Object>;

@immutable
final class NavApp {
  const NavApp({
    required this.asset,
    required this.iosPackage,
    required this.androidPackage,
    required this.name,
  });

  final String asset;
  final String name;
  final String? iosPackage;
  final String? androidPackage;

  bool get hasPlatformPackage {
    if (Platform.isAndroid) return androidPackage != null;
    if (Platform.isIOS) return iosPackage != null;
    return false;
  }

  String get platformPackage {
    if (Platform.isAndroid) {
      return androidPackage.checkNotNull('Android package');
    }
    if (Platform.isIOS) return iosPackage.checkNotNull('iOS Package');

    throw UnimplementedError();
  }
}

final class _InstalledMapsNotifier extends ValueNotifier<_InstalledMapsState> {
  _InstalledMapsNotifier() : super(const _InstalledMapsState.initial([]));

  @protected
  static const kAndroidIdentifiers = <NavApp>[
    NavApp(
      androidPackage: 'com.google.android.apps.maps',
      iosPackage: 'comgooglemaps',
      asset: MapIcons.google,
      name: 'Google',
    ),
    NavApp(
      androidPackage: 'com.google.android.apps.mapslite',
      iosPackage: null,
      asset: MapIcons.googleGo,
      name: 'Google Go',
    ),
    NavApp(
      androidPackage: null,
      iosPackage: 'iosamap',
      asset: MapIcons.apple,
      name: 'Apple',
    ),
    NavApp(
      androidPackage: null,
      iosPackage: 'qqmap',
      asset: MapIcons.amap,
      name: 'QQ',
    ),
    NavApp(
      androidPackage: null,
      iosPackage: 'tomtomgo',
      asset: MapIcons.tomtomgo,
      name: 'TomTom Go',
    ),
    NavApp(
      androidPackage: 'com.autonavi.minimap',
      iosPackage: null,
      asset: MapIcons.amap,
      name: 'AutoNavi',
    ),
    NavApp(
      androidPackage: 'com.baidu.BaiduMap',
      iosPackage: 'baidumap',
      asset: MapIcons.baidu,
      name: 'Baidu',
    ),
    NavApp(
      androidPackage: 'com.waze',
      iosPackage: 'waze',
      asset: MapIcons.waze,
      name: 'Waze',
    ),
    NavApp(
      androidPackage: 'ru.yandex.yandexnavi',
      iosPackage: 'yandexnavi',
      asset: MapIcons.yandexNavi,
      name: 'Яндекс Навигатор',
    ),
    NavApp(
      androidPackage: 'ru.yandex.yandexmaps',
      iosPackage: 'yandexmaps',
      asset: MapIcons.yandexMaps,
      name: 'Яндекс Карты',
    ),
    NavApp(
      androidPackage: 'com.citymapper.app.release',
      iosPackage: 'citymapper',
      asset: MapIcons.citymapper,
      name: 'Citymapper',
    ),
    NavApp(
      androidPackage: 'com.mapswithme.maps.pro',
      iosPackage: 'mapswithme',
      asset: MapIcons.mapswithme,
      name: 'Maps.me',
    ),
    NavApp(
      androidPackage: 'net.osmand',
      iosPackage: 'osmandmaps',
      asset: MapIcons.osmand,
      name: 'OsmAnd',
    ),
    NavApp(
      androidPackage: 'net.osmand.plus',
      iosPackage: null,
      asset: MapIcons.osmandplus,
      name: 'OsmAnd Plus',
    ),
    NavApp(
      androidPackage: 'ru.dublgis.dgismobile',
      iosPackage: 'dgis',
      asset: MapIcons.doubleGis,
      name: '2ГИС',
    ),
    NavApp(
      androidPackage: 'com.dss.doublegis',
      iosPackage: null,
      asset: MapIcons.doubleGis,
      name: 'Дубль Гис',
    ),
    NavApp(
      androidPackage: 'com.tencent.map',
      iosPackage: null,
      asset: MapIcons.tencent,
      name: 'Tencent',
    ),
    NavApp(
      androidPackage: 'com.here.app.maps',
      iosPackage: 'here-location',
      asset: MapIcons.here,
      name: 'Here',
    ),
    NavApp(
      androidPackage: 'com.huawei.maps.app',
      iosPackage: null,
      asset: MapIcons.petal,
      name: 'Petal',
    ),
  ];

  Future<void> load() async {
    value = value.inLoading();
    final availableMaps = [
      for (final map in kAndroidIdentifiers)
        if (map.hasPlatformPackage &&
            await LaunchApp.isAppInstalled(
                  androidPackageName: map.androidPackage,
                  iosUrlScheme: map.iosPackage,
                ) ==
                true)
          map,
    ];
    value = AsyncData.success(availableMaps);
  }
}
