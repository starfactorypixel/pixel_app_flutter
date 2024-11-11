import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pixel_app_flutter/domain/user_defined_buttons/user_defined_buttons.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/routes/main_router.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/widgets/buttons/indicator_button.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/widgets/buttons/one_axis_joystick_button.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/widgets/buttons/send_packages_button.dart';

enum _MenuItem {
  remove,
  edit;

  R when<R>({
    required R Function() remove,
    required R Function() edit,
  }) {
    return switch (this) {
      _MenuItem.remove => remove(),
      _MenuItem.edit => edit(),
    };
  }
}

class ButtonDecorationWrapper extends StatelessWidget {
  const ButtonDecorationWrapper({
    super.key,
    required this.child,
    required this.button,
    this.border,
  });

  @protected
  final UserDefinedButton button;

  @protected
  final Border? border;

  @protected
  final Widget child;

  static const kBorderRadius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        final buttonBox = context.findRenderObject()! as RenderBox;
        final overlay = Navigator.of(context)
            .overlay!
            .context
            .findRenderObject()! as RenderBox;

        const offset = Offset.zero;

        final position = RelativeRect.fromRect(
          Rect.fromPoints(
            buttonBox.localToGlobal(offset, ancestor: overlay),
            buttonBox.localToGlobal(
              buttonBox.size.bottomRight(Offset.zero) + offset,
              ancestor: overlay,
            ),
          ),
          Offset.zero & overlay.size,
        );
        final result = await showMenu(
          context: context,
          position: position,
          items: [
            PopupMenuItem(
              value: _MenuItem.remove,
              child: Text(context.l10n.removeButtonCaption),
            ),
            PopupMenuItem(
              value: _MenuItem.edit,
              child: Text(context.l10n.editButtonCaption),
            ),
          ],
        );
        if (result == null) return;
        result.when(
          remove: () {
            if (!context.mounted) return;
            context.read<RemoveUserDefinedBurronBloc>().add(
                  RemoveUserDefinedBurronEvent.remove(button.id),
                );
          },
          edit: () {
            context.router.push(
              UserDefinedButtonsFlow(
                children: [
                  EditUserDefinedButtonRoute(
                    id: button.id,
                    buttonBuilder: button.when(
                      indicator: IndicatorButton.builder,
                      yAxisJoystick: YAxisJoystickButton.builder,
                      xAxisJoystick: XAxisJoystickButton.builder,
                      sendPackagesButton: (button) =>
                          SendPackagesButton.builder(context, button),
                    ),
                    buttonName: button.when(
                      indicator: (_) => context.l10n.indicatorButtonCaption,
                      yAxisJoystick: (_) =>
                          context.l10n.yAxisJoystickButtonCaption,
                      xAxisJoystick: (_) =>
                          context.l10n.xAxisJoystickButtonCaption,
                      sendPackagesButton: (_) =>
                          context.l10n.simpleButtonCaption,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 50),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: kBorderRadius,
            color: Theme.of(context).colorScheme.surface,
            border: border,
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 1),
                color: Colors.black12,
                spreadRadius: 5,
                blurRadius: 3,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }
}
