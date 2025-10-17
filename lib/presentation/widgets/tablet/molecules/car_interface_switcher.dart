import 'package:flutter/widgets.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/icon_button.dart';

enum CarInterfaceSwitcherTitleSide {
  left,
  top,
  right,
  bottom;

  bool get isLeft => this == CarInterfaceSwitcherTitleSide.left;
  bool get istop => this == CarInterfaceSwitcherTitleSide.top;
  bool get isright => this == CarInterfaceSwitcherTitleSide.right;
  bool get isbottom => this == CarInterfaceSwitcherTitleSide.bottom;
}

class CarInterfaceSwitcher extends StatelessWidget {
  const CarInterfaceSwitcher({
    super.key,
    required this.icon,
    required this.state,
    required this.title,
    required this.status,
    this.onPressed,
    this.titleSide = CarInterfaceSwitcherTitleSide.top,
    this.pointerLength = 75,
  });

  @protected
  final CarInterfaceSwitcherTitleSide titleSide;


  @protected
  final PIconButtonState state;

  @protected
  final VoidCallback? onPressed;

  @protected
  final IconData icon;

  @protected
  final String title;

  @protected
  final String status;

  @protected
  final double pointerLength;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = state.when(
      enabled: () => colors.border,
      error: () => colors.error,
      success: () => colors.successPastel,
      primary: () => colors.primary,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (titleSide.isLeft) ...[
          _TitleAndStatus(
            title: title,
            side: titleSide,
            status: status,
          ),
          const SizedBox(width: 16),
        ],
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (titleSide.istop) ...[
              _TitleAndStatus(
                title: title,
                side: titleSide,
                status: status,
              ),
              const SizedBox(height: 16),
            ],
            PIconButton(
              icon: icon,
              size: PIconButtonSize.big,
              state: state,
              onPressed: onPressed,
            ),
            if (titleSide.isbottom) ...[
              const SizedBox(height: 16),
              _TitleAndStatus(
                title: title,
                side: titleSide,
                status: status,
              ),
            ],
          ],
        ),
        if (titleSide.isright) ...[
          const SizedBox(width: 16),
          _TitleAndStatus(
            title: title,
            side: titleSide,
            status: status,
          ),
        ],
      ],
    );
  }
}

class _TitleAndStatus extends StatelessWidget {
  const _TitleAndStatus({
    required this.title,
    required this.side,
    required this.status,
  });

  @protected
  final String title;

  @protected
  final String status;

  @protected
  final CarInterfaceSwitcherTitleSide side;

  @protected
  static const textStyle = TextStyle(
    fontSize: 15,
    height: 1.21,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
  );

  @override
  Widget build(BuildContext context) {
    final align = side.istop || side.isbottom
        ? TextAlign.center
        : side.isLeft
            ? TextAlign.right
            : TextAlign.left;

    return Text(
      '$title\n$status',
      style: textStyle.copyWith(color: AppColors.of(context).text),
      textAlign: align,
    );
  }
}
