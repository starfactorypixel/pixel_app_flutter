import 'package:flutter/widgets.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';

class WheelSteeringSymbolWidget extends StatelessWidget {
  const WheelSteeringSymbolWidget({
    required this.value,
    required this.values,
    required this.screenSize,
    this.inactive = false,
    super.key,
  });

  @protected
  final int value;

  @protected
  final Size screenSize;

  @protected
  final bool inactive;

  @protected
  final List<String> values;

  @protected
  static const kTextStyle = TextStyle(
    height: 1.2,
    fontSize: 32,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  @override
  Widget build(BuildContext context) {
    return Text(
      values.elementAt(value) ?? '',
      style: kTextStyle.copyWith(
        color: inactive ? context.colors.disabled : context.colors.text,
      ),
    );
  }
}
