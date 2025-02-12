import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:pixel_app_flutter/presentation/app/brightness.dart';

/// Defines color palette
abstract class AppColorsData with EquatableMixin {
  @literal
  const AppColorsData();

  /// Creates dark color scheme
  @literal
  const factory AppColorsData.dark() = _AppColorsDataDark;

  factory AppColorsData.fromBrightness(AppBrightness brightness) {
    return brightness.when(
      dark: () => const _AppColorsDataDark(),
      light: () => throw UnimplementedError('Light theme not supported yet'),
    );
  }

  /// The brightness of color palette
  AppBrightness get brightness;

  Color get text;

  Color get textAccent;

  Color get buttonText;

  Color get hintText;

  Color get disabled;

  ColorSwatch<int> get primary;

  Color get primaryAccent;

  Color get primaryPastel;

  Color get onPrimary;

  Color get background;

  Color get error;

  Color get errorAccent;

  Color get errorPastel;

  Color get warning;

  Color get successPastel;

  Color get border;

  Color get borderAccent;

  Color get dialogBarrier;

  @override
  List<Object?> get props => [brightness];
}

class _AppColorsDataDark extends AppColorsData {
  const _AppColorsDataDark();

  @override
  AppBrightness get brightness => AppBrightness.dark;

  @override
  Color get text => const Color(0xFFE8EEED);

  @override
  Color get textAccent => const Color(0xFFFFFFFF);

  @override
  Color get buttonText => const Color(0xFFFAFAFA);

  @override
  Color get hintText => const Color(0xFFBDBDBD);

  @override
  Color get background => const Color(0xFF273137);

  @override
  ColorSwatch<int> get primary {
    return const ColorSwatch(
      0xFF07AFD4,
      {
        50: Color(0xFFE1F5FA),
        100: Color(0xFFB5E7F2),
        200: Color(0xFF83D7EA),
        300: Color(0xFF51C7E1),
        400: Color(0xFF2CBBDA),
        500: Color(0xFF07AFD4),
        600: Color(0xFF06A8CF),
        700: Color(0xFF059FC9),
        800: Color(0xFF0496C3),
        900: Color(0xFF0286B9),
      },
    );
  }

  @override
  Color get primaryAccent => const Color(0xFF29B6F6);

  @override
  Color get primaryPastel => const Color(0xFF81D4FA);

  @override
  Color get onPrimary => const Color(0xFFFFFFFF);

  @override
  Color get disabled => const Color(0xFF5B6B74);

  @override
  Color get error => const Color(0xFFC62828);

  @override
  Color get errorAccent => const Color(0xFFED0332);

  @override
  Color get errorPastel => const Color(0xFFEF5350);

  @override
  Color get warning => const Color.fromARGB(255, 250, 215, 110);

  @override
  Color get successPastel => const Color(0xffA5D6A7);

  @override
  Color get border => const Color(0xFF5A6A73);

  @override
  Color get borderAccent => const Color(0xFF546E7A);

  @override
  Color get dialogBarrier => const Color(0x66000000);
}

class AppColors extends StatelessWidget {
  const AppColors({
    required this.child,
    required this.data,
    super.key,
  });

  @protected
  final Widget child;

  @protected
  final AppColorsData data;

  static AppColorsData of(BuildContext context, {bool watch = true}) {
    final getInheritedElement = context.getElementForInheritedWidgetOfExactType;
    final inheritedColors = getInheritedElement<InheritedColors>();

    if (inheritedColors == null) {
      throw FlutterError(
        'AppColors.of(context) called with a context that does not contain a '
        'AppColorsData',
      );
    }

    if (watch) {
      context.dependOnInheritedElement(inheritedColors);
    }

    return (inheritedColors.widget as InheritedColors).colors.data;
  }

  @override
  Widget build(BuildContext context) {
    return InheritedColors(
      colors: this,
      child: child,
    );
  }
}

@protected
class InheritedColors extends InheritedWidget {
  @literal
  const InheritedColors({
    required super.child,
    required this.colors,
    super.key,
  });
  @protected
  final AppColors colors;

  @override
  bool updateShouldNotify(InheritedColors oldWidget) {
    return colors != oldWidget.colors;
  }
}

extension AppColorsExtension on BuildContext {
  AppColorsData get colors => AppColors.of(this);
}
