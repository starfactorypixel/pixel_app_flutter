import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/icons.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/glue_title.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/icon_button.dart';

class PCloseButton extends StatelessWidget {
  const PCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlueTitle(
      title: context.l10n.closeButtonCaption,
      side: GlueTitleSide.bottom,
      alignment: Alignment.centerLeft,
      child: PIconButton.error(
        size: PIconButtonSize.normal,
        onPressed: context.router.maybePop,
        icon: PixelIcons.close,
      ),
    );
  }
}
