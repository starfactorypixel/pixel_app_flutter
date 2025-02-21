import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pixel_app_flutter/domain/data_source/data_source.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/screens/general/widgets/gear_symbol_widget.dart';
import 'package:pixel_app_flutter/presentation/widgets/app/organisms/screen_data.dart';
import 'package:re_seedwork/re_seedwork.dart';

@RoutePage(name: 'ChangeGearDialogRoute')
class ChangeGearDialog extends StatefulWidget {
  const ChangeGearDialog({super.key, required this.padding});

  final (double? left, double? top, double? right, double? bottom) padding;

  @override
  State<ChangeGearDialog> createState() => _ChangeGearDialogState();
}

class _ChangeGearDialogState extends State<ChangeGearDialog> {
  @protected
  static const kBorderRadius = BorderRadius.all(Radius.circular(10));

  @protected
  static const kDialogActiveTimeSecs = 2;

  bool isInit = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: kDialogActiveTimeSecs)).then(
      (value) {
        if (!mounted) return;
        context.router.maybePop<MotorGear>();
      },
    );
  }

  @override
  void didChangeDependencies() {
    if (!isInit && mounted) {
      context.router.maybePop<MotorGear>();
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final size = Screen.of(context).size;

    return Stack(
      children: [
        Positioned(
          left: widget.padding.$1,
          top: widget.padding.$2,
          right: widget.padding.$3,
          bottom: widget.padding.$4,
          child: Material(
            borderRadius: kBorderRadius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: kBorderRadius,
                color: context.colors.primaryAccent.withAlpha(50),
                border: Border.all(
                  color: context.colors.primary,
                  width: 2,
                ),
              ),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (final gear in [
                      MotorGear.drive,
                      MotorGear.low,
                      MotorGear.neutral,
                      MotorGear.reverse,
                    ])
                      InkWell(
                        onTap: () {
                          context.router.maybePop<MotorGear>(gear);
                        },
                        borderRadius: kBorderRadius,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: GearSymbolWidget(
                            gear: gear,
                            screenSize: size,
                          ),
                        ),
                      ),
                  ]
                      .divideBy(
                        Divider(
                          thickness: 1,
                          indent: 6,
                          endIndent: 6,
                          color: context.colors.text,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
