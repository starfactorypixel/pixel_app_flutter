import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/widgets/app/organisms/screen_data.dart';

class SpeedWidget extends StatelessWidget {
  const SpeedWidget({super.key});

  @protected
  static const speedTextStyle = TextStyle(
    height: 0.88,
    fontSize: 104,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  @protected
  static const kmhTextStyle = TextStyle(
    height: 1.21,
    fontSize: 23,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
  );

  @override
  Widget build(BuildContext context) {
    final isHandset = Screen.of(context).type.isHandset;
    final model = context.select<GeneralDataCubit, IntWithStatus>(
      (value) => value.state.speed,
    );

    return Padding(
      padding: EdgeInsets.only(right: isHandset ? 0 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.speedInfoPanelTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(
            height: 16,
          ),
          FittedBox(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: model.value.toString(),
                    style: speedTextStyle.copyWith(
                      color: AppColors.of(context).textAccent,
                    ),
                  ),
                  TextSpan(
                    text: context.l10n.kmPerHourMeasurenentUnit,
                    style: kmhTextStyle.copyWith(
                      color: AppColors.of(context).textAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
