import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/domain/data_source/models/package_data/package_data.dart';
import 'package:pixel_app_flutter/l10n/l10n.dart';
import 'package:pixel_app_flutter/presentation/routes/main_router.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/wheel_steering_symbol_widget.dart';
import 'package:pixel_app_flutter/presentation/widgets/app/organisms/screen_data.dart';
import 'package:re_widgets/re_widgets.dart';

class WheelSteeringWidget extends StatelessWidget {
  const WheelSteeringWidget({
    super.key,
    required this.screenSize,
  });

  @protected
  final Size screenSize;

  @protected
  static const kHorizontalPadding = 10;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GeneralDataCubit, GeneralDataState, WheelSteering>(
      selector: (state) => state.wheelSteering,
      builder: (context, value) {
        return BlocConsumer<ChangeWheelSteeringBloc, ChangeWheelSteeringState>(
          listenWhen: (previous, current) => current.isFailure,
          listener: (context, state) {
            context.showSnackBar(context.l10n.errorChangeWheelSteeringMessage);
          },
          builder: (context, settingGearState) {
            return InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              onTap: settingGearState.isLoading
                  ? null
                  : () async {
                      final s = Screen.of(context, watch: false);
                      final rect = context.globalPaintBounds;
                      final padding = s.orientation == Orientation.portrait &&
                              s.type == ScreenType.handset
                          ? (
                              null,
                              rect?.top ?? 0,
                              s.size.width -
                                  (rect?.left ?? 0) +
                                  kHorizontalPadding,
                              null
                            )
                          : (
                              (rect?.left ?? 0) +
                                  (rect?.width ?? 0) +
                                  kHorizontalPadding,
                              rect?.top ?? 0,
                              null,
                              null,
                            );

                      final wheelSteeringValue =
                          await context.router.push<WheelSteering>(
                        ChangeWheelSteeringDialogRoute(
                          padding: padding,
                        ),
                      );

                      if (wheelSteeringValue == null || !context.mounted) {
                        return;
                      }

                      context.read<ChangeWheelSteeringBloc>().add(
                            ChangeWheelSteeringEvent.change(wheelSteeringValue),
                          );
                    },
              child: WheelSteeringSymbolWidget(
                value: settingGearState.maybeWhen(
                  orElse: (payload) => value.index,
                  loading: (payload) => payload.index,
                ),
                values: const [
                  'free', // TODO(Alexandr): replace with icons
                  'align',
                  'turn',
                  'diagonal',
                  'blocked',
                ],
                inactive: settingGearState.isLoading,
                screenSize: screenSize,
              ),
            );
          },
        );
      },
    );
  }
}

extension on BuildContext {
  Rect? get globalPaintBounds {
    final renderObject = findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}
