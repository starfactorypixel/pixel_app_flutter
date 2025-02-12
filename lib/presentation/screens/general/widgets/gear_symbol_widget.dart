import 'package:flutter/widgets.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/app/extensions.dart';

class GearSymbolWidget extends StatelessWidget {
  const GearSymbolWidget({
    required this.gear,
    required this.screenSize,
    this.inactive = false,
    super.key,
  });

  @protected
  final MotorGear gear;

  @protected
  final Size screenSize;

  @protected
  final bool inactive;

  @protected
  static const kTextStyle = TextStyle(
    height: 1.2,
    fontSize: 50,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  @override
  Widget build(BuildContext context) {
    return Text(
      context.gearToShortString(gear),
      style: kTextStyle.copyWith(
        color: inactive ? context.colors.disabled : context.colors.text,
        fontSize: screenSize.height.flexSize(
          screenFlexRange: (600, 700),
          valueClampRange: (50, 60),
        ),
      ),
    );
  }
}
