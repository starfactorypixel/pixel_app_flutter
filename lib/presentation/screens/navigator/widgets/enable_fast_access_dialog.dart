import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';

@RoutePage(name: 'EnableFastAccessDialogRoute')
class EnableFastAccessDialog extends StatelessWidget {
  const EnableFastAccessDialog({super.key});

  @protected
  static const kTitleTextStyle = TextStyle(
    height: 1.2,
    fontSize: 20,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
  );

  @protected
  static const kContentTextStyle = TextStyle(
    height: 1.2,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
  );

  @protected
  static const kContentWarningTextStyle = TextStyle(
    height: 1.2,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w600,
  );

  @protected
  static const kActionButtonTextStyle = TextStyle(
    height: 1.2,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 5,
      shadowColor: context.colors.primary,
      title: Text(
        context.l10n.enableFastAccessDialogTitle,
        style: kTitleTextStyle.copyWith(color: context.colors.text),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.enableFastAccessHint,
            style: kContentTextStyle.copyWith(color: context.colors.text),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.enableFastAccessWarning,
            style: kContentWarningTextStyle.copyWith(
              color: context.colors.text,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(
            context.l10n.cancelButtonCaption,
            style: kActionButtonTextStyle.copyWith(color: context.colors.text),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text(
            context.l10n.enableButtonCaption,
            style: kActionButtonTextStyle.copyWith(
              color: context.colors.primary,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
