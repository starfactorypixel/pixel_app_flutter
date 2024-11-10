import 'package:flutter/widgets.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/app/extensions.dart';

class StatisticItem extends StatelessWidget {
  const StatisticItem({
    super.key,
    required this.icon,
    required this.value,
    this.customColor,
    this.measurementUnit,
  });

  @protected
  final IconData icon;

  @protected
  final String value;

  @protected
  final String? measurementUnit;

  @protected
  final Color? customColor;

  @protected
  static const valueTextStyle = TextStyle(
    height: 1.21,
    fontSize: 14,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  @protected
  static const measurementUnitTextStyle = TextStyle(
    height: 1.21,
    fontSize: 12,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    final color = customColor ?? AppColors.of(context).textAccent;
    final width = MediaQuery.sizeOf(context).width;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: width.flexSize(
            screenFlexRange: (800, 1000),
            valueClampRange: (20, 25),
          ),
          color: color,
        ),
        const SizedBox(
          width: 13,
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$value ',
                style: valueTextStyle.copyWith(
                  color: color,
                  fontSize: width.flexSize(
                    screenFlexRange: (800, 1000),
                    valueClampRange: (14, 16),
                  ),
                ),
              ),
              if (measurementUnit != null)
                TextSpan(
                  text: measurementUnit,
                  style: measurementUnitTextStyle.copyWith(
                    color: color,
                    fontSize: width.flexSize(
                      screenFlexRange: (800, 1000),
                      valueClampRange: (12, 14),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
