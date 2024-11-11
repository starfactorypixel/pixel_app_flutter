import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pixel_app_flutter/presentation/app/icons.dart';
import 'package:pixel_app_flutter/presentation/widgets/app/organisms/screen_data.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/organisms/bottom_interfaces_menu.dart';
import 'package:pixel_app_flutter/presentation/widgets/phone/molecules/animated_bottom_sheet.dart';

class BottomSheetInterfacesBuilder extends StatefulWidget {
  const BottomSheetInterfacesBuilder({
    super.key,
    required this.builder,
    required this.enable,
  });

  @protected
  final Widget Function(AnimatedBottomSheetController sheetPositionNotifier)
      builder;

  @protected
  final bool enable;

  @override
  State<BottomSheetInterfacesBuilder> createState() =>
      _BottomSheetInterfacesBuilderState();
}

class _BottomSheetInterfacesBuilderState
    extends State<BottomSheetInterfacesBuilder>
    with SingleTickerProviderStateMixin {
  late final AnimatedBottomSheetController sheetController;

  @override
  void initState() {
    super.initState();
    sheetController = AnimatedBottomSheetController(vsync: this);
    if (mounted) {
      final screenData = Screen.of(context, watch: false);
      final isPortrait = screenData.isPortrait;
      final stickUpHeight = isPortrait ? 47.0 : 42.0;
      sheetController.stickUpHeight = stickUpHeight;
    }
  }

  @override
  void dispose() {
    sheetController.dispose();
    super.dispose();
  }

  @protected
  static const stickInitAnimationDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          widget.builder(sheetController),
          if (widget.enable)
            AnimatedBottomSheet(
              controller: sheetController,
              content: BottomSheetLayer(
                stickUpHeight: sheetController.stickUpHeight,
              ),
              stickUpWidget: AnimatedBuilder(
                animation: sheetController,
                builder: (context, child) {
                  return AnimatedOpacity(
                    duration: stickInitAnimationDuration,
                    opacity: sheetController.initialized ? 1 : 0,
                    child: Transform.rotate(
                      angle: sheetController.mainRangeProgress * math.pi,
                      child: sheetController.mainRangeProgress == 1
                          ? child
                          : UnconstrainedBox(child: child),
                    ),
                  );
                },
                child: const ColoredBox(
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      PixelIcons.showUp,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

@protected
class BottomSheetLayer extends StatelessWidget {
  const BottomSheetLayer({
    super.key,
    required this.stickUpHeight,
  });

  @protected
  final double stickUpHeight;

  @protected
  static const shadowColor = Color(0x26000000);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            offset: Offset(0, -5),
            color: shadowColor,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
          top: stickUpHeight,
        ),
        child: const BottomInterfacesMenu(),
      ),
    );
  }
}
