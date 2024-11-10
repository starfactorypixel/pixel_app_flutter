import 'package:flutter/material.dart';
import 'package:re_widgets/re_widgets.dart';

class AnimatedBottomSheet extends StatelessWidget {
  const AnimatedBottomSheet({
    super.key,
    required this.content,
    required this.controller,
    required this.stickUpWidget,
  });

  @protected
  final Widget content;

  @protected
  final Widget stickUpWidget;

  @protected
  final AnimatedBottomSheetController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: controller,
      builder: (context, position, child) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: controller.toBottomOffset,
          child: Stack(
            children: [
              // Bottom sheet content
              Visibility(
                maintainSize: true,
                maintainState: true,
                maintainAnimation: true,
                visible: !controller.isClosed,
                child: Opacity(
                  opacity: controller.mainRangeProgress,
                  child: MeasureSize(
                    onChange: (size) {
                      controller.changeBottomSheetHeight(size.height);
                    },
                    child: content,
                  ),
                ),
              ),
              child ?? const SizedBox.shrink(),
            ],
          ),
        );
      },
      // Show/Hide arrow and interactive(gesture) area
      child: Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: controller.stickUpHeight,
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            controller.changeManuallySheetPosition(details.delta.dy / 1.5);
          },
          onVerticalDragEnd: (_) {
            controller.animateToNearestEdge();
          },
          onTap: controller.toggleBottomSheet,
          child: stickUpWidget,
        ),
      ),
    );
  }
}

class AnimatedBottomSheetController extends AnimationController {
  AnimatedBottomSheetController({
    required super.vsync,
    super.upperBound,
    this.stickUpHeight = 0,
    super.duration = const Duration(milliseconds: 400),
  })  : bottomPadding = 0,
        prevBottomPadding = 0,
        bottomSheetHeight = 0,
        _bottomPaddingSet = false,
        super(lowerBound: 0);

  @protected
  double prevBottomPadding;

  @protected
  double bottomPadding;

  @protected
  double bottomSheetHeight;

  bool _bottomPaddingSet;

  double stickUpHeight;

  bool get isOpened => value == upperBound;

  bool get isClosed => value == minHeightPerc;

  bool get initialized {
    return value >= minHeightPerc && minHeightPerc > 0;
  }

  double get toBottomOffset => -(bottomSheetHeight - value * bottomSheetHeight);

  double get closedBottomSheetHeight => bottomPadding + stickUpHeight;

  double get minHeightPerc {
    if (bottomSheetHeight == 0) return 0;
    return closedBottomSheetHeight / bottomSheetHeight;
  }

  double get mainRangeProgress {
    if (minHeightPerc == 0) return 0;
    if (value < minHeightPerc) return 0;
    return (value - minHeightPerc) / (upperBound - minHeightPerc);
  }

  void toggleBottomSheet() {
    if (isOpened) hide();
    if (isClosed) show();
  }

  void changeBottomSheetHeight(double newHeight) {
    if (newHeight == bottomSheetHeight) return;
    bottomSheetHeight = newHeight;
    _animateInitial();
  }

  void changeBottomPadding(double newBottomPadding) {
    if (_bottomPaddingSet) {
      if (newBottomPadding == bottomPadding) return;
      prevBottomPadding = bottomPadding;
    } else {
      _bottomPaddingSet = true;
    }
    bottomPadding = newBottomPadding;
    _animateInitial();
  }

  void changeManuallySheetPosition(double delta) {
    final percDelta = delta * -1 / bottomSheetHeight;
    value = (value + percDelta).clamp(minHeightPerc, upperBound);
  }

  void animateToNearestEdge() {
    final toBottom = value - minHeightPerc;
    final toTop = upperBound - value;
    if (isAnimating) stop();

    if (toBottom < toTop) {
      animateTo(minHeightPerc);
    } else {
      animateTo(upperBound);
    }
  }

  void show() {
    if (isAnimating) stop();

    if (value == upperBound) return;
    animateTo(upperBound);
  }

  void hide() {
    if (isAnimating) stop();

    if (value == minHeightPerc) return;
    animateTo(minHeightPerc);
  }

  void _animateInitial() {
    if (isAnimating) stop();

    if (bottomSheetHeight == 0) return;

    if (_bottomPaddingSet) {
      animateTo(minHeightPerc);
    }
  }
}
