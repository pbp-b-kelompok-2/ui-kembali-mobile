import 'package:material_ui/material_ui.dart';

/// Design tokens, copied from the website's katalog theme.
class AppColors {
  static const canvas = Color(0xFFF7F6F1);
  static const surface = Colors.white;
  static const ink = Color(0xFF17231B);
  static const inkSoft = Color(0xFF667168);
  static const muted = Color(0xFF909990);
  static const line = Color(0xFFDDE3DD);
  static const green = Color(0xFF257A47);
  static const greenDark = Color(0xFF155E35);
  static const greenTint = Color(0xFFDFF1E5);
  static const subtle = Color(0xFFEDF6EF);
  static const yellow = Color(0xFFFFCB05);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    // Buttons are chunky in the design: tall, heavy label.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        foregroundColor: AppColors.green,
        side: const BorderSide(color: AppColors.line),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    chipTheme: const ChipThemeData(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      secondary: AppColors.yellow,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.canvas,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.canvas,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          color: selected ? AppColors.green : AppColors.inkSoft,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? AppColors.green : AppColors.inkSoft);
      }),
    ),
  );
}
