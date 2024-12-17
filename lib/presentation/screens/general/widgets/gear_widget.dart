import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/app/extensions.dart';

class GearWidget extends StatelessWidget {
  const GearWidget({
    super.key,
    required this.screenSize,
  });

  @protected
  final Size screenSize;

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
    return BlocSelector<GeneralDataCubit, GeneralDataState, MotorGear>(
      selector: (state) => state.mergedGear,
      builder: (context, state) {
        final gear = state.when(
          reverse: () => context.l10n.reverseGearShort,
          neutral: () => context.l10n.neutralGearShort,
          drive: () => context.l10n.driveGearShort,
          low: () => context.l10n.lowGearShort,
          boost: () => context.l10n.boostGearShort,
          unknown: () => context.l10n.unknownGearShort,
        );
        return Text(
          gear,
          style: kTextStyle.copyWith(
            color: context.colors.text,
            fontSize: screenSize.height.flexSize(
              screenFlexRange: (600, 700),
              valueClampRange: (50, 60),
            ),
          ),
        );
      },
    );
  }
}
