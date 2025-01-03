import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixel_app_flutter/presentation/app/brightness.dart';
import 'package:pixel_app_flutter/presentation/app/colors.dart';
import 'package:pixel_app_flutter/presentation/app/screen_size_helper.dart';
import 'package:pixel_app_flutter/presentation/screens/user_defined_buttons/widgets/input_fields/data_matchers_input_fileds_widget.dart';
import 'package:pixel_app_flutter/presentation/widgets/app/atoms/gradient_scaffold.dart';
import 'package:pixel_app_flutter/presentation/widgets/common/atoms/nav_bar_colors.dart';

class MaterialTheme {
  static const _fontFamily = 'Inter';

  static ThemeData from(AppColorsData colors) {
    final brightness = colors.brightness.when(
      dark: () => Brightness.dark,
      light: () => Brightness.light,
    );

    return ThemeData(
      extensions: [
        const GradientScaffoldColors(
          start: Color(0xFF435159),
          end: Color(0xFF1F292E),
        ),
        NavBarColors(
          icon: colors.text,
          selectedText: colors.primary,
          selectedBackground: colors.primary,
          divider: const Color(0x1AFAFAFA),
          unselectedText: const Color(0xFFC2C6C8),
          unselectedBackground: const Color(0xFF1A2227),
        ),
        const DataMatchersColors(
          accent: Color(0xFF5898CE),
          statement: Color(0xFFC679DD),
          regular: Color(0xFFABB2BF),
        ),
      ],
      brightness: brightness,
      fontFamily: _fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      dividerTheme: DividerThemeData(
        space: 1.si,
      ),
      canvasColor: colors.background,
      dialogBackgroundColor: colors.background,
      dialogTheme: DialogTheme(
        shadowColor: colors.primary,
      ),
      scaffoldBackgroundColor: colors.background,
      disabledColor: colors.disabled,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: brightness,
        ),
      ),
      //
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.primary,
        onSecondary: colors.onPrimary,
        error: colors.error,
        onError: colors.text,
        surface: colors.background,
        onSurface: colors.text,
        brightness: brightness,
      ),
      primaryColor: colors.primary,
      shadowColor: colors.border,
      dividerColor: colors.border,
      textTheme: TextTheme(
        displayMedium: TextStyle(
          fontSize: 22.fo,
          height: 1.21,
          color: colors.textAccent,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          height: 1.21,
          fontSize: 17.fo,
          color: colors.textAccent,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.fo,
          height: 1.23,
          color: colors.text,
          fontWeight: FontWeight.w500,
        ),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: colors.text,
      ),
      iconTheme: IconThemeData(
        size: 24.si,
        color: colors.text,
      ),
      chipTheme: ChipThemeData(
        labelStyle: TextStyle(
          height: 1.21,
          fontSize: 11.fo,
          fontFamily: _fontFamily,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w500,
          color: colors.buttonText,
        ),
        padding:
            EdgeInsets.symmetric(horizontal: 5.si, vertical: 12.5.si).copyWith(
          bottom: 14.5,
        ),
        elevation: 0,
        shape: ElevatedButtonBorder(colors: colors),
        selectedColor: colors.primaryAccent.withValues(alpha: .15),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: colors.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: colors.onPrimary,
          textStyle: TextStyle(
            height: 1.21,
            fontSize: 11.fo,
            fontFamily: _fontFamily,
            // fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: colors.buttonText,
          ),
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 13.si, vertical: 22.si),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.primaryAccent.withValues(alpha: .15);
            }
            return colors.borderAccent.withValues(alpha: .10);
          }),
          shape: ElevatedButtonBorder(colors: colors),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        // Color from [InputDecorator()._getIconColor()]
        suffixIconColor: Colors.white70,
      ),
    );
  }
}

class ElevatedButtonBorder extends RoundedRectangleBorder
    implements WidgetStateOutlinedBorder {
  const ElevatedButtonBorder({required this.colors});

  @protected
  final AppColorsData colors;

  static const _borderRadius = BorderRadius.all(Radius.circular(32));

  static const border = RoundedRectangleBorder(borderRadius: _borderRadius);

  @override
  OutlinedBorder? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.selected)) {
      return border.copyWith(
        side: BorderSide(
          color: colors.primaryAccent,
          width: 1.si,
        ),
      );
    }
    return border.copyWith(
      side: BorderSide(
        color: colors.borderAccent,
        width: 1.si,
      ),
    );
  }
}
