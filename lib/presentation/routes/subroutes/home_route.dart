part of '../main_router.dart';

final _homeRoute = AutoRoute(
  path: '',
  page: HomeRoute.page,
  children: [
    AutoRoute(
      path: 'general',
      page: GeneralFlow.page,
      children: [
        AutoRoute(
          path: '',
          page: GeneralRoute.page,
        ),
        CustomRoute<void>(
          path: 'led-switcher-dialog',
          page: LEDSwitcherDialogRoute.page,
          customRouteBuilder: noBarrierDialogRouteBuilder,
        ),
        CustomRoute<void>(
          path: 'suspension-control-dialog',
          page: SuspensionControlDialogRoute.page,
          customRouteBuilder: noBarrierDialogRouteBuilder,
        ),
        CustomRoute<void>(
          path: 'steering-rack-control-dialog',
          page: SteeringRackControlDialogRoute.page,
          customRouteBuilder: noBarrierDialogRouteBuilder,
        ),
      ],
    ),
    AutoRoute(
      path: 'car-info',
      page: CarInfoRoute.page,
    ),
    AutoRoute(
      path: 'navigator',
      page: NavigatorFlow.page,
      children: [
        AutoRoute(
          path: '',
          page: NavigatorRoute.page,
        ),
        CustomRoute<bool>(
          path: 'enable-fast-access',
          page: EnableFastAccessDialogRoute.page,
          customRouteBuilder: noBarrierDialogRouteBuilder,
        ),
      ],
    ),
    AutoRoute(
      path: 'apps',
      page: AppsFlow.page,
      children: [
        AutoRoute(
          path: '',
          page: AppsRoute.page,
        ),
      ],
    ),
    AutoRoute(
      path: 'charging',
      page: ChargingRoute.page,
    ),
    AutoRoute(
      path: 'motor',
      page: MotorRoute.page,
    ),
  ],
);

@RoutePage(name: 'NavigatorFlow')
class NavigatorScope extends AutoRouter {
  const NavigatorScope({super.key});
}
