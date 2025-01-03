import 'package:flutter/material.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';

enum PIconButtonState {
  enabled,
  error,
  success,
  primary;

  R when<R>({
    required R Function() enabled,
    required R Function() error,
    required R Function() success,
    required R Function() primary,
  }) {
    switch (this) {
      case PIconButtonState.enabled:
        return enabled();
      case PIconButtonState.error:
        return error();
      case PIconButtonState.success:
        return success();
      case PIconButtonState.primary:
        return primary();
    }
  }
}

enum PIconButtonSize {
  small,
  normal,
  big;

  R when<R>({
    required R Function() small,
    required R Function() normal,
    required R Function() big,
  }) {
    switch (this) {
      case PIconButtonSize.small:
        return small();
      case PIconButtonSize.normal:
        return normal();
      case PIconButtonSize.big:
        return big();
    }
  }
}

class PIconButton extends StatelessWidget {
  const PIconButton({
    super.key,
    this.state = PIconButtonState.enabled,
    this.size = PIconButtonSize.small,
    this.onPressed,
    required this.icon,
  });

  factory PIconButton.error({
    VoidCallback? onPressed,
    required IconData icon,
    PIconButtonSize size = PIconButtonSize.small,
  }) =>
      PIconButton(
        onPressed: onPressed,
        state: PIconButtonState.error,
        icon: icon,
        size: size,
      );

  @protected
  final IconData icon;

  @protected
  final PIconButtonSize size;

  @protected
  final PIconButtonState state;

  @protected
  final VoidCallback? onPressed;

  @protected
  static const borderRaius = BorderRadius.all(Radius.circular(100));

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = state.when(
      enabled: () => colors.border,
      error: () => colors.error,
      success: () => colors.successPastel,
      primary: () => colors.primary,
    );

    final padding = size.when(
      small: () => 9,
      normal: () => 11,
      big: () => 12,
    );
    final iconSize = size.when(
      small: () => 14,
      normal: () => 16,
      big: () => 23,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRaius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRaius,
            border: Border.all(
              color: color,
              width: 2,
            ),
            color: color.withValues(alpha: .2),
          ),
          child: Padding(
            padding: EdgeInsets.all(padding.toDouble()),
            child: Icon(icon, size: iconSize.toDouble()),
          ),
        ),
      ),
    );
  }
}
