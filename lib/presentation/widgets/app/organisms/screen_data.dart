import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

enum ScreenType {
  desktop,
  tablet,
  handset;

  bool get isDesktop => this == ScreenType.desktop;
  bool get isTablet => this == ScreenType.tablet;
  bool get isHandset => this == ScreenType.handset;
}

class FormFactorResponsive extends StatelessWidget {
  const FormFactorResponsive({
    super.key,
    required this.orElse,
    this.tablet,
    this.desktop,
    this.handset,
  });

  @protected
  final Widget Function(ScreenData screenData) orElse;

  @protected
  final Widget Function(ScreenData screenData)? tablet;

  @protected
  final Widget Function(ScreenData screenData)? desktop;

  @protected
  final Widget Function(ScreenData screenData)? handset;

  @override
  Widget build(BuildContext context) {
    final screen = Screen.of(context);

    return screen.whenType<Widget?>(
          orElse: () => orElse(screen),
          tablet: () => tablet?.call(screen),
          handset: () => handset?.call(screen),
          desktop: () => desktop?.call(screen),
        ) ??
        orElse(screen);
  }
}

class Screen extends StatelessWidget {
  const Screen({
    super.key,
    required this.child,
    this.desktopSize = 900,
    this.tabletSize = 600,
    this.handsetSize = 300,
  });

  @protected
  final Widget child;

  @protected
  final double desktopSize;

  @protected
  final double tabletSize;

  @protected
  final double handsetSize;

  static ScreenData of(BuildContext context, {bool watch = true}) {
    final getInheritedElement = context.getElementForInheritedWidgetOfExactType;
    final inheritedAdaptiveWidget = getInheritedElement<InheritedScreenData>();

    if (inheritedAdaptiveWidget == null) {
      throw FlutterError(
        'Screen.of(context) called with a context that does not '
        'contain a ScreenData',
      );
    }

    if (watch) {
      context.dependOnInheritedElement(inheritedAdaptiveWidget);
    }

    return (inheritedAdaptiveWidget.widget as InheritedScreenData).data;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final shortestSize = size.shortestSide;
        final screenType = shortestSize > desktopSize
            ? ScreenType.desktop
            : shortestSize > tabletSize
                ? ScreenType.tablet
                : ScreenType.handset;

        return OrientationBuilder(
          builder: (context, orientation) {
            return InheritedScreenData(
              data: ScreenData(
                size: size,
                type: screenType,
                orientation: orientation,
              ),
              child: child,
            );
          },
        );
      },
    );
  }
}

@immutable
class ScreenData {
  const ScreenData({
    required this.size,
    required this.type,
    required this.orientation,
  });

  final Size size;

  final ScreenType type;

  final Orientation orientation;

  R whenType<R>({
    required R Function() orElse,
    R Function()? desktop,
    R Function()? tablet,
    R Function()? handset,
  }) {
    switch (type) {
      case ScreenType.desktop:
        return desktop?.call() ?? orElse();
      case ScreenType.tablet:
        return tablet?.call() ?? orElse();
      case ScreenType.handset:
        return handset?.call() ?? orElse();
    }
  }

  bool get isPortrait {
    return size.width < size.height;
  }

  bool get isLandscape {
    return !isPortrait;
  }

  @override
  bool operator ==(Object other) {
    return other is ScreenData &&
        size == other.size &&
        type == other.type &&
        orientation == other.orientation;
  }

  @override
  int get hashCode => Object.hash(
        type.hashCode,
        size.hashCode,
        orientation.hashCode,
      );
}

@protected
class InheritedScreenData extends InheritedWidget {
  @literal
  const InheritedScreenData({
    required super.child,
    required this.data,
    super.key,
  });
  @protected
  final ScreenData data;

  @override
  bool updateShouldNotify(InheritedScreenData oldWidget) {
    return data != oldWidget.data;
  }
}
