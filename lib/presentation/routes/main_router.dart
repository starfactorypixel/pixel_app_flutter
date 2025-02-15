import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pixel_app_flutter/app/scopes/flows/apps_scope.dart';
import 'package:pixel_app_flutter/app/scopes/flows/developer_tools_scope.dart';
import 'package:pixel_app_flutter/app/scopes/flows/general_scope.dart';
import 'package:pixel_app_flutter/app/scopes/flows/led_panel_scope.dart';
import 'package:pixel_app_flutter/app/scopes/flows/select_data_source_scope.dart';
import 'package:pixel_app_flutter/app/scopes/flows/selected_data_source_scope.dart';
import 'package:pixel_app_flutter/app/scopes/screens/charging_screen_wrapper.dart';
import 'package:pixel_app_flutter/app/scopes/screens/motor_screen_wrapper.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/domain/led_panel/led_panel.dart';
import 'package:pixel_app_flutter/domain/user_defined_buttons/user_defined_buttons.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/screens/apps/apps_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/car_info/car_info_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/common/loading_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/data_source/data_source_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/data_source/enter_serial_number_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/data_source/select_device_dialog.dart';
import 'package:pixel_app_flutter/presentation/screens/developer_tools/developer_tools_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/developer_tools/packages_exchange_console_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/developer_tools/processed_exhange_logs_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/developer_tools/raw_exchange_logs_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/developer_tools/requests_exchange_logs_filter_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/developer_tools/requests_exchange_logs_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/developer_tools/widgets/integer_list_dialog.dart';
import 'package:pixel_app_flutter/presentation/screens/developer_tools/widgets/slider_dialog.dart';
import 'package:pixel_app_flutter/presentation/screens/general/general_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/change_gear_dialog.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/change_wheel_steering_dialog.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/led_panel_switcher_dialog.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/suspension_control_dialog.dart';
import 'package:pixel_app_flutter/presentation/screens/home/home_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/navigator/navigator_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/navigator/widgets/enable_fast_access_dialog.dart';
import 'package:pixel_app_flutter/presentation/screens/settings/led_panel_screen/add_led_configuration_dialog.dart';
import 'package:pixel_app_flutter/presentation/screens/settings/led_panel_screen/led_panel_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/settings/led_panel_screen/remove_led_configuration_dialog.dart';
import 'package:pixel_app_flutter/presentation/screens/settings/settings_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/add_user_defined_button_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/edit_user_defined_button_screen.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/models/button_builder.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/select_button_type_screen.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/molecules/bool_dialog.dart';

part 'guards/selected_data_source_guard.dart';
part 'main_router.gr.dart';
part 'subroutes/developer_tools_route.dart';
part 'subroutes/home_route.dart';
part 'subroutes/select_data_source_route.dart';
part 'subroutes/settings_route.dart';
part 'subroutes/user_defined_buttons_route.dart';

@AutoRouterConfig(
  replaceInRouteName: 'ScreenWrapper|Screen|PageWrapper|Page|Scope,Route',
)
class MainRouter extends RootStackRouter {
  MainRouter({
    required this.selectedDataSourceGuard,
  });

  @protected
  final SelectedDataSourceGuard selectedDataSourceGuard;

  @override
  List<AutoRoute> get routes => <AutoRoute>[
        CustomRoute<void>(
          path: '/',
          page: SelectedDataSourceFlow.page,
          guards: [selectedDataSourceGuard],
          transitionsBuilder: TransitionsBuilders.fadeIn,
          children: [
            _homeRoute,
            //
            _settingsRoute,
            //
            _selectDataSourceRoute(root: false),
            //
            _userDefinedButtonsRoute,
            //
            _developerToolsRoute(),
            //
            CustomRoute<MotorGear>(
              path: 'change-gear-dialog',
              page: ChangeGearDialogRoute.page,
              customRouteBuilder: dialogRouteBuilder,
            ),
            CustomRoute<WheelSteering>(
              path: 'change-wheel-steering-dialog',
              page: ChangeWheelSteeringDialogRoute.page,
              customRouteBuilder: dialogRouteBuilder,
            ),
          ],
        ),
        //
        _selectDataSourceRoute(),
        //
        _developerToolsRoute(selectedDS: false),
        //
        CustomRoute<void>(
          path: '/loading',
          page: LoadingRoute.page,
          fullscreenDialog: true,
          transitionsBuilder: TransitionsBuilders.noTransition,
        ),
      ];
}

Route<T> dialogRouteBuilder<T>(
  BuildContext context,
  Widget child,
  AutoRoutePage<T> page,
) {
  return DialogRoute(
    settings: page,
    builder: (context) => child,
    context: context,
    barrierColor: context.colors.dialogBarrier,
  );
}

Route<T> noBarrierDialogRouteBuilder<T>(
  BuildContext context,
  Widget child,
  AutoRoutePage<T> page,
) {
  return DialogRoute(
    settings: page,
    builder: (context) => child,
    context: context,
    barrierColor: null,
  );
}
