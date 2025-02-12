part of '../main_router.dart';

final _settingsRoute = AutoRoute(
  page: SettingsFlow.page,
  path: 'settings',
  children: [
    AutoRoute(
      initial: true,
      page: SettingsRoute.page,
    ),
    AutoRoute(
      path: 'led-panel',
      page: LEDPanelFlow.page,
      children: [
        AutoRoute(
          initial: true,
          page: LEDPanelRoute.page,
        ),
        CustomRoute<void>(
          page: AddConfigurationDialogRoute.page,
          path: 'add-configuration',
          customRouteBuilder: noBarrierDialogRouteBuilder,
        ),
        CustomRoute<void>(
          page: RemoveConfigurationDialogRoute.page,
          path: 'remove-configuration',
          customRouteBuilder: noBarrierDialogRouteBuilder,
        ),
      ],
    ),
  ],
);

@RoutePage(name: 'SettingsFlow')
class SettingsScope extends AutoRouter {
  const SettingsScope({super.key});
}
