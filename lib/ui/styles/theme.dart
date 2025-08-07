import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(AppConstants.primaryBlue),
        brightness: Brightness.light,
        primary: const Color(AppConstants.primaryBlue),
        secondary: const Color(AppConstants.purple),
        surface: const Color(AppConstants.cardBackground),
        background: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF8FAFC),
            const Color(0xFFF1F5F9),
          ],
        ).colors.first,
      ),

      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: Color(AppConstants.darkGray),
          letterSpacing: -1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Color(AppConstants.darkGray),
          letterSpacing: -0.8,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(AppConstants.darkGray),
          letterSpacing: -0.4,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(AppConstants.darkGray),
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(AppConstants.darkGray),
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(AppConstants.darkGray),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(AppConstants.darkGray),
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(AppConstants.textGray),
          height: 1.5,
        ),
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 8,
        backgroundColor: Colors.white.withOpacity(0.95),
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(AppConstants.darkGray),
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(AppConstants.darkGray),
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(
          color: Color(AppConstants.primaryBlue),
          size: 26,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 6,
          shadowColor: const Color(AppConstants.primaryBlue).withOpacity(0.3),
          backgroundColor: const Color(AppConstants.primaryBlue),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.pressed)) {
              return const Color(AppConstants.secondaryBlue);
            }
            return const Color(AppConstants.primaryBlue);
          }),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 4,
          shadowColor: const Color(AppConstants.purple).withOpacity(0.25),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          side: const BorderSide(
            color: Color(AppConstants.primaryBlue),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ).copyWith(
          side: MaterialStateProperty.resolveWith<BorderSide>((states) {
            if (states.contains(MaterialState.hovered)) {
              return const BorderSide(
                color: Color(AppConstants.secondaryBlue),
                width: 2.5,
              );
            }
            return const BorderSide(
              color: Color(AppConstants.primaryBlue),
              width: 2,
            );
          }),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 12,
        shadowColor: const Color(AppConstants.shadowColor).withOpacity(0.08),
        surfaceTintColor: Colors.transparent,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: const Color(AppConstants.borderGray).withOpacity(0.3),
            width: 0.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(AppConstants.borderGray).withOpacity(0.5),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(AppConstants.borderGray).withOpacity(0.5),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(AppConstants.primaryBlue),
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(AppConstants.warning),
            width: 2,
          ),
        ),
        hintStyle: const TextStyle(
          color: Color(AppConstants.textGray),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: Color(AppConstants.textGray),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 8,
        highlightElevation: 12,
        backgroundColor: const Color(AppConstants.primaryBlue),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(AppConstants.lightGray).withOpacity(0.7),
        selectedColor: const Color(AppConstants.primaryBlue).withOpacity(0.15),
        labelStyle: const TextStyle(
          color: Color(AppConstants.darkGray),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 2,
        pressElevation: 4,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        elevation: 20,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(AppConstants.darkGray),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(AppConstants.textGray),
          height: 1.5,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 20,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        modalElevation: 20,
        modalBackgroundColor: Colors.white,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: const Color(AppConstants.borderGray).withOpacity(0.4),
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: Color(AppConstants.primaryBlue),
        size: 26,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        elevation: 12,
        backgroundColor: const Color(AppConstants.darkGray),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
        actionTextColor: const Color(AppConstants.lightPurple),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tileColor: Colors.white,
        selectedTileColor:
            const Color(AppConstants.primaryBlue).withOpacity(0.1),
        iconColor: const Color(AppConstants.primaryBlue),
        textColor: const Color(AppConstants.darkGray),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(AppConstants.darkGray),
        ),
        subtitleTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(AppConstants.textGray),
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return const Color(AppConstants.borderGray);
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(AppConstants.primaryBlue);
          }
          return const Color(AppConstants.lightGray);
        }),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(AppConstants.primaryBlue),
        linearTrackColor: Color(AppConstants.lightGray),
        circularTrackColor: Color(AppConstants.lightGray),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(AppConstants.primaryBlue),
        brightness: Brightness.dark,
        primary: const Color(AppConstants.lightPurple),
        secondary: const Color(AppConstants.accentBlue),
        surface: const Color(0xFF1F2937),
        background: const Color(0xFF111827),
      ),

      // Typography for Dark Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: -1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.8,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.4,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF9CA3AF),
          height: 1.5,
        ),
      ),

      // AppBar Theme for Dark
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 8,
        backgroundColor: Color(0xFF1F2937),
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(
          color: Color(AppConstants.lightPurple),
          size: 26,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Dark theme button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 6,
          shadowColor: const Color(AppConstants.lightPurple).withOpacity(0.3),
          backgroundColor: const Color(AppConstants.lightPurple),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Card Theme for Dark
      cardTheme: CardThemeData(
        elevation: 12,
        shadowColor: Colors.black.withOpacity(0.3),
        surfaceTintColor: Colors.transparent,
        color: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: const Color(0xFF374151).withOpacity(0.5),
            width: 0.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),

      // Input Decoration Theme for Dark
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF374151),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF4B5563),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF4B5563),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(AppConstants.lightPurple),
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(AppConstants.warning),
            width: 2,
          ),
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
