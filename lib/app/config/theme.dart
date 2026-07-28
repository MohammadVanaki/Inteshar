import 'package:flutter/material.dart';
import 'package:inteshar/app/core/extensions/success_color_theme.dart';

class MyThemes {
  static final ThemeData darkTheme = ThemeData(
    fontFamily: 'dijlah',
    useMaterial3: true,
    dividerTheme:
        const DividerThemeData(color: Color.fromARGB(50, 210, 210, 210)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black87,
        backgroundColor: const Color.fromARGB(255, 254, 194, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      side: WidgetStateBorderSide.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const BorderSide(color: Colors.white, width: 2.0);
        }
        return const BorderSide(color: Colors.white12, width: 1.5);
      }),
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.white38;
      }),
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color.fromARGB(255, 44, 44, 44),
      onPrimary: Color.fromARGB(255, 245, 245, 245),
      surface: Color.fromARGB(255, 55, 55, 55),
      onSurface: Color.fromARGB(255, 245, 245, 245),
      secondary: Color(0xFFFEC200),
      onSecondary: Color.fromARGB(255, 63, 34, 34),
      error: Color.fromARGB(255, 249, 52, 62),
      onError: Color(0xffffb4ab),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      SuccessColorTheme(
        successColor: Colors.lightGreen,
        onSuccessColor: Colors.white,
      ),
    ],
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'dijlah',
    useMaterial3: true,
    dividerTheme: const DividerThemeData(color: Colors.black26),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black87,
        backgroundColor: const Color.fromARGB(255, 254, 194, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      side: WidgetStateBorderSide.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const BorderSide(color: Colors.black45, width: 2.0);
        }
        return const BorderSide(color: Colors.black26, width: 1.5);
      }),
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.black45;
        }
        return Colors.black26;
      }),
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color.fromARGB(255, 255, 255, 255),
      onPrimary: Color.fromARGB(255, 20, 20, 20),
      surface: Color.fromARGB(255, 208, 208, 208),
      onSurface: Color.fromARGB(255, 20, 20, 20),
      secondary: Color.fromARGB(255, 254, 194, 0),
      onSecondary: Color(0xff22323f),
      error: Color.fromARGB(255, 249, 52, 62),
      onError: Color(0xffffb4ab),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color.fromARGB(205, 208, 208, 208),
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      iconColor: Colors.transparent,
      labelStyle: TextStyle(color: Colors.black54),
      floatingLabelStyle:
          TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      hintStyle: TextStyle(color: Colors.black38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          color: Colors.white,
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Color.fromARGB(255, 254, 194, 0),
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Colors.white,
          width: 1.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Colors.red,
          width: 2.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Colors.red,
          width: 2.0,
        ),
      ),
    ),
    extensions: const <ThemeExtension<dynamic>>[
      SuccessColorTheme(
        successColor: Colors.lightGreen,
        onSuccessColor: Colors.white,
      ),
    ],
  );
}
