import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/routes/main_router.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/models/button_builder.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/widgets/buttons/indicator_button.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/widgets/buttons/one_axis_joystick_button.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/widgets/buttons/send_packages_button.dart';

@RoutePage()
class SelectButtonTypeScreen extends StatelessWidget {
  const SelectButtonTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: context.router.maybePop),
        title: Text(context.l10n.selectButtonTypeScreenTtitle),
      ),
      body: ListView(
        children: [
          _Tile(
            title: context.l10n.simpleButtonCaption,
            buttonBuilder: SendPackagesButton.builder(context),
          ),
          _Tile(
            title: context.l10n.indicatorButtonCaption,
            buttonBuilder: IndicatorButton.builder(),
          ),
          _Tile(
            title: context.l10n.yAxisJoystickButtonCaption,
            buttonBuilder: YAxisJoystickButton.builder(),
          ),
          _Tile(
            title: context.l10n.xAxisJoystickButtonCaption,
            buttonBuilder: XAxisJoystickButton.builder(),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.title,
    required this.buttonBuilder,
  });

  @protected
  final String title;

  @protected
  final ButtonBuilder buttonBuilder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: () {
        context.router.push(
          AddUserDefinedButtonRoute(
            buttonBuilder: buttonBuilder,
            buttonName: title,
          ),
        );
      },
    );
  }
}
